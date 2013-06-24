require "spec_helper"

describe Lita::Adapters::IRC::CinchPlugin do
  subject { described_class.new(cinch) }

  let(:cinch) { double("Cinch::Bot").as_null_object }
  let(:message) { double("Lita::Message").as_null_object }
  let(:m) do
    double(
      "Cinch::Message",
      action_message: "foo",
      message: "bar",
      action?: false
    ).as_null_object
  end

  before do
    allow(subject).to receive(:config).and_return(
      double("Hash", :[] => robot)
    )
    allow(Lita::Source).to receive(:new).and_return(source)
  end

  describe "#execute" do
    it "dispatches regular messages to the robot" do
      allow(Lita::Message).to receive(:new).with(
        robot,
        "bar",
        source
      ).and_return(message)
      expect(robot).to receive(:receive).with(message)
      subject.execute(m)
    end

    it "dispatches action messages to the robot" do
      allow(m).to receive(:action?).and_return(true)
      allow(Lita::Message).to receive(:new).with(
        robot,
        "foo",
        source
      ).and_return(message)
      expect(robot).to receive(:receive).with(message)
      subject.execute(m)
    end
  end
end
