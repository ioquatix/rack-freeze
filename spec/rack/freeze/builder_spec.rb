
require_relative 'frozen_stack'

RSpec.describe StatefulMiddleware do
	include_context "middleware builder"
	
	it "should fail when invoked" do
		expect{app.call(env)}.to raise_error(RuntimeError, /can't modify frozen/)
	end
end

RSpec.describe GoodMiddleware do
	include_context "middleware builder"
end

RSpec.describe 'Faulty #freeze' do
	let(:builder) do
		Rack::Builder.new do
			use BrokenMiddleware
			use GoodMiddleware
			
			run proc{}
		end
	end
	
	it_behaves_like "frozen middleware"
end
