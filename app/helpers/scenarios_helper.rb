module ScenariosHelper
  # シナリオ実行用のデバイス
  DEVICES = {
    # デバイスの識別子: デフォルトでチェックを入れるかどうかのフラグ
    ie: false,
    chrome: false,
    headless_chrome: true,
    firefox: false,
    iphone6: false,
    ipad_pro: false,
    android: ENV['SHOW_ANDROID'],
  }.compact.freeze

  # デバイスアイコン用のCSSクラス
  # 当該するアイコンについては https://fontawesome.com/icons を参照。
  ICON_CLASSES = {
    ie: "fab fa-internet-explorer",
    chrome: "fab fa-chrome",
    headless_chrome: "fab fa-chrome",
    firefox: "fab fa-firefox",
    iphone6: "fas fa-mobile-alt",
    ipad_pro: "fas fa-tablet-alt",
    android: "fab fa-android",
  }.freeze

  def devices
    DEVICES
  end

  def device_title(device)
    I18n.t(device, scope: 'views.scenarios.show.device.select')
  end

  def device_icon(device)
    content_tag(:span, nil, class: ICON_CLASSES[device.to_sym], title: device_title(device))
  end

  # 特定のデバイス上の特定ステップの実行結果（成功、失敗、未実施）を表すアイコンを返す。
  def latest_build_result_icon(scenario, device, step)
    if scenario.latest_build_stale?
      return '' # ビルドのステップ情報がシナリオの状態から乖離した場合。
    end

    branch = scenario.latest_build_branch(device) # BuildHistory

    if branch.nil?
      return '' # まだビルドしたことが無い場合。
    end

    step_status = branch.step_status(step.step_no)&.to_sym

    # ブランチの結果での判定
    if branch.pending?
      css_class = 'fas fa-hourglass-half'
    elsif branch.passed?
      css_class = 'fas fa-check' # ブランチの成功 == 全てのステップの成功
    else
      # ステップの結果で判定
      css_class = {
        passed: 'fas fa-check',
        failed: 'fas fa-times',
        skipped: 'fas fa-minus'
      }[step_status]
    end

    if [:passed, :failed].include?(step_status)
      link_to build_history_path(branch, anchor: "step_no=#{step.step_no}") do
        content_tag(:span, nil, class: css_class)
      end
    else
      content_tag(:span, nil, class: css_class)
    end
  end

  def progress_indicator_image(url)
    opts = {
      class: 'loading',
      # data-urlはhaenawa.ProgressUpdaterの進捗更新処理で使う。
      data: {
        url: url
      }
    }
    image_tag('loading.gif', opts)
  end
end
