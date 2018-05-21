class ApplicationNotifier

  include Rails.application.routes.url_helpers

  def dingtalk(access_token, title)
    DingBot.access_token = access_token
    Rails.logger.debug(collect_responses)
    DingBot.send_markdown(title, collect_responses)
  end

  def initialize(method_name)
    @method_name = method_name
  end

  def self.method_missing(method_name, *args, &block)
    self.new(method_name).send(method_name, *args, &block)
  end

  def respond_to_missing?(method, include_all = false)
    action_methods.include?(method.to_s)
  end

  def collect_responses
    render_md(self.class.name.underscore, @method_name)
  end

  def render_md(path, name)
    ERB.new(lookup_md_context(path, name)).result(binding)
  end

  def lookup_md_context(path, name)
    path = File.join(Rails.root, 'app', 'views', path, "#{name}.md.erb")
    if File.exist?(path)
      file = File.open(path)
      data = file.read
      file.close
      data
    else
      raise ActionView::MissingTemplate.new(path, name, path, false, 'notifier')
    end
  end

end