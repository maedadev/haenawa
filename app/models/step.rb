require 'active_support/core_ext/digest/uuid'

class Step < ActiveRecord::Base
  include ::Encryptor

  belongs_to :steppable, polymorphic: true, inverse_of: 'steps'

  acts_as_list scope: :steppable, column: :step_no

  after_initialize :set_default_values


  # .sideファイルを読み込む段階ではバリデーションをスキップする。
  validates :command, on: :update, :inclusion => { in: Haenawa::Command::COMMAND_NAMES }
  validate(on: :update) { step_command.validate }

  class << self
    def default_attrs
      { command: 'click', target: 'css=body' }
    end
  end

  def targets
    ActiveSupport::JSON.decode(raw_targets)
  end

  def targets=(o)
    self.raw_targets = ActiveSupport::JSON.encode(o)
  end

  def step_command
    @step_command ||= Haenawa::Command.create_from_step(self)
  end

  # .sideファイルの内容へ変換する。
  def to_side_file_content
    {
      id: uuid,
      comment: comment,
      command: command,
      target: target,
      targets: targets,
      value: value,
    }
  end

  def command_names
    # .sideファイルに未対応のコマンドが入っていることはあり得るので
    # COMMAND_NAMESに含まれていないコマンドのステップが生成される可能性がある。
    # この可能性に備えて本ステップのコマンドを戻り値の配列に追加する。
    (Haenawa::Command::COMMAND_NAMES + [command]).uniq
  end

  def should_mask?
    case command
    when 'type'
      target.include?('password')
    else
      false
    end
  end

  def masked_value
    if value.present?
      should_mask? ? '********' : value
    elsif encrypted_value.present?
      '********'
    end
  end

  def encrypt
    if value.present?
      should_mask? ? encrypt_and_sign(value) : value
    end
  end

  def decrypt
    if value.present?
      should_mask? ? decrypt_and_verify(value) : value
    end
  end

  private

  def uuid
    namespace = 'HaenawaStep'
    name = [comment, command, target, raw_targets].join
    Digest::UUID.uuid_v5(namespace, name)
  end

  def set_default_values
    # MySQLのTEXT型にはデフォルト値が付与できないため、
    # モデルでデフォルト値を与える。
    if !target
      self.target = ''
    end
    if !value
      self.value = ''
    end
    if !comment
      self.comment = ''
    end
    if !raw_targets.present?
      self.raw_targets = '[]'
    end
  end
end
