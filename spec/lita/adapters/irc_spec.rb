require "spec_helper"

describe Lita::Adapters::IRC, lita: true do
  let(:robot) { double("Lita::Robot") }

  subject { described_class.new(robot) }

  before do
    Lita.configure do |config|
      config.adapter.server = "irc.example.com"
      config.adapter.channels = "#lita"
      config.adapter.user = "litabot"
      config.adapter.password = "secret"
      config.adapter.realname = "Lita the Robot"
      config.adapter.nick = "NotLita"
      config.adapter.max_reconnect_delay = 123
    end
  end

  it "registers with Lita" do
    expect(Lita.adapters[:irc]).to eql(described_class)
  end

  it "requires a server and channels" do
    Lita.clear_config
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

  describe "#send_messages" do
    it "sends messages to rooms" do
      source = double("Lita::Source", room: "#foo")
      channel = double("Cinch::Channel")
      allow(Cinch::Channel).to receive(:new).with(
        "#foo",
        subject.cinch
      ).and_return(channel)
      expect(channel).to receive(:msg).with("Hello!")
      expect(channel).to receive(:msg).with("How are you?")
      subject.send_messages(source, ["Hello!", "How are you?"])
    end

    it "sends messages to users" do
      user = double("Lita::User", name: "Carl")
      source = double("Lita::Source", room: nil, user: user)
      user = double("Cinch::User")
      allow(Cinch::User).to receive(:new).with(
        "Carl",
        subject.cinch
      ).and_return(user)
      expect(user).to receive(:msg).with("Hello!")
      expect(user).to receive(:msg).with("How are you?")
      subject.send_messages(source, ["Hello!", "How are you?"])
    end
  end

  describe "#set_topic" do
    it "sets a new topic for the room" do
      source = double("Lita::Source", room: "#foo")
      channel = double("Cinch::Channel")
      expect(Cinch::Channel).to receive(:new).with(
        "#foo",
        subject.cinch
      ).and_return(channel)
      expect(channel).to receive(:topic=).with("Topic")
      subject.set_topic(source, "Topic")
    end
  end

  describe "#shut_down" do
    it "disconnects from IRC" do
      expect(subject.cinch).to receive(:quit)
      expect(robot).to receive(:trigger).with(:disconnected)
      subject.shut_down
    end
  end
end
