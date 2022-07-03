# Gitploy: dead-simple deployment DSL created with git in mind

## ⚠️ NOT MAINTAINED ⚠️

This project is not maintained. I would recommend looking elsewhere for your deployment needs :)

### Example config/gitploy.rb

    require 'gitploy/script'

    configure do |c|
      c.path = '/var/www/fooapp'

      stage :staging do
        c.host = 'staging.fooapp.com'
        c.user = 'ninja'
      end

      stage :production do
        c.host = 'fooapp.com'
        c.user = 'deployer'
      end
    end

    setup do
      remote do
        run "mkdir -p #{config.path}"
        run "cd #{config.path} && git init"
        run "git config --bool receive.denyNonFastForwards false"
        run "git config receive.denyCurrentBranch ignore"
      end
    end

    deploy do
      push!
      remote do
        run "cd #{config.path}"
        run "git reset --hard"
        run "bundle install --deployment"
        run "touch tmp/restart.txt"
      end
    end

### Usage

    $ gem install gitploy
    # create config/deploy.rb
    $ gitploy production setup
    $ gitploy production
