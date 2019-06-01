module Haenawa
  module SeleniumScriptParser
    class V1
      def self.processable?(file)
        "text/html" == file.content_type
      end

      def initialize(file)
        @html = Nokogiri::XML(File.read(file.path))
      end

      def base_url
        @html.css('link[rel="selenium.base"]').first['href']
      end

      def each_step
        @html.css('table tbody tr').each do |tr|
          data = 3.times.map {|i| tr.css('td')[i].text.strip }
          # V1仕様のファイルではtargetsに相当する要素がない
          yield(command: data[0], target: data[1], value: data[2], targets: [])
        end
      end
    end
  end
end
