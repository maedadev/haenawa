module Haenawa
  module Commands
    class SelectFrame < Command
      VALID_TARGET_REGEXP = Regexp.union(/\Aindex=(\d+)\Z/,
                                         /\Arelative=(parent|top)\Z/)

      def validate
        if target.blank?
          @step.errors.add(:target, :missing)
        elsif (VALID_TARGET_REGEXP =~ target.strip).nil?
          @step.errors.add(:target, :invalid)
        end
      end

      def render
        partial = nil
        case target
        when /\Aindex=/
          partial = switch_to_frame_by_index(Regexp.last_match.post_match.to_i)
        when /\Arelative=/
          partial = switch_to_frame_by_relative(Regexp.last_match.post_match.to_sym)
        end
        if !partial
          return render_unsupported_target
        end

        ensure_capture { partial }
      end

      private

      SUPPORTED_FRAME_SYMBOL_NAMES = %i[parent top]

      def switch_to_frame_by_index(index)
        [
          'assert has_selector?("iframe")',
          'iframes = all(:css, "iframe")',
          "switch_to_frame(iframes[#{index}])",
        ]
      end

      def switch_to_frame_by_relative(frame)
        if !SUPPORTED_FRAME_SYMBOL_NAMES.include?(frame)
          return nil
        end

        [
          "switch_to_frame(:#{frame})",
        ]
      end
    end
  end
end
