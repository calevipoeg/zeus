# frozen_string_literal: true

module Zeus
  class PgBaseBackup
    attr_reader :s3, :bucket, :dir, :prefix

    # @param s3 [Aws::Client::S3]
    def initialize(s3:, bucket:, prefix: 'postgresql')
      @dir = Dir.mktmpdir('pg-base-backup')
      @s3 = s3
      @bucket = bucket
      @prefix = prefix
    end

    def dump(user:, password: nil, port: '5432', host: 'localhost', rate: '10M')
      system <<~CMD.tr("\n", ' '), exception: true
        PG_COLOR=always PGPASSWORD=#{Shellwords.escape password} pg_basebackup
        -D #{dir.pathmap} -Ft -z -Xs
        --host #{host}
        --port #{port}
        --username #{user}
        --max-rate="#{rate}"
        --write-recovery-conf
        --progress
        --verbose
      CMD
    end

    def upload
      Dir.entries(dir.pathmap).each do |filename|
        next if filename.start_with?('.')

        key = File.join(folder, filename)
        file = File.open(File.join(dir, filename), 'rb')
        io = Zeus::S3Io.new(file)

        io.upload(s3, bucket: bucket, key: key) do |progress|
          puts "[#{progress.to_i}%] Uploading #{key}"
        end
      end
    end

    # clear previously sored backup
    # @param [Time]
    def clear(past_time)
      Zeus::S3Iterate.new(s3).delete_if(bucket: bucket, prefix: prefix) do |file|
        break(false) unless past_time >= file.last_modified

        puts "[-] removing (last mod #{file.last_modified}) #{file.key}"
      end
    end

    def unlink
      FileUtils.remove_entry(dir.pathmap) if File.directory?(dir.pathmap)
    end

    private

    def folder
      "#{prefix}/#{timestamp}"
    end

    def timestamp
      @timestamp ||= Time.current.strftime('%Y-%m-%d-%H-%M')
    end
  end
end
