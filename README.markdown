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

### Example config/deploy.rb

    configure do |c|
      c.repo = 'git@github.com:myuser/fooapp.git'
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

### Disclaimer

Gitploy is super alpha - don't use it yet, unless you're just that baller. Are you?