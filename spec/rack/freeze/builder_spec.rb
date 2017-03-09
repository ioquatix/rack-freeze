
RSpec.shared_context "app builder" do
	it "should generate frozen app" do
		# We need to give lexical scope for ruby to find it :)
		middleware = described_class
		
		app = Rack::Builder.new do
			use middleware
			
			run lambda { |env| [404, {}, []] }
		end.to_app
		
		expect(app.frozen?).to be_truthy
	end
end

class NonConformingMiddleware
	def initialize(app)
		@app = app
	end
	
	def call(env)
		return @app.call(env)
	end
end

RSpec.describe NonConformingMiddleware do
	include_context "app builder"
end

class ConformingMiddleware < NonConformingMiddleware
	def freeze
		@app.freeze
		
		super
	end
end

RSpec.describe ConformingMiddleware do
	include_context "app builder"
end
