require "spec_helper"

describe Lita::Adapters::IRC::CinchPlugin do
  subject { described_class.new(cinch) }

  let(:authorization) { instance_double("Lita::Authorization") }
  let(:robot) { double("Lita::Robot", auth: authorization) }
  let(:cinch) { double("Cinch::Bot").as_null_object }
  let(:user) { double("Lita::User", name: "Carl") }
  let(:message) { double("Lita::Message", command!: nil, source: source) }
  let(:source) { double("Lita::Source", room: "#channel", user: user) }
  let(:m) do
    instance_double(
      "Cinch::Message",
      action_message: "foo",
      message: "bar",
      action?: false,
      channel: cinch_channel,
      user: cinch_user
    )
  end
  let(:invite_m) do
    instance_double(
      "Cinch::Message",
      channel: cinch_channel,
      user: cinch_user
    )
  end
  let(:cinch_channel) { instance_double("Cinch::Channel", name: "#lita.io") }
  let(:cinch_user) { instance_double("Cinch::User", nick: "Carl") }

  before do
    allow(subject).to receive(:config).and_return(instance_double("Hash", :[] => robot))
    allow(Lita::Source).to receive(:new).and_return(source)
  end

  describe "#execute" do
    it "dispatches regular messages to the robot" do
      allow(Lita::Message).to receive(:new).with(robot, "bar", source).and_return(message)
      expect(robot).to receive(:receive).with(message)
      subject.execute(m)
    end

    it "dispatches action messages to the robot" do
      allow(m).to receive(:action?).and_return(true)
      allow(Lita::Message).to receive(:new).with(robot, "foo", source).and_return(message)
      expect(robot).to receive(:receive).with(message)
      subject.execute(m)
    end

    it "marks private messages as commands" do
      allow(source).to receive(:room).and_return(nil)
      allow(Lita::Message).to receive(:new).with(robot, "bar", source).and_return(message)
      allow(robot).to receive(:receive)
      expect(message).to receive(:command!)
      subject.execute(m)
    end
  end

  describe "#on_connect" do
    it "triggers a connected event on the robot" do
      expect(robot).to receive(:trigger).with(:connected)
      subject.on_connect(double)
    end
  end

  describe "#on_invite" do
    before do
      allow(authorization).to receive(:user_is_admin?).and_return(false)
    end

    it "joins the room if the invite came from an admin" do
      allow(subject).to receive(:user_by_nick).and_return(user)
      allow(authorization).to receive(:user_is_admin?).with(user).and_return(true)
      expect(invite_m.channel).to receive(:join)
      subject.on_invite(invite_m)
    end

    it "ignores the invite if it didn't come from an admin" do
      expect(invite_m.channel).not_to receive(:join)
      subject.on_invite(invite_m)
    end
  end
end
