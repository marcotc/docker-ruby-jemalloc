# frozen_string_literal: true

require 'thor'
require 'git'

# WIP WIP WIP
class A
  class << self
    NAME = 'ruby'
    URI = "https://github.com/docker-library/#{NAME}.git"
    DIRECTORY = './tmp/'

    def clone_source
      Git.clone(URI, NAME, path: './tmp/', depth: 1)
    end

    def main
      clone_source
      Dir.chdir(File.join(DIRECTORY, NAME)) do
        Replace.new.call
      end
    end
  end
end

# WIP WIP WIP
class Replace < Thor
  include Thor::Actions
  def call
    insert_into_file 'Dockerfile-slim.template',
                     "\t\tlibjemalloc-dev \\\n",
                     after: "libgdbm3 \\\n"

    insert_into_file 'Dockerfile-slim.template',
                     "\t\t--with-jemalloc \\\n",
                     after: "--enable-shared \\\n"

    append_file 'Dockerfile-slim.template', <<~RUBY
       # Sanity check for jemalloc
      RUN ruby -r rbconfig -e "abort 'jemalloc not enabled' unless RbConfig::CONFIG['LIBS'].include?('jemalloc')"
    RUBY

    puts `PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH" ./update.sh`
  end
end

A.main
