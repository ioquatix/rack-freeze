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

## Usage

Add this to your config.ru:

```ruby
require 'rack/freeze'
```

Now all your middleware will be frozen by default.

### What bugs does this fix?

It guarantees as much as is possible, that middleware won't mutate during a request.

```ruby
# This modifies `Rack::Builder#use` and `Rack::Builder#to_app` to generate a frozen stack of middleware.
require 'rack/freeze'

class NonThreadSafeMiddleware
	def initialize(app)
		@app = app
		@state = 0
	end

	def call(env)
		@state += 1

		return @app.call(env)
	end
end

use NonThreadSafeMiddleware
```

As `NonThreadSafeMiddleware` mutates it's state `@state += 1`, it will raise a `RuntimeError`. In a multi-threaded web-server, unprotected mutation of internal state will lead to undefined behavior. [5 out of 4 dentists agree that multi-threaded programming is hard to get right](http://www.rubyinside.com/does-the-gil-make-your-ruby-code-thread-safe-6051.html).

### How to write thread-safe middleware?

There are two options: Don't mutate state, or if you need to for the purposes of performance, implement `#freeze` and use data-structures from [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby).

```ruby
require 'concurrent/map'

# Cache every request based on the path. Don't do this in production :)
class CacheEverythingForever
	def initialize(app)
		@app = app
		@cache_all_the_things = Concurrent::Map.new
	end

	def freeze
		return self if frozen?

		# Don't freeze @cache_all_the_things
		@app.freeze

		super
	end

	def call(env)
		# Use the thread-safe `Concurrent::Map` to fetch the value or store it if it doesn't exist already.
		@cache_all_the_things.fetch_or_store(env[Rack::PATH_INFO]) do
			@app.call(env)
		end
	end
end
```

### Can I ignore a specific middleware ?

In some particular cases, we want to be able to ignore a mutable middleware. This can be done in `config.ru` :

```ruby
Rack::Freeze.configure do |config|
  config.ignored_middlewares << MutableButFineMiddleware
end
```

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
