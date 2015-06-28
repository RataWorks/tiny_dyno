require "spec_helper"

describe TinyDyno::Loggable do

  describe "#logger=" do

    let(:logger) do
      Logger.new($stdout).tap do |log|
        log.level = Logger::INFO
      end
    end

    before do
      TinyDyno.logger = logger
    end

    it "sets the logger" do
      expect(TinyDyno.logger).to eq(logger)
    end
  end
end
