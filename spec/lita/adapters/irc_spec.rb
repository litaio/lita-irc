require "spec_helper"

describe Lita::Adapters::IRC do
  it "registers with Lita" do
    expect(Lita.adapters[:irc]).to eql(described_class)
  end
end
