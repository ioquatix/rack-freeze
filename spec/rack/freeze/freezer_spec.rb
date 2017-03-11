
RSpec.describe Rack::Freeze do
	let(:class_with_freeze) do
		Class.new(Object) do
			def freeze
			end
		end
	end
	
	it "should detect class has \#freeze" do
		expect(Rack::Freeze::Freezer.new(class_with_freeze).implements_freeze?).to be_truthy
	end
	
	let(:class_without_freeze) do
		Class.new(Object)
	end
	
	it "should detect class without \#freeze" do
		expect(Rack::Freeze::Freezer.new(class_without_freeze).implements_freeze?).to be_falsey
	end
	
	let(:default_app) {proc{|env| nil}}
	let(:app_class) do
		Class.new(Object) do
			def initialize(app)
				@app = app
			end
			
			attr :app
		end
	end
	
	it "should make a frozen instance" do
		instance = Rack::Freeze::Freezer.new(app_class).new(default_app)
		expect(instance).to be_frozen
		expect(instance.app).to be_frozen
	end
	
	it "should generate a nice class string" do
		instance = Rack::Freeze::Freezer.new(app_class)
		
		expect(instance.to_s).to include "Freezer"
		expect(instance.to_s).to include app_class.to_s
	end
end
