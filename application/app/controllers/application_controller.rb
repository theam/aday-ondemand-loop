class ApplicationController < ActionController::Base
  include RedirectBackWithAnchor

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :load_user_settings
  before_action :set_redirect_params
  after_action :stash_redirect_params

  def ajax_request?
    request.xhr? || request.headers['X-Requested-With'] == 'XMLHttpRequest'
  end

  private

  def load_user_settings
    Current.settings = UserSettings.new
    @active_project = Project.find(Current.settings.user_settings.active_project.to_s)
  end

  def set_redirect_params
    Current::PERSISTED_ATTRIBUTES.each do |key|
      value = request.request_parameters[key] || params[key] || flash[:redirect_params]&.[](key.to_s)
      next if value.nil?

      Current.public_send("#{key}=", value)
    end
  end

  def stash_redirect_params
    return unless response.redirect?

    redirect_params = params.permit(*Current::PERSISTED_ATTRIBUTES)
    flash[:redirect_params] = redirect_params.to_h if redirect_params.present?
  end
end
