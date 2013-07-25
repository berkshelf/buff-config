require 'json'
require 'buff/config'

module Buff
  module Config
    class JSON < Config::Base
      class << self
        # @param [String] data
        #
        # @return [Buff::Config::JSON]
        def from_json(data)
          new.from_json(data)
        end

        # @param [Hash] hash
        #
        # @return [Buff::Config::JSON]
        def from_hash(hash)
          new.from_hash(hash)
        end

        # @param [String] path
        #
        # @raise [Buff::Errors::ConfigNotFound]
        #
        # @return [Buff::Config::JSON]
        def from_file(path)
          path = File.expand_path(path)
          data = File.read(path)
          new(path).from_json(data)
        rescue TypeError, Errno::ENOENT, Errno::EISDIR
          raise Errors::ConfigNotFound, "No configuration found at: '#{path}'"
        end
      end

      # @see {VariaModel#from_json}
      #
      # @raise [Buff::Errors::InvalidConfig]
      #
      # @return [Buff::Config::JSON]
      def from_json(*args)
        super
      rescue ::JSON::ParserError => ex
        raise Errors::InvalidConfig, ex
      end

      def save(destination = self.path)
        if destination.nil?
          raise Errors::ConfigSaveError, "Cannot save configuration without a destination. Provide one to save or set one on the object."
        end

        FileUtils.mkdir_p(File.dirname(destination))
        File.open(destination, 'w+') do |f|
          f.write(::JSON.pretty_generate(self.to_hash))
        end
      end

      # Reload the current configuration file from disk
      #
      # @return [Buff::Config::JSON]
      def reload
        mass_assign(self.class.from_file(path).to_hash)
        self
      end
    end
  end
end
