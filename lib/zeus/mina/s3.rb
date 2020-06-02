require 'aws-sdk-s3'

set :s3_client, -> { raise }
set :s3_bucket, -> { raise }

namespace :s3 do
  task :upload, %i[dirs destination] do |_t, argv|
    Array(argv.dirs).each do |dir|
      Dir.glob(Pathname.new(dir).join('**/**')).each do |file|
        next if File.directory?(file)

        path = Pathname.new(file).relative_path_from(dir)
        key = Pathname.new(argv.destination).join(path)
        io = Zeus::S3Io.new(File.open(file))

        io.upload(fetch(:s3_client), bucket: fetch(:s3_bucket), acl: 'public-read', key: String(key)) do |progress|
          puts "[#{progress}%] Uploading #{file} -> #{key}"
        end
      end
    end
  end

  task :clean, %i[prefix last_mod] do |_t, argv|
    Zeus::S3Iterate.new(fetch(:s3_client)).delete_if(bucket: fetch(:s3_bucket), prefix: argv.prefix) do |file|
      break(false) unless argv.last_mod >= file.last_modified

      puts "[-] removing (last mod #{file.last_modified}) #{file.key}"
    end
  end
end
