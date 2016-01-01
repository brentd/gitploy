require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + "/../lib/gitploy")
include Gitploy

describe 'Giploy' do
  context 'setting arguments' do
    it 'returns current stage from ARGV[0]' do
      ARGV[0] = 'test'
      current_stage.should == 'test'
    end
    it 'returns current action from ARGV[1]' do
      ARGV[1] = 'setup'
      action.should == 'setup'
    end
  end
  context 'consuming config' do
    it 'yields block for current stage' do
      ARGV[0] = 'test'
      lambda do
        stage :test do
          raise 'Error'
        end
      end.should raise_error
    end
    it 'does not yield block for other stage' do
      ARGV[0] = 'test'
      lambda do
        stage :staging do
          raise 'Error'
        end
      end.should_not raise_error
    end
    it 'yields block for deploy when action is not set' do
      ARGV[1] = nil
      lambda do
        deploy do
          raise 'Error'
        end
      end.should raise_error
    end
    it 'yields block for deploy when action is set to deploy' do
      ARGV[1] = 'deploy'
      lambda do
        deploy do
          raise 'Error'
        end
      end.should raise_error
    end
    it 'yields block for setup when action is set to setup' do
      ARGV[1] = 'setup'
      lambda do
        setup do
          raise 'Error'
        end
      end.should raise_error
    end
    it 'does not yield block for setup when action is set to deploy' do
      ARGV[1] = 'deploy'
      lambda do
        setup do
          raise 'Error'
        end
      end.should_not raise_error
    end
    it 'is configured in block with required options set' do
      ARGV[0] = 'test'
      configure do |config|
        config.path = '/var/apps'
        stage :test do
          config.host = 'example.org'
          config.user = 'deploy'
        end
      end
    end
    it 'raises error when option is missing' do
      ARGV[0] = 'test'
      lambda do 
        configure do |config|
          config.path = '/var/apps'
          stage :test do
            config.host = 'example.org'
          end
        end
      end.should raise_error
    end
  end
  context 'running queue' do
    it 'adds command to queue' do
      run 'test'
      run 'test'
      instance_variable_get(:@run_queue).should == ['test', 'test']
    end
    it 'adds sudo commands to queue' do
      sudo 'test'
      sudo 'test'
      instance_variable_get(:@run_queue).should == ['sudo test', 'sudo test']
    end
    it 'adds rake commands to queue' do
      rake 'test'
      rake 'test'
      instance_variable_get(:@run_queue).should == ['rake test', 'rake test']
    end
    it 'flushes command queue' do
      run 'test'
      run 'test'
      send(:flush_run_queue)
      instance_variable_get(:@run_queue).should == []
    end
    it 'returns all added commands joined for execution when flushing queue' do
      run 'test'
      run 'test'
      send(:flush_run_queue).should == 'test && test'
    end
  end
  context 'remote and local evaluating' do
    before :each do
      ARGV[0] = 'test'
      @config = configure do |config|
        config.path = '/var/apps'
        stage :test do
          config.host = 'example.org'
          config.user = 'deploy'
          config.local_branch = 'master'
        end
      end
    end
    it 'flushes run queue after running remote block' do
      stub(:pretty_run).and_return(nil)
      remote do
        run 'test'
        run 'test'
      end
      instance_variable_get(:@run_queue).should == []
    end
    it 'executes remote command from block' do
      should_receive(:pretty_run).with("example.org", "ssh deploy@example.org 'test && test'")
      remote do
        run 'test'
        run 'test'
      end
    end
    it 'flushes run queue after running local block' do
      should_receive(:pretty_run).and_return(nil)
      local do
        run 'test'
        run 'test'
      end
      instance_variable_get(:@run_queue).should == []
    end
    it 'executes local command from block' do
      stub(:pretty_run).and_return(nil)
      local do
        run 'test'
        run 'test'
      end
    end
    it 'pushes local changes' do
      should_receive(:pretty_run).with("LOCAL",
        "git push deploy@example.org:/var/apps/.git master:master")
      deploy do
        push!
      end
    end
    it 'remote command from block evals current_user var' do
      stub(:current_user).and_return('deploy@example.org')
      should_receive(:pretty_run).with("example.org", "ssh deploy@example.org 'test && deploy@example.org'")
      remote do
        run 'test'
        run "#{current_user}"
      end
    end
  end
  context 'detecting environment' do
    it 'returns current git branch' do
      should_receive(:`).with('git symbolic-ref HEAD').and_return('refs/heads/test')
      send(:current_branch).should == 'test'
    end

    it 'returns current user email' do
      should_receive(:`).with('git config user.email').and_return('deploy@example.org')
      send(:current_user).should == 'deploy@example.org'
    end
  end
end
