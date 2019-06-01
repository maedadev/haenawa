module Haenawa
  module SeleniumScriptParser
    class V2
      def self.processable?(file)
        !!(/\.side\z/ =~ file.path)
      end

      def initialize(file)
        @parsed = ActiveSupport::JSON.decode(File.read(file.path))
      rescue
        @parsed = {}
      end

      def base_url
        @parsed['url']
      end

      def each_step
        @parsed['tests'][0]['commands'].each do |c|
          yield(c.symbolize_keys.slice(:comment, :command, :target, :value, :targets))
        end
      end
    end
  end
end
