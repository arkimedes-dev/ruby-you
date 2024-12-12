require "spec_helper"

RSpec.describe You do
  describe ".configuration" do
    it "initializes a Configuration object" do
      expect(You.configuration).to be_a(You::Configuration)
    end
  end

  describe ".configure" do
    it "yields the configuration object" do
      expect { |b| You.configure(&b) }.to yield_with_args(You.configuration)
    end
  end

  describe ".client" do
    it "initializes a Client object with default parameters" do
      client = You.client
      expect(client).to be_a(You::Client)
      expect(client.api_key).to eq("test_api_key")
      expect(client.max_retries).to eq(3)
      expect(client.initial_wait_time).to eq(1)
    end
  end
end
