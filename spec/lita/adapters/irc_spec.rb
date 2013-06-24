require "spec_helper"

describe Lita::Adapters::IRC do
  subject { described_class.new(robot) }

  before do
    Lita.config.adapter.server = "irc.example.com"
    Lita.config.adapter.channels = "#lita"
    Lita.config.adapter.user = "litabot"
    Lita.config.adapter.password = "secret"
    Lita.config.adapter.realname = "Lita the Robot"
    Lita.config.adapter.nick = "NotLita"
    Lita.config.adapter.max_reconnect_delay = 123
  end

  it "registers with Lita" do
    expect(Lita.adapters[:irc]).to eql(described_class)
  end

  it "requires a server and channels" do
    Lita.instance_variable_set(:@config, nil)
    expect(Lita.logger).to receive(:fatal).with(/server, channels/)
    expect { subject }.to raise_error(SystemExit)
  end

  it "configures Cinch" do
    subject.cinch.config.tap do |config|
      expect(config.nick).to eq("Lita")
      expect(config.server).to eq("irc.example.com")
      expect(config.channels).to eq(["#lita"])
      expect(config.user).to eq("litabot")
      expect(config.password).to eq("secret")
      expect(config.realname).to eq("Lita the Robot")
      expect(config.max_reconnect_delay).to eq(123)
    end
  end

  it "registers a plugin with Cinch" do
    expect(subject.cinch.config.plugins.plugins).to include(
      described_class::CinchPlugin
    )
  end

  it "turns Cinch's logging on if config.adapter.log_level is set" do
    Lita.config.adapter.log_level = :debug
    expect(subject.cinch.loggers).not_to be_empty
  end

  describe "#run" do
    it "connects to IRC" do
      expect(subject.cinch).to receive(:start)
      subject.run
    end
  end

  describe "#shut_down" do
    it "disconnects from IRC" do
      expect(subject.cinch).to receive(:quit)
      subject.shut_down
    end
  end
end
