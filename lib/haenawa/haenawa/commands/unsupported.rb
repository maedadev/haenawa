module Haenawa
  module Commands
    class Unsupported < Command
      def validate; end

      def render
        message = "サポートしていないコマンドです。| #{command} | #{target} | #{value} |"
        append_partial("raise \"#{escape_ruby(message)}\"")
      end
    end
  end
end
