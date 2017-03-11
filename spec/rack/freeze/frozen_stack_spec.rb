
RSpec.shared_context "frozen stack" do
	let(:top) {builder.to_app}
	
	it "should generate completely frozen app" do
		current = top
		
		while current
			expect(current).to be_frozen
			
			current = current.app
		end
	end
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

RSpec.describe 'Faulty #freeze' do
	let(:builder) do
		Rack::Builder.new do
			use BrokenMiddleware
			use GoodMiddleware
			
			run proc{}
		end
	end
	
	include_context "frozen stack"
end
