
RSpec.describe Rack::Freeze do
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
  end

  it "should generate a nice class string" do
    instance = Rack::Freeze::Freezer.new(app_class)

    expect(instance.to_s).to include "Freezer"
    expect(instance.to_s).to include app_class.to_s
  end
end
