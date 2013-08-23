require 'spec_helper'
require 'buff/config/ruby'

describe Buff::Config::Ruby do
  let(:ruby) do
    %(
      current_dir = File.dirname(__FILE__)
      log_level       :info
      log_location    STDOUT
      cookbook_path   ['cookbooks']
      knife[:foo] = 'bar'
      knife[:key] = "\#{current_dir}/key.pem"
    )
  end

  let(:klass) do
    Class.new(Buff::Config::Ruby) do
      attribute :log_level
      attribute :log_location
      attribute :node_name, default: 'bacon'
      attribute :cookbook_path
      attribute :knife, default: {}
    end
  end

  describe 'ClassMethods' do
    subject { klass }

    describe '.from_ruby' do
      it 'returns an instance of the inheriting class' do
        expect(subject.from_ruby(ruby)).to be_a(subject)
      end

      it 'assigns values for each defined attribute' do
        config = subject.from_ruby(ruby)

        expect(config[:log_level]).to eq(:info)
        expect(config[:log_location]).to eq(STDOUT)
        expect(config[:node_name]).to eq('bacon')
        expect(config[:cookbook_path]).to eq(['cookbooks'])
        expect(config[:knife][:foo]).to eq('bar')
      end

      it 'properly sets the calling file' do
        config = subject.from_ruby(ruby, '/home/annie/.chef/knife.rb')

        expect(config[:knife][:key]).to eq ('/home/annie/.chef/key.pem')
      end
    end

    describe '::from_file' do
      let(:filepath) { tmp_path.join('test_config.rb').to_s }

      before { File.stub(:read).with(filepath).and_return(ruby) }

      it 'returns an instance of the inheriting class' do
        expect(subject.from_file(filepath)).to be_a(subject)
      end

      it 'sets the object\'s filepath to the path of the loaded filepath' do
        expect(subject.from_file(filepath).path).to eq(filepath)
      end

      context 'given a filepath that does not exist' do
        before { File.stub(:read).and_raise(Errno::ENOENT) }

        it 'raises a Buff::Errors::ConfigNotFound error' do
          expect {
            subject.from_file(filepath)
          }.to raise_error(Buff::Errors::ConfigNotFound)
        end
      end
    end
  end

  subject { klass.new }

  describe '#to_rb' do
    it 'returns ruby with key values for each attribute' do
      subject.log_level = :info
      subject.log_location = STDOUT
      subject.node_name = 'bacon'
      subject.cookbook_path = ['cookbooks']

      lines = subject.to_ruby.strip.split("\n")

      expect(lines[0]).to eq('log_level(:info)')
      expect(lines[1]).to eq('log_location(STDOUT)')
      expect(lines[2]).to eq('node_name("bacon")')
      expect(lines[3]).to eq('cookbook_path(["cookbooks"])')
    end
  end

  describe '#from_ruby' do
    it 'returns an instance of the updated class' do
      expect(subject.from_ruby(ruby)).to be_a(Buff::Config::Ruby)
    end

    it 'assigns values for each defined attribute' do
      config = subject.from_ruby(ruby)

      expect(config[:log_level]).to eq(:info)
      expect(config[:log_location]).to eq(STDOUT)
      expect(config[:node_name]).to eq('bacon')
      expect(config[:cookbook_path]).to eq(['cookbooks'])
    end
  end

  describe '#save' do
    it 'raises a ConfigSaveError if no path is set or given' do
      subject.path = nil
      expect {
        subject.save
      }.to raise_error(Buff::Errors::ConfigSaveError)
    end
  end

  describe '#reload' do
    before do
      subject.path = 'foo/bar.rb'
      File.stub(:read).and_return(ruby)
    end

    it 'returns self' do
      expect(subject.reload).to eq(subject)
    end

    it 'updates the contents of self from disk' do
      subject.log_level = :warn
      subject.node_name = 'eggs'

      expect(subject.log_level).to eq(:warn)
      expect(subject.node_name).to eq('eggs')

      subject.reload

      expect(subject.log_level).to eq(:info)
      expect(subject.node_name).to eq('bacon')
    end

    it 'raises ConfigNotFound if the path is nil' do
      subject.path = nil
      expect {
        subject.reload
      }.to raise_error(Buff::Errors::ConfigNotFound)
    end
  end
end
