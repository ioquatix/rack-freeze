require "spec_helper"

RSpec.describe Rack::Freeze do
	it "should detect class has \#freeze" do
		klass = Class.new(Object) do
			def freeze
			end
		end
		
		expect(Rack::Freeze.implements_freeze?(klass)).to be_truthy
	end
	
	it "should detect class without \#freeze" do
		klass = Class.new(Object)
		
		expect(Rack::Freeze.implements_freeze?(klass)).to be_falsey
	end
	
	it "should make instance with freeze" do
		klass = Class.new(Object) do
			attr :app
		end
		
		expect(Rack::Freeze.implements_freeze?(klass)).to be_falsey
		expect(Rack::Freeze.implements_freeze?(Rack::Freeze[klass])).to be_truthy
	end
end
