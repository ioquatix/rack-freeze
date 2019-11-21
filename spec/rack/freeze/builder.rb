
RSpec.shared_examples_for "frozen middleware" do
	it "should be entirely frozen" do
		current = builder.to_app

		expect(current).to_not be_nil

		# This can't traverse into Rack::URLMap and I'm not really sure how it should do that.
		while current
			expect(current).to be_frozen

			current = current.respond_to?(:app) ? current.app : nil
		end
	end

  it "should not be frozen if configuration ignores it" do
    allow(Rack::Freeze.configuration).to receive(:ignored_middlewares)
                                           .and_return([described_class])

    expect(builder.to_app).to_not be_frozen
  end
end

RSpec.shared_context "middleware builder" do
	let(:env) {Hash.new}

	let(:builder) do
		Rack::Builder.new.tap do |builder|
			builder.use described_class
			builder.run lambda { |env| [404, {}, []] }
		end
	end

	let(:app) {builder.to_app}

	it "should generate a valid app" do
		expect(app).to_not be_nil
	end

	it_behaves_like "frozen middleware"
end

class FaultyMiddleware
	def initialize(app)
		@app = app
	end

	attr :app

	# Broken implementation of freeze doesn't call @app.freeze
	def freeze
		return self if frozen?

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
		return self if frozen?

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
