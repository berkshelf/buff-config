$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'rspec'
require 'buff/ruby_engine'
require 'json_spec'

def setup_rspec
  RSpec.configure do |config|
    config.include JsonSpec::Helpers

    config.expect_with :rspec do |c|
      c.syntax = :expect
    end

    config.mock_with :rspec
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run focus: true
    config.run_all_when_everything_filtered = true

    config.before(:each) { clean_tmp_path }
  end
end

def app_root
  @app_root ||= Pathname.new(File.expand_path('../../', __FILE__))
end

def clean_tmp_path
  FileUtils.rm_rf(tmp_path)
  FileUtils.mkdir_p(tmp_path)
end

def tmp_path
  app_root.join('spec', 'tmp')
end

if Buff::RubyEngine.jruby?
  require 'buff/config'
  setup_rspec
else
  require 'spork'

  Spork.prefork { setup_rspec }
  Spork.each_run { require 'buff/config' }
end
