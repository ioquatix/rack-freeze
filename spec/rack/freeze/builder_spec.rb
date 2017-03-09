
RSpec.shared_context "app builder" do
	let(:env) {Hash.new}
	
	let(:app) do
		# We need to give lexical scope for ruby to find it :)
		middleware = described_class
		
		Rack::Builder.new do
			use middleware
			
			run lambda { |env| [404, {}, []] }
		end.to_app
	end
	
	it "should generate frozen app" do
		expect(app.frozen?).to be_truthy
	end
end

class NonConformingMiddleware
	def initialize(app)
		@app = app
		@state = 0
	end
	
	def call(env)
		@state += 1
		
		return @app.call(env)
	end
end

RSpec.describe NonConformingMiddleware do
	include_context "app builder"
	
	it "should fail when invoked" do
		expect{app.call(env)}.to raise_error(RuntimeError, /can't modify frozen/)
	end
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
