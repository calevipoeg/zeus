# frozen_string_literal: true

require 'aws-sdk-s3'

# Clean S3 files base on file#lost_mod
module Zeus
  class S3Iterate
    attr_reader :s3

    def initialize(s3)
      @s3 = s3
    end

    def delete_if(bucket:, prefix:)
      each_file(bucket: bucket, prefix: prefix) do |file|
        next unless yield(file)

        s3.delete_object(bucket: bucket, key: file.key)
      end
    end

    def each_file(bucket:, prefix:)
      s3.list_objects_v2(bucket: bucket, prefix: prefix).each do |page|
        iterate(page) do |list|
          list.contents.each do |file|
            yield(file)
          end
        end
      end
    end

    private

    # @param page [Seahorse::Client::Response]
    def iterate(page, &block)
      yield(page)
      iterate(page.next_page, &block) if page.next_page?
    end
  end
end
