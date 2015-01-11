require "spec_helper"

describe Lita::Adapters::IRC, lita: true do
  let(:robot) { Lita::Robot.new(registry) }

  subject { described_class.new(robot) }

  before do
    registry.register_adapter(:irc, described_class)

    registry.configure do |config|
      config.adapters.irc.server = "irc.example.com"
      config.adapters.irc.channels = "#lita"
      config.adapters.irc.user = "litabot"
      config.adapters.irc.password = "secret"
      config.adapters.irc.realname = "Lita the Robot"
      config.adapters.irc.cinch = lambda do |c|
        c.nick = "NotLita"
        c.sasl.username = "sasl username"
      end
    end
  end

  it "registers with Lita" do
    expect(Lita.adapters[:irc]).to eql(described_class)
  end

  it "configures Cinch" do
    subject.cinch.config.tap do |config|
      expect(config.nick).to eq("Lita")
      expect(config.server).to eq("irc.example.com")
      expect(config.channels).to eq(["#lita"])
      expect(config.user).to eq("litabot")
      expect(config.password).to eq("secret")
      expect(config.realname).to eq("Lita the Robot")
      expect(config.sasl.username).to eq("sasl username")
    end
  end

  it "registers a plugin with Cinch" do
    expect(subject.cinch.config.plugins.plugins).to include(described_class::CinchPlugin)
  end

  it "turns Cinch's logging on if config.adapter.log_level is set" do
    registry.config.adapters.irc.log_level = :debug
    expect(subject.cinch.loggers).not_to be_empty
  end

  describe "#join" do
    it "joins a channel" do
      expect(subject.cinch).to receive(:join).with("#lita.io")
      subject.join("#lita.io")
    end
  end

  describe "#part" do
    it "parts from a channel" do
      expect(subject.cinch).to receive(:part).with("#lita.io")
      subject.part("#lita.io")
    end
  end

  describe "#run" do
    it "connects to IRC" do
      expect(subject.cinch).to receive(:start)
      subject.run
    end
  end

  describe "#send_messages" do
    it "sends messages to rooms" do
      source = instance_double("Lita::Source", room: "#foo", private_message?: false)
      channel = instance_double("Cinch::Channel")
      allow(Cinch::Channel).to receive(:new).with("#foo", subject.cinch).and_return(channel)
      expect(channel).to receive(:send).with("Hello!")
      expect(channel).to receive(:send).with("How are you?")
      subject.send_messages(source, ["Hello!", "How are you?"])
    end

    it "sends actions to rooms" do
      source = instance_double("Lita::Source", room: "#foo", private_message?: false)
      channel = instance_double("Cinch::Channel")
      allow(Cinch::Channel).to receive(:new).with("#foo", subject.cinch).and_return(channel)
      expect(channel).to receive(:action).with("greets you")
      subject.send_messages(source, ["/me greets you"])
    end

    it "sends messages to users" do
      user = instance_double("Lita::User", name: "Carl")
      source = instance_double("Lita::Source", user: user, private_message?: true)
      user = instance_double("Cinch::User")
      allow(Cinch::User).to receive(:new).with("Carl", subject.cinch).and_return(user)
      expect(user).to receive(:send).with("Hello!")
      expect(user).to receive(:send).with("How are you?")
      subject.send_messages(source, ["Hello!", "How are you?"])
    end

    it "sends actions to users" do
      user = instance_double("Lita::User", name: "Carl")
      source = instance_double("Lita::Source", user: user, private_message?: true)
      user = instance_double("Cinch::User")
      allow(Cinch::User).to receive(:new).with("Carl", subject.cinch).and_return(user)
      expect(user).to receive(:action).with("greets you")
      subject.send_messages(source, ["/me greets you"])
    end
  end

  describe "#set_topic" do
    it "sets a new topic for the room" do
      source = instance_double("Lita::Source", room: "#foo")
      channel = instance_double("Cinch::Channel")
      expect(Cinch::Channel).to receive(:new).with("#foo", subject.cinch).and_return(channel)
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
