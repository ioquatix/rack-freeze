
require_relative 'builder'

RSpec.describe StatefulMiddleware do
  include_context "middleware builder"

  it "should fail when invoked" do
    expect{app.call(env)}.to raise_error(RuntimeError, /can't modify frozen/)
  end
end

RSpec.describe GoodMiddleware do
  include_context "middleware builder"
end

RSpec.describe FaultyMiddleware do
  let(:builder) do
    Rack::Builder.new do
      use FaultyMiddleware
      use GoodMiddleware

      run proc{}
    end
  end

  it_behaves_like "frozen middleware"
end

require 'rack/urlmap'

RSpec.describe 'Builder#generate_map' do
  let(:builder) do
    Rack::Builder.new do
      map '/foo' do
        use GoodMiddleware
        run proc{}
      end

      map '/bar' do
        use FaultyMiddleware
        use GoodMiddleware
        run proc{}
      end
    end
  end

  it_behaves_like "frozen middleware"
end
