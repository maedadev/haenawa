haenawa.ProgressUpdater = function(selector) {
  this.selector = selector;
  var that = this;
  $(document).ready(function() {
    that.init();
  });
};

haenawa.ProgressUpdater.prototype.init = function() {
  var progressIndicators = $(this.selector).find('.loading');
  if (progressIndicators.length === 0) {
    return;
  }

  var that = this;

  // Kaminariのページネーションリンクがクリックされた場合は進捗更新を中止する。
  $(document).one('click', '.pagination a', function() {
    that.cancel();
  });

  this.timeoutId = setTimeout(function() {
    that.request = $.get(progressIndicators.first().data('url'));
  }, 2000);
};

haenawa.ProgressUpdater.prototype.cancel = function() {
  if (this.timeoutId) {
    clearTimeout(this.timeoutId);
  }
  if (this.request) {
    this.request.abort();
  }
};
