module Haenawa
  module Commands
    def validate; end

    class Close < Command
      def render
        "page.driver.browser.quit"
      end
    end
  end
end
