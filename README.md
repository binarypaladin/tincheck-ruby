# TINCheck

## Overview

This gem provides a simple interface for interacting with TINCheck's SOAP API. It doesn't use any SOAP library and the response object is a glorified hash that merges all the keys from the various Result elements.

## Installation

Pretty standard gem stuff.

    $ gem install tincheck

When using [Bundler](https://bundler.io) or requiring this library in general, it's important to note that this gem will attempt to load its XML add-ons by default if `Ox` or `Nokogiri` is already defined, it will use them in that order. Otherwise, it will use the default of `REXML`. The only consideration is that `REXML` will get required if neither optional library is already required.

So, ensure you load your project's XML libs (if you're using them) first.

## Configuration

Generally, you'll just configure a username and password. Unfortunately, TINCheck doesn't have any sort of a sandbox. Happy testing.

### `ENV`

Prefix any configuration option with `tincheck_` and it will be automatically set:

* `ENV['tincheck_password']`
* `ENV['tincheck_proxy_url']`
* `ENV['tincheck_username']`
* `ENV['tincheck_xml_lib']`

You can return the configuration set by the environment with `TINCheck.env_config` which might be useful in situations where you want multiple configurations modified from a default set by the environment.

### With a Hash

```ruby
TINCheck.configure(
  password: 'password',
  username: 'user@example.com'
)
```

### With a Block

```ruby
TINCheck.configure do
  password 'password'
  username 'user@example.com'
end
```

## Making Requests

Basic requests can be made using `TINCheck.request`. This will take the supplied hash, wrap it in a SOAP envelop and inject the proper credentials. You should probably never do this directly.

TINCheck only supports for different services and this gem currently supports only two of those, each with its own method.

### Check Service Status

If you want to just make sure everything is working:

```ruby
response = TINCheck.status # => #<TINCheck::Response>
```

### Check a TIN and a Name

```ruby
response = TINCheck.tin_name(name: 'John Q Person', tin: '000000000') # => #<TINCheck::Response>
response.name_and_tin_match? # => true
response.death_record? # => false
```

## Contributing

### Issue Guidelines

GitHub issues are for bugs, not support. As of right now, there is no official support for this gem. You can try reaching out to the author, [Joshua Hansen](mailto:joshua@epicbanality.com?subject=TINCheck) if you're really stuck, but there's a pretty high chance that won't go anywhere at the moment or you'll get a response like this:

> Hi. I'm super busy. It's nothing personal. Check the README first if you haven't already. If you don 't find your answer there, it's time to start reading the source. Have fun! Let me know if I screwed something up.

### Pull Request Guidelines

* Include tests with your PRs. (Wouldn't it be nice if I included some?)
* Run `rubocop` to ensure your style fits with the rest of the project.

### Code of Conduct

Be nice. After all, this is free code. I have a day job.

## License

See [`LICENSE.txt`](LICENSE.txt).

## What if I stop maintaining this?

The codebase isn't huge. If you opt to rely on this code and I die/get bored/find enlightenment you should be able to maintain it. Sadly, that's the only guarantee at the moment!
