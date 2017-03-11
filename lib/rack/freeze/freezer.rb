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

module Rack
	module Freeze
		class Freezer
			def initialize(klass)
				@klass = klass
			end
			
			def to_s
				"#{self.class}<#{@klass}>"
			end
			
			private def freeze_instance_variables(instance)
				# This ensures that all instance variables are frozen.
				instance.instance_variables.each do |name|
					instance.instance_variable_get(name).freeze
				end
			end
			
			# Check if the given klass overrides `Kernel#freeze`.
			def implements_freeze?
				@klass.instance_method(:freeze).owner != Kernel
			end
			
			def new(*args, &block)
				instance = @klass.new(*args, &block)
				
				unless implements_freeze?
					freeze_instance_variables(instance)
				end
				
				return instance.freeze
			end
		end
		
		# Return a wrapper that will freeze the instance after calling `#new`.
		def self.[] klass
			Freezer[klass]
		end
	end
end
