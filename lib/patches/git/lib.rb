module Patches
  module Git
    module Lib
      def initialize(*args)
        super
        @logger = Rails.logger
      end
    end
  end
end

# ::Git::Lib.prepend(Patches::Git::Lib)