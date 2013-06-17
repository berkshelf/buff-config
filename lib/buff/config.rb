require 'buff/extensions'
require 'varia_model'
require 'forwardable'

module Buff
  require_relative 'config/errors'

  module Config
    class Base
      extend Forwardable
      include VariaModel

      attr_accessor :path

      def_delegator :to_hash, :slice
      def_delegator :to_hash, :slice!
      def_delegator :to_hash, :extract!

      # @param [String] path
      # @param [Hash] attributes
      def initialize(path = nil, attributes = {})
        @path = File.expand_path(path) if path

        mass_assign(attributes)
      end

      def to_hash
        super.deep_symbolize_keys
      end
    end
  end
end
