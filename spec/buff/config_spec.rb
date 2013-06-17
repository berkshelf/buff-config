require 'spec_helper'

describe Buff::Config::Base do
  subject { Class.new(described_class).new }

  describe "#to_hash" do
    it "returns a Hash" do
      expect(subject.to_hash).to be_a(Hash)
    end

    it "contains all of the attributes" do
      subject.set_attribute(:something, "value")

      expect(subject.to_hash).to have_key(:something)
      expect(subject.to_hash[:something]).to eql("value")
    end
  end

  describe "#slice" do
    before(:each) do
      subject.set_attribute(:one, nested: "value")
      subject.set_attribute(:two, nested: "other")
      @sliced = subject.slice(:one)
    end

    it "returns a Hash" do
      expect(@sliced).to be_a(Hash)
    end

    it "contains just the sliced elements" do
      expect(@sliced).to have(1).item
    end
  end
end
