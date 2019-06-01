module Haenawa
  module Commands
    class Window < Command
      def validate; end

      def render
        ensure_capture do
          <<-EOF
last_handle = page.driver.browser.window_handles.last
page.driver.browser.switch_to.window(last_handle)
          EOF
        end
      end
    end
  end
end
