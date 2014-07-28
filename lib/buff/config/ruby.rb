require 'buff/config'

module Buff
  module Config
    class Ruby < Config::Base
      class Evaluator
        class << self
          # Parse the contents of the Ruby file into a Hash.
          #
          # @param [String] contents
          # @param [String] path file that should be used as __FILE__
          #   during eval
          # @param [Object] context the parent Config object
          #
          # @return [Hash]
          def parse(contents, path=nil, context=nil)
            self.new(contents, path, context).send(:attributes)
          end
        end

        # @param [String] contents
        # @param [String] path
        # @param [Object] context
        def initialize(contents, path=nil, context=nil)
          path ||= "(buff-config)"
          @context = context
          @attributes = Hash.new
          instance_eval(contents, path)
        rescue Exception => ex
          raise Errors::InvalidConfig, ex
        end

        # @see {Buff::Config::Ruby.platform_specific_path}
        def platform_specific_path(path)
          Buff::Config::Ruby.platform_specific_path(path)
        end

        private

          attr_reader :attributes

          def method_missing(m, *args, &block)
            if args.size > 0
              attributes[m.to_sym] = (args.length == 1) ? args[0] : args
            elsif @context && @context.respond_to?(m)
              @context.send(m, *args, &block)
            else
              Proxy.new
            end
          end

          class Proxy
            def method_missing(m, *args, &block)
              self
            end
          end
      end

      class << self
        # @param [String] contents
        # @param [String] path
        #
        # @return [Buff::Config::Ruby]
        def from_ruby(contents, path=nil)
          new.from_ruby(contents, path)
        end

        # @param [String] path
        #
        # @raise [Buff::Errors::ConfigNotFound]
        #
        # @return [Buff::Config::Ruby]
        def from_file(path)
          path = File.expand_path(path)
          contents = File.read(path)
          new(path).from_ruby(contents, path)
        rescue TypeError, Errno::ENOENT, Errno::EISDIR
          raise Errors::ConfigNotFound, "No configuration found at: '#{path}'"
        end

        # Converts a path to a path usable for your current platform
        #
        # @param [String] path
        #
        # @return [String]
        def platform_specific_path(path)
          if RUBY_PLATFORM =~ /mswin|mingw|windows/
            system_drive = ENV['SYSTEMDRIVE'] ? ENV['SYSTEMDRIVE'] : ""
            path         = win_slashify File.join(system_drive, path.split('/')[2..-1])
          end

          path
        end

        private

          # Convert a unixy filepath to a windowsy filepath. Swaps forward slashes for
          # double backslashes
          #
          # @param [String] path
          #   filepath to convert
          #
          # @return [String]
          #   converted filepath
          def win_slashify(path)
            path.gsub(File::SEPARATOR, (File::ALT_SEPARATOR || '\\'))
          end
      end

      def initialize(path = nil, options = {})
        super
        from_ruby(File.read(path), path) if path && File.exists?(path)
      end

      # @raise [Buff::Errors::InvalidConfig]
      #
      # @return [Buff::Config::Ruby]
      def from_ruby(contents, path=nil)
        hash = Buff::Config::Ruby::Evaluator.parse(contents, path, self)
        mass_assign(hash)
        self
      end

      # Convert the result to Ruby.
      #
      # @return [String]
      def to_ruby
        self.to_hash.map do |k,v|
          value = if const = find_constant(v)
            const
          else
            v.inspect
          end

          "#{k.to_s}(#{value})"
        end.join("\n")
      end
      alias_method :to_rb, :to_ruby

      def save(destination = self.path)
        if destination.nil?
          raise Errors::ConfigSaveError, "Cannot save configuration without a destination. " +
            "Provide one to save or set one on the object."
        end

        FileUtils.mkdir_p(File.dirname(destination))
        File.open(destination, 'w+') do |f|
          f.write(to_ruby)
        end
      end

      # Reload the current configuration file from disk
      #
      # @return [Buff::Config::Ruby]
      def reload
        mass_assign(self.class.from_file(path).to_hash)
        self
      end

      private

        def find_constant(name)
          Module.constants.find do |const|
            begin
              Module.const_get(const) == name
            rescue NameError; end
          end
        end
    end
  end
end
