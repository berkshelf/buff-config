module Buff
  module Errors
    class ConfigNotFound < StandardError; end
    class InvalidConfig < StandardError; end
    class ConfigSaveError < StandardError; end
  end
end
