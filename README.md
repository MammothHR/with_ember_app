[![Build Status](https://travis-ci.com/MammothHR/with_ember_app.svg?token=xGaPGowvPdvqS2QgbViy&branch=master)](https://travis-ci.com/MammothHR/with_ember_app)

# WithEmberApp

Offers a simple mounting point for Ember apps within a Rails app.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'with_ember_app'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install with_ember_app


## Usage

This gem includes the following behavior:

- exposes an endpoint to notify your Rails app about a new Ember build
- caching asset HTML
- version timing
- easy template helper for mounting the Ember asset HTML
- loading spinner / timeout page
- default mounting for development


### Set-up

1. Mount route in your `config/routes.rb`

```
  mount WithEmberApp::Engine => '/with_ember_app'
```

2. Add initializer

```
rails generate with_ember_app:initializer
```

2. Set up asset paths in initializer

3. Set up your Ember Deploy pipeline to build your app, post to the Rails webhook, then host the files (e.g. S3 or Rsync).


### Template Helper

```
= with_ember_app name: 'my-app'
```

Arguments:

- `name` - App name
- `names` - Array of app names (for mounting multiple builds)
- `globals` - Hash of globals to be mixed into `window`
- `loading_spinner` - Whether to show a loading spinner while the app boots
- `timeout_page` - Whether to show an error after a set period of time

### Loading Spinner

If you chose to use the loading spinner, you'll want to add something like this to your Ember App (such as the `afterModel` hook in your application route):
```
$('#ember-app>.ember-app-remove-after-load').remove();
```

To override the loading / error messages, add the following partials in your Rails app:

```
app/views/with_ember_app/_loading_message.html
app/views/with_ember_app/_error_message.html
```

### Version fetching

```
WithEmberApp.fetch_version 'app'
=> Timestamp of latest version
```

### Asset Paths

The trickiest part of this flow is making sure all of your asset paths sync up.  For example:

- in production, you need to adjust the HTML ember-cli generates to point to the actual hosted location (whether on your server or on a CDN).  This is primarily achieved through the `config.url_prep`.

- in development, you need to tell Rails how to find your app's files.  This is primarily achieved by adding your local Ember app's build path to Rail's asset paths.

For more complex apps this may require changing the output filenames Ember CLI generates.  However, for most simple apps this should just work out of the box.  This gem exposes several configuration options for tuning its assumptions about these asset paths.

See the [initializer](lib/generators/templates/with_ember_app.rb) for examples.


### Set up for development

Note that development hosting is easier when you have Rails point to the build directory of your Ember app.  See the initializer for an example.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/with_ember_app.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

