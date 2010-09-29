module Gitploy
  extend self
  attr_accessor :config

  class Config
    REQUIRED_OPTIONS = [:path, :user, :host]
    attr_accessor *REQUIRED_OPTIONS
    attr_accessor :local_branch, :remote_branch

    def check!
      unless missing_options.empty?
        raise "The following configuration options are missing for the '#{Gitploy.current_stage}' stage: #{missing_options.join(', ')}"
      end
    end

    def missing_options
      REQUIRED_OPTIONS.select {|m| send(m).nil? }
    end
  end

  def configure
    config = Config.new
    yield config; config.check!

    config.local_branch ||= current_branch
    config.remote_branch ||= 'master'

    self.config = config
  end

  def current_stage
    ARGV[0]
  end

  def action
    ARGV[1]
  end

  def stage(name)
    yield if name.to_s == current_stage
  end

  def deploy
    yield unless action == 'setup'
  end

  def setup
    yield if action == 'setup'
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

  def push!
    local { run "git push #{config.user}@#{config.host}:#{config.path}/.git #{config.local_branch}:#{config.remote_branch}" }
  end

  private

    def pretty_run(title, cmd)
      puts
      print_bar(100, title)
      puts "> #{cmd}"
      puts
      Kernel.system(cmd) unless pretend?
      print_bar(100)
    end

    def print_bar(width, title=nil)
      if title
        title += " (pretend)" if pretend?
        half_width = (width / 2) - (title.length / 2) - 2
        left_bar  = '=' * half_width
        right_bar = '=' * (title.length % 2 == 0 ? half_width : half_width - 1) # TODO: lame.
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

    def current_branch
      if branch = `git symbolic-ref HEAD`
        branch.chomp.gsub('refs/heads/', '')
      else
        'master'
      end
    end

    def pretend?
      pretend = %w(-p --pretend)
      ARGV.any? { |v| pretend.include? v }
    end
end
