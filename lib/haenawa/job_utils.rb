require 'cron_validator'

class JobUtils

  def self.add_job(klass, *args, &block)
    add_job_to(nil, klass, *args, &block)
  end

  def self.add_job_to(queue, klass, *args)
    if Rails.env.test?
      if klass.respond_to?(:before_enqueue)
        return unless klass.before_enqueue(*args)
      end

      Rails.logger.info "テスト時にはジョブの登録を行わず、即時実行します。"
      klass.perform(*args)
      return
    end

    if block_given?
      yield
    else
      if queue
        Rails.logger.info "ジョブ #{klass} を #{queue} に登録します。"
      else
        Rails.logger.info "ジョブ #{klass} を登録します。"
      end
    end

    if queue.present?
      Resque.enqueue_to(queue, klass, *args)
    else
      Resque.enqueue(klass, *args)
    end
  end

  def self.add_job_silently(klass, *args)
    add_job(klass, *args) do
      # 何も出力しない
    end
  end

  def self.add_job_silently_to(queue, klass, *args)
    add_job_to(queue, klass, *args) do
      # 何も出力しない
    end
  end

  def self.set_job_at(time, klass, *args)
    if Rails.env.test?
      if klass.respond_to?(:before_enqueue)
        return unless klass.before_enqueue(*args)
      end

      Rails.logger.info "テスト時には遅延ジョブの登録を行わず、即時実行します。"
      klass.perform(*args)
      return
    end

    if block_given?
      yield
    else
      Rails.logger.info "遅延ジョブ #{klass} を登録します。"
    end

    Resque.enqueue_at(time, klass, *args)
  end

  def self.set_job_silently_at(time, klass, *args)
    set_job_at(time, klass, *args) do
      # 何も出力しない
    end
  end

  def self.cancel_job_at(klass, *args)
    if Rails.env.test?
      Rails.logger.info "テスト時には遅延ジョブのキャンセルを行いません。"
      return
    end

    Resque.remove_delayed(klass, *args)
  end

  def self.add_cron(name, job_type, cron, *args)
    if Rails.env.test?
      Rails.logger.info 'テスト時にはCronの設定を行いません。'
      return
    end

    Resque.remove_schedule(name)

    if cron.to_s.strip.empty?
      return
    elsif CronValidator.new(cron).valid?
      config = {
        :class => job_type,
        :cron => cron,
        :args => args,
        :persist => true,
        :first_at => Time.now,
      }
      Resque.set_schedule(name, config)
    else
      raise ArgumentError, "Cronの書式が正しくないのでスケジューリングしません。name=#{name}"
    end
  end

  def self.add_cron_to(queue, name, job_type, cron, *args)
    if Rails.env.test?
      Rails.logger.info 'テスト時にはCronの設定を行いません。'
      return
    end

    Resque.remove_schedule(name)

    if cron.to_s.strip.empty?
      return
    elsif CronValidator.new(cron).valid?
      config = {
        :queue => queue,
        :class => job_type,
        :cron => cron,
        :args => args,
        :persist => true,
        :first_at => Time.now,
      }
      Resque.set_schedule(name, config)
    else
      raise ArgumentError, "Cronの書式が正しくないのでスケジューリングしません。name=#{name}"
    end
  end

  def self.remove_cron(name)
    remove_scheduler(name)
  end

  def self.add_scheduler(name, job_type, interval_args, *args)
    if Rails.env.test?
      Rails.logger.info 'テスト時にはCronの設定を行いません。'
      return
    end

    Resque.remove_schedule(name)
    
    if interval_args[:cron].present?
      add_cron(name, job_type, interval_args[:cron], args)
    elsif interval_args[:every].present?
      config = {
        :class => job_type,
        :every => interval_args[:every],
        :args => args,
        :persist => true,
        :first_at => Time.now,
      }
      Resque.set_schedule(name, config)
    else
      raise ArgumentError, "cronもしくはeveryが指定されていないのでスケジューリングしません。name=#{name}"
    end
  end

  def self.remove_scheduler(name)
    if Rails.env.test?
      Rails.logger.info 'テスト時にはCronの設定を行いません。'
      return
    end

    Resque.remove_schedule(name)
  end

  def self.peek(queue, start = 0, count = 1)
    if Rails.env.test?
      Rails.logger.info 'テスト時は、ジョブ 0 件とします。'
      return []
    end

    Resque.peek(queue, start, count)
  end
  
  def self.enqueue_in(time_to_delay, klass, *args)
    if Rails.env.test?
      Rails.logger.info 'テスト時にジョブの遅延実行は行いません。'
      return
    end

    Resque.enqueue_in(time_to_delay, klass, *args)
  end

  def self.dequeue(klass, *args)
    if Rails.env.test?
      Rails.logger.info 'テスト時にジョブの削除は行いません。'
      return
    end

    Resque.dequeue(klass, *args)
  end

  def self.any_jobs_for?(queue)
    ret = Resque.size(queue)
    ret += Resque.working.reduce(0){|sum, worker| sum += worker.queues.include?(queue) ? 1 : 0 }
    ret > 0
  end

  def self.remove_queue(queue)
    if Rails.env.test?
      Rails.logger.info 'テスト時にキューの削除は行いません。'
      return
    end

    Resque.remove_queue(queue)
  end

end
