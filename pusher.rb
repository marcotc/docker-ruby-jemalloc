# frozen_string_literal: true

require 'yaml'

class Pusher
  PROJECT_PREFIX = 'jemalloc/ruby'

  class << self
      def list
        lines = YAML.load_file('.travis.yml')['env']
        lines.map do |line|
          ruby_version = line.split[0].delete_prefix('VERSION=')

          os_version = line.split[1].delete_prefix('VARIANT=').split('/')

          [ruby_version, os_version].flatten
        end
      end

      def version(image)
        `docker run -i -t #{PROJECT_PREFIX}:#{image} bash -c 'echo "$RUBY_VERSION"'`.strip
      end

      def tag(source, tag)
        puts "docker tag #{PROJECT_PREFIX}:#{source} #{PROJECT_PREFIX}:#{tag}"
      end

      def push(image)
        puts "docker push #{PROJECT_PREFIX}:#{image}"
      end

      def call
        images = list.flat_map do |version|
          version_str = version.join('-')
            ruby_version = version(version_str)
            if ruby_version.split('.').size == 3
              long_version = ruby_version

              long_version_list = [long_version, *version[1..-1]]
              tag(version_str, long_version_list.join('-'))

              [version, long_version_list]
            else
              [version]
            end
        end

        images.each{|image| push(image.join('-'))}
      end
  end
end

pp Pusher.call
