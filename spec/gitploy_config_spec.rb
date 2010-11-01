require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + "/../lib/gitploy")

describe 'Gitploy::Config' do
  context 'initialization' do
    it 'can be created' do
      Gitploy::Config.new.should_not be_nil
    end
  end
  context 'attribute storing' do
    before :each do
      @config = Gitploy::Config.new
    end
    it 'stores path' do
      @config.path = 'test'
      @config.path.should eql 'test'
    end
    it 'stores user' do
      @config.user = 'test'
      @config.user.should eql 'test'
    end
    it 'stores host' do
      @config.host = 'test'
      @config.host.should eql 'test'
    end
    it 'stores local_branch' do
      @config.local_branch = 'test'
      @config.local_branch.should eql 'test'
    end
    it 'stores remote_branch' do
      @config.remote_branch = 'test'
      @config.remote_branch.should eql 'test'
    end
  end
  context 'attribute checking' do
    it 'returns missing options' do
      config = Gitploy::Config.new
      config.user = 'test'   
      config.host = 'test'   
      config.missing_options.should eql [:path]
    end
    it 'raises error when checked' do
      Gitploy.stub!(:current_stage).and_return('test')
      config = Gitploy::Config.new
      config.user = 'test'   
      config.host = 'test'
      lambda {config.check!}.should raise_error(RuntimeError, "The following configuration options are missing for the 'test' stage: path")
    end
  end
end
