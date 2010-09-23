Given /^an invalid configuration file$/ do
  Given %{a file named "config/deploy.rb" with:},
    """
    require 'gitploy/script'
    configure do |c|
      stage :staging do
      end
    end
    """
end

Given /^a valid configuration file$/ do
  Given %{a file named "config/deploy.rb" with:},
    <<-CODE
    require 'gitploy/script'

    configure do |c|
      c.repo = 'git@github.com:brentd/gitploy.git'
      c.path = '/var/www/fooapp'
      c.local_branch = 'master'
      c.remote_branch = 'master'

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
        run "mkdir -p /var/www/fooapp"
        run "cd /var/www/fooapp && git init"
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
        run "cd /var/www/fooapp"
        run "git reset --hard"
        run "bundle install --deployment"
        run "touch tmp/restart.txt"
      end
    end
    CODE
end
