module Gitploy
  extend self
  attr_accessor :config

  class Config
    REQUIRED_OPTIONS = [:repo, :path, :user, :host]
    attr_accessor *REQUIRED_OPTIONS

    def check!
      unless missing_options.empty?
        raise "The following configuration options are missing for the '#{Gitploy.current_stage}' stage: #{missing_options.join(', ')}"
      end
    end

    def missing_options
      REQUIRED_OPTIONS.select {|m| send(m) == nil }
    end
  end

  def configure
    config = Config.new
    yield config; config.check!
    self.config = config
  end

  def current_stage
    ARGV[0]
  end

  def stage(name)
    yield if name.to_s == current_stage
  end

  def deploy
    yield if ARGV[1].nil?
  end

  def setup
    yield if ARGV[1] == 'setup'
  end

  def remote
    yield
    pretty_run(config.host, "ssh #{config.user}@#{config.host} '#{flush_run_queue}'")
  end

  def local
    yield
    pretty_run("LOCAL", flush_run_queue)
  end

  def run(cmd)
    run_queue << cmd
  end

  def sudo(cmd)
    run("sudo #{cmd}")
  end

  def rake(task)
    run("rake #{task}")
  end

  def push
    local { run "git push #{config.user}@#{config.host}:#{config.path}/.git master" }
  end

  private

    def pretty_run(title, cmd)
      puts
      print_bar(100, title)
      puts "> #{cmd}"
      puts
      Kernel.system(cmd)
      print_bar(100)
    end

    def print_bar(width, title=nil)
      if title
        half_width = (width / 2) - (title.length / 2) - 2
        left_bar  = '=' * half_width
        right_bar = '=' * (title.length % 2 == 0 ? half_width : half_width - 1)
        puts "#{left_bar}( #{title} )#{right_bar}"
      else
        puts "=" * width
      end
    end

    def run_queue
      @run_queue ||= []
    end

    def flush_run_queue
      cmd = run_queue.join(' && ')
      @run_queue = []
      cmd
    end
end

include Gitploy