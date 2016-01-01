require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + "/../lib/gitploy")
include Gitploy

describe 'Giploy' do
	context 'newrelic_deployment_marker' do
    it 'works without parameters' do
      should_receive(:current_stage).and_return('test')
      should_receive(:current_user).and_return('deploy@example.org')
      should_receive(:current_revision).and_return('d9f8bed')
      should_receive(:commit_message).and_return('add echo command')
      newrelic_deployment_marker
      send(:flush_run_queue).should == 'bundle exec newrelic deployments -e test --user=deploy@example.org --revision=d9f8bed add echo command'
    end
    it 'allows parameter overrides' do
      newrelic_deployment_marker(stage: 'staging', user: 'bob@barker.com', revision: 'some_hash', message: 'test commit')
      send(:flush_run_queue).should == 'bundle exec newrelic deployments -e staging --user=bob@barker.com --revision=some_hash test commit'
    end
  end
end