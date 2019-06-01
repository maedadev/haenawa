module Haenawa
  module Commands
    class Type < Command
      def validate
        if target.blank?
          @step.errors.add(:target, :missing)
        elsif !VALID_STRATEGIES.include?(strategy) || locator.blank?
          @step.errors.add(:target, :invalid)
        else
          begin
            interpolated_locator
          rescue I18n::MissingInterpolationArgument
            @step.errors.add(:target, :invalid_placeholder)
          end
        end

        if value.blank?
          @step.errors.add(:value, :missing)
        else
          begin
            interpolated_value
          rescue I18n::MissingInterpolationArgument
            @step.errors.add(:value, :invalid_placeholder)
          end
        end
      end

      def render
        ensure_capture do
          if File.exists?(value) # ファイルアップロードの場合
            "#{find_target}.attach_file(#{value.dump})"
          else # テキスト入力の場合
            "#{find_target}.set(#{interpolated_value.dump})"
          end
        end
      rescue Haenawa::Exceptions::Unsupported::TargetType
        render_unsupported_target
      end
    end
  end
end
