# Hello world rails applocation 

This application only was created with `rails new hello_world` and a new controller with a single action was created
```bash
rails generate controller controller1 index
```

the `routes.rb` was updated to route the root traffic to `controller1#index`

to initialize this app it is necessary execute the next commands

```bash
bundle install
rails server
```

the index method in controller1 controller only set 2 variables to show the variables behavior with helm commands
```ruby
  def index
    @controller_var = "from Controller1Controller"
    @env_var = ENV["CUSTOM_ENV_LOVE"]
  end
```

puma.rb file was updated to allow the rails listen the request in all interfaces
```
bind "tcp://0.0.0.0:#{ENV['PORT'] || 3000}"
```