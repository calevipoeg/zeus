# frozen_string_literal: true

require 'aws-sdk-s3'

# === S3 decorator for the IO object
module Zeus
  class S3Io
    # * Размер каждой части, кроме последней, должен быть не менее 5MB
    # * Номер — это целое число в промежутке от 1 до 10000 включительно
    DEFAULT_PART_SIZE = 1024 * 1024 * 50 # 50MB

    attr_reader :io, :part_size

    # @param [File, StringIO, IO]
    def initialize(io, part_size: DEFAULT_PART_SIZE)
      @io = io
      @part_size = part_size
    end

    # @param s3 [Aws::S3::Client]
    def upload(s3, bucket:, key:, **extra, &block)
      if multipart?
        upload_multipart(s3, bucket: bucket, key: key, **extra, &block)
      else
        s3.put_object(bucket: bucket, key: key, body: io.read, **extra)
        yield(100) if block_given?
      end
    end

    private

    def upload_multipart(s3, bucket:, key:, **extra)
      multipart = s3.create_multipart_upload(bucket: bucket, key: key, **extra)
      parts = []

      each_part do |part, num|
        parts << s3.upload_part(
          body: part,
          bucket: bucket,
          content_length: part.bytesize,
          key: key,
          part_number: num,
          upload_id: multipart.upload_id
        )

        progress = (num.fdiv(total_parts) * 100).round
        progress = 100 if progress > 100

        yield(progress) if block_given?
      end

      s3.complete_multipart_upload(
        bucket: bucket,
        key: key,
        upload_id: multipart.upload_id,
        multipart_upload: {
          parts: parts.map.with_index  do |part, ix|
            {
              etag: part.etag,
              part_number: ix.next
            }
          end
        }
      )
    end

    # yields parts bytes and number of a page
    def each_part(num: 1)
      until io.eof?
        yield(io.read(part_size), num)
        num += 1
      end
    end

    def multipart?
      total_parts.nonzero?
    end

    def total_parts
      io.size.fdiv(part_size).ceil
    end
  end
end
