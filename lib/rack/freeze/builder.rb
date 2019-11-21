# Copyright, 2017, by Samuel G. D. Williams. <http://www.codeotaku.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'rack/builder'
require_relative 'freezer'

module Rack
  module Freeze
    module Builder
      def use(klass, *args, &block)
        if ignored_middleware?(klass)
          super(klass, *args, &block)
        else
          super(Freezer.new(klass), *args, &block)
        end
      end

      def run(app)
        if ignored_middleware?(app.class)
          super(app)
        else
          super(app.freeze)
        end
      end

      def to_app
        app = super
        ignored_middleware?(app.class) ? app : app.freeze
      end

      private

      def ignored_middleware?(klass)
        Rack::Freeze.configuration.ignored_middlewares.include?(klass)
      end
    end
  end
end
