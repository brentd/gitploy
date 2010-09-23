$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))
require 'gitploy/script'

configure do |c|
  c.repo = 'git@github.com:tsigo/gitploy.git'
  c.path = '/var/www/fooapp'

  stage :staging do
    c.host = 'staging.gitploy.foo'
    c.user = 'staging'
  end

  stage :production do
    c.host = 'gitploy.foo'
    c.user = 'production'
  end
end

setup do
  local do
    run "echo 'Setup local'"
  end
  remote do
    run "mkdir -p #{config.path}"
    run "cd #{config.path} && git init"
    run "git config --bool receive.denyNonFastForwards false"
    run "git config receive.denyCurrentBranch ignore"
  end
end

deploy do
  push!
  local do
    run "echo 'Deploy local'"
  end
  remote do
    run "cd #{config.path}"
    run "git reset --hard"
    run "bundle install --deployment"
    run "touch tmp/restart.txt"
  end
end
