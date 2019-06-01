module Haenawa
  module Commands
    class NilCommand < Command
      def render
        ensure_capture
      end

      def validate; end
    end
  end
end
