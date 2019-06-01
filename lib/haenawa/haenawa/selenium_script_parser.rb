module Haenawa
  module SeleniumScriptParser
    mattr_accessor :parsers
    self.parsers = [V2, V1]

    def self.run(file)
      parsers.each do |parser|
        if parser.processable?(file)
          return parser.new(file)
        end
      end
      nil # どれも処理できなかったとき
    end
  end
end
