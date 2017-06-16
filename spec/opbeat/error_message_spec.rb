require 'spec_helper'

module Opbeat
  RSpec.describe ErrorMessage do

    let(:config) { Configuration.new }

    def real_exception
      1 / 0
    rescue => e
      e
    end

    describe "#initialize" do
      it "sets attrs by hash" do
        error = ErrorMessage.new config, 'Error', level: :warn
        expect(error.level).to eq :warn
      end
      it "yields itself" do
        error = ErrorMessage.new(config, 'Error') { |m| m.level = :warn }
        expect(error.level).to eq :warn
      end
    end

    describe ".from_exception" do
      it "initializes from an exception" do
        error = ErrorMessage.from_exception config, real_exception
        expect(error.message).to eq 'ZeroDivisionError: divided by 0'
        expect(error.level).to eq :error

        expect(error.exception.type).to eq 'ZeroDivisionError'
        expect(error.exception.value).to eq 'divided by 0'
        expect(error.exception.module).to eq ''

        expect(error.stacktrace.frames.length).to_not be 0
        expect(error.stacktrace.frames.map(&:class).uniq)
          .to eq [ErrorMessage::Stacktrace::Frame]
        expect(error.culprit).to eq "opbeat/error_message_spec.rb:9:in `/'"
      end

      it "skips excluded exceptions" do
        class ::SleepDeprivationError < StandardError; end
        exception = SleepDeprivationError.new('so tired')
        config.excluded_exceptions += %w{SleepDeprivationError}

        error = ErrorMessage.from_exception config, exception
        expect(error).to be_nil
      end

      context "with a rack env" do
        it "adds rack env to message" do
          env = Rack::MockRequest.env_for '/'
          error = ErrorMessage.from_exception config, real_exception, rack_env: env

          expect(error.http).to be_a(ErrorMessage::HTTP)
          expect(error.http.url).to eq 'http://example.org/'
        end

        it "uses proper filter options" do
          env = Rack::MockRequest.env_for '/nested/path?foo=bar&password=SECRET'
          error = ErrorMessage.from_exception config, real_exception, rack_env: env
          expect(error.http.query_string).to eq "foo=bar&password=[FILTERED]"
        end

        class DummyController
          def current_user
            Struct.new(:id, :email, :username).new(1, 'john@example.com', 'leroy')
          end
        end

        it "adds user from controller" do
          env = Rack::MockRequest.env_for '/', {
            'action_controller.instance' => DummyController.new
          }
          error = ErrorMessage.from_exception config, real_exception, rack_env: env

          expect(error.user).to be_a(ErrorMessage::User)
          expect(error.user.id).to be 1
        end

        it "adds extra data to message" do
          error = ErrorMessage.from_exception config, real_exception, extra: { "test" => 1 }

          expect(error.extra).to eq("test" => 1)
        end
      end
    end

    describe "#add_extra" do
      it "adds extra info from hash" do
        error_message = ErrorMessage.new config, "Message"
        error_message.add_extra(thing: 1)
        expect(error_message.extra).to eq(thing: 1)
      end
      it "merges with current" do
        error_message = ErrorMessage.new config, "Message"
        error_message.extra = { other_thing: 2 }
        error_message.add_extra(thing: 1)
        expect(error_message.extra).to eq(thing: 1, other_thing: 2)
      end
    end

  end
end
