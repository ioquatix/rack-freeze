# Rack::Freeze

Provides a policy for Rack middleware which should be frozen by default to prevent mutability bugs in a multi-threaded environment.

[![Build Status](https://secure.travis-ci.org/ioquatix/rack-freeze.svg)](http://travis-ci.org/ioquatix/rack-freeze)
[![Code Climate](https://codeclimate.com/github/ioquatix/rack-freeze.svg)](https://codeclimate.com/github/ioquatix/rack-freeze)
[![Coverage Status](https://coveralls.io/repos/ioquatix/rack-freeze/badge.svg)](https://coveralls.io/r/ioquatix/rack-freeze)

## Motivation

I found issues due to unexpected state mutation when developing [Utopia](https://github.com/ioquatix/utopia). It only became apparent when running in production using multi-threaded passenger. Freezing the middleware (and related state) allowed me to identify these issues, find other issues, and helps prevent these issues in the future.

Ideally, [this concept would be part of rack](https://github.com/rack/rack/issues/1010). However, regardless of whether Rack adopts a policy on immutable middleware, this gem provides the tools necessary to implement such a policy transparently on top of existing rack middleware where possible.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-freeze'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-freeze

## Usage

For existing rack middleware, simply wrap it:

```ruby
use Rack::Freeze[Rack::Logger]
```

This will make a subclass of `Rack::Logger` if required with a working implementation of `#freeze`.

In your `config.ru`, you prepare your app using the `#warmup method`;

```ruby
warmup do |app|
	# Recursively freeze all the middleware so that mutation bugs are detected.
	app.freeze
end
```

### What bugs does this fix?

So, instead of writing

```ruby
use External::Middleware
```

you write

```ruby
use Rack::Freeze[External::Middleware]
```

That ensures that `External::Middleware` will correctly freeze itself and all subsequent apps. Additionally, if `External::Middleware` mutates it's state, it will throw an exception. In a multi-threaded web-server, unprotected mutation of internal state will lead to undefined behavior.

### Thar be the Monkeys

Some Rack middleware is not easy to patch in a generic way, e.g. `Rack::URLMap`. As these are identified, they will be monkey patched by this gem automatically. Going forward, I hope to bring attention to this issue and ideally integrate these changes directly into Rack.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the MIT license.

Copyright, 2017, by [Samuel G. D. Williams](http://www.codeotaku.com/samuel-williams).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
