
RSpec.shared_examples_for "frozen middleware" do
	it "should be entirely frozen" do
		current = builder.to_app
		
		while current
			expect(current).to be_frozen
			
			current = current.respond_to?(:app) ? current.app : nil
		end
	end
end

RSpec.shared_context "middleware builder" do
	let(:env) {Hash.new}
	
	let(:builder) do
		# We need to give lexical scope for ruby to find it :)
		middleware = described_class
		
		Rack::Builder.new do
			use middleware
			
			run lambda { |env| [404, {}, []] }
		end
	end
	
	let(:app) {builder.to_app}
	
	it_behaves_like "frozen middleware"
end

class BrokenMiddleware
	def initialize(app)
		@app = app
	end
	
	attr :app
	
	# Broken implementation of freeze doesn't call @app.freeze
	def freeze
		return if frozen?
		
		super
	end
end

class GoodMiddleware
	def initialize(app)
		@app = app
	end
	
	attr :app
	
	# Broken implementation of freeze doesn't call @app.freeze
	def freeze
		return if frozen?
		
		@app.freeze
		
		super
	end
end

class StatefulMiddleware
	def initialize(app)
		@app = app
		@state = 0
	end
	
	attr :app
	attr :state
	
	def call(env)
		@state += 1
		
		return @app.call(env)
	end
end
