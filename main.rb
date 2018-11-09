# frozen_string_literal: true

require 'thor'
require 'git'

# WIP WIP WIP
class Main
  class << self
    NAME = 'ruby'
    URI = "https://github.com/docker-library/#{NAME}.git"
    DIRECTORY = './tmp/'

    def clone_source
      Git.clone(URI, NAME, path: './tmp/', depth: 1)
    end

    def call
      clone_source
      Dir.chdir(File.join(DIRECTORY, NAME)) do
        Replace.new.in_project
      end

      Replace.new.root
    end
  end
end

# WIP WIP WIP
class Replace < Thor
  include Thor::Actions

  def in_project
    puts `cp '.travis.yml' '../../'`

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

  def root
    prepend_file '.travis.yml', <<~YAML
      before_script: cd ./tmp/ruby
    YAML
  end
end

Main.call