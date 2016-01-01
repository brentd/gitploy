## Gitploy: dead-simple deployment DSL created with git in mind

### Why yet another deployment solution?

* Because Capistrano is bloated
* Because, no, I don't want to use rake for deployment, thank you
* Because I'm sick of having to jump through flaming hoops just to tweak the arguments of some stupid command
* Because I want something bare minimum, git-based, and dead-simple
* Because I felt like it

Gitploy was created to do dead-simple git-push based deployments. It doesn't use rake, it doesn't
require git hooks, it just does the bare minimum. It's so minimal, in fact, that it doesn't even
come with its own "recipe" - Gitploy is actually just a DSL to quickly define your own deployment
strategy. No hooks, very little behind-the-scenes magic - it just does what you tell it to.

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
        echo "Deployment complete. Restarting server!"
        run "touch tmp/restart.txt"
        
        # uncomment the line below to send new relic a deployment marker
        # newrelic_deployment_marker
      end
    end

### Usage

    $ gem install gitploy
    # create config/gitploy.rb
    $ gitploy production setup
    $ gitploy production

    # In case of emergency you can do a git push with the --force option
    $ gitploy production --force

### New Relic Deployment Marker

Gitploy supports sending [New Relic Deployment Markers](https://docs.newrelic.com/docs/apm/new-relic-apm/maintenance/deployment-notifications). 

In your config/gitploy.rb
    
    deploy do
      push!
      remote do
        run "cd #{config.path}"
        run "git reset --hard"
        run "bundle install --deployment"
        echo "Deployment complete. Restarting server!"
        run "touch tmp/restart.txt"
        
        # new relic a deployment marker
        newrelic_deployment_marker
      end
    end

The newrelic_deployment_marker supports the following optional overrides:

    deploy do
      push!
      remote do
        run "cd #{config.path}"
        run "git reset --hard"
        run "bundle install --deployment"
        echo "Deployment complete. Restarting server!"
        run "touch tmp/restart.txt"
        
        # new relic a deployment marker
        newrelic_deployment_marker( stage: 'custom_stage_name', user: 'custom_user', revision: 'custom_revision', message: 'custom_message')
      end
    end


### Disclaimer

Gitploy is super alpha - don't use it yet, unless you're just that baller. Are you?

### Known issues

* Not enough documentation
* DSL implementation is pretty dumb and needs refactoring
