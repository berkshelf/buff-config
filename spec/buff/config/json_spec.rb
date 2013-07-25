require 'spec_helper'
require 'buff/config/json'

describe Buff::Config::JSON do
  let(:json) do
    %(
      {
        "name": "reset",
        "job": "programmer",
        "status": "awesome"
      }
    )
  end

  describe "ClassMethods" do
    subject do
      Class.new(Buff::Config::JSON) do
        attribute :name, required: true
        attribute :job
      end
    end

    describe "::from_hash" do
      let(:hash) { JSON.parse(json) }

      it "returns an instance of the inheriting class" do
        expect(subject.from_hash(hash)).to be_a(subject)
      end
    end

    describe "::from_json" do
      it "returns an instance of the inheriting class" do
        expect(subject.from_json(json)).to be_a(subject)
      end

      it "assigns values for each defined attribute" do
        config = subject.from_json(json)

        expect(config[:name]).to eql("reset")
        expect(config[:job]).to eql("programmer")
      end
    end

    describe "::from_file" do
      let(:file) { tmp_path.join("test_config.json").to_s }

      before(:each) do
        File.open(file, "w") { |f| f.write(json) }
      end

      it "returns an instance of the inheriting class" do
        expect(subject.from_file(file)).to be_a(subject)
      end

      it "sets the object's filepath to the path of the loaded file" do
        expect(subject.from_file(file).path).to eql(file)
      end

      context "given a file that does not exist" do
        it "raises a Buff::Errors::ConfigNotFound error" do
          expect { subject.from_file(tmp_path.join("asdf.txt")) }.to raise_error(Buff::Errors::ConfigNotFound)
        end
      end
    end
  end

  subject do
    Class.new(Buff::Config::JSON) do
      attribute :name, required: true
      attribute :job
    end.new
  end

  describe "#to_json" do
    before(:each) do
      subject.name = "reset"
      subject.job = "programmer"
    end

    it "returns JSON with key values for each attribute" do
      hash = parse_json(subject.to_json)

      expect(hash).to have_key("name")
      expect(hash["name"]).to eql("reset")
      expect(hash).to have_key("job")
      expect(hash["job"]).to eql("programmer")
    end
  end

  describe "#from_json" do
    it "returns an instance of the updated class" do
      expect(subject.from_json(json)).to be_a(Buff::Config::JSON)
    end

    it "assigns values for each defined attribute" do
      config = subject.from_json(json)

      expect(config.name).to eql("reset")
      expect(config.job).to eql("programmer")
    end
  end

  describe "#save" do
    it "raises a ConfigSaveError if no path is set or given" do
      subject.path = nil

      expect { subject.save }.to raise_error(Buff::Errors::ConfigSaveError)
    end
  end

  describe "#reload" do
    before(:each) do
      subject.path = tmp_path.join('tmpconfig.json').to_s
      subject.save
    end

    it "returns self" do
      expect(subject.reload).to eql(subject)
    end

    it "updates the contents of self from disk" do
      original = subject.class.from_file(subject.path)
      subject.job = "programmer"
      subject.save

      expect(original.job).to be_nil
      original.reload
      expect(original.job).to eql("programmer")
    end

    it "raises ConfigNotFound if the path is nil" do
      subject.path = nil

      expect { subject.reload }.to raise_error(Buff::Errors::ConfigNotFound)
    end
  end
end
