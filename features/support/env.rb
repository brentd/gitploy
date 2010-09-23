require 'rubygems'
require 'aruba'
require 'fileutils'

Before do
  FileUtils.rm_rf("tmp")
  FileUtils.mkdir("tmp")
end

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..')).freeze
BIN_PATH = File.join(PROJECT_ROOT, 'bin').freeze
LIB_PATH = File.join(PROJECT_ROOT, 'lib').freeze

ENV['PATH'] = [BIN_PATH, ENV['PATH']].join(':')
ENV['RUBYLIB'] = LIB_PATH
