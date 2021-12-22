# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Pundit

  before_action :check_rack_mini_profiler

  protected

  def authenticate_user!
    return if logged_in?

    flash[:error] = 'You must be logged in to do that.'
    redirect_to root_path
  end

  def authorize_admin!
    redirect_to dashboard_path unless current_user.admin?
  end

  helper_method :current_user
  def current_user
    @current_user ||= User.includes(:alliance).find(session[:current_user_id]) if session[:current_user_id].present?
  end

  helper_method :logged_in?
  def logged_in?
    current_user.present?
  end

  helper_method :main_alliance
  def main_alliance
    @main_alliance ||= Alliance.find(main_alliance_id)
  end

  helper_method :main_alliance_logo_url
  def main_alliance_logo_url
    @main_alliance_logo_url ||= "https://images.evetech.net/alliances/#{main_alliance_id}/logo?size=128"
  end

  helper_method :main_alliance_id
  def main_alliance_id
    app_config.main_alliance_id
  end

  helper_method :main_market_id
  def main_market_id
    main_alliance.main_market_id
  end

  helper_method :main_market
  def main_market
    main_alliance.main_market
  end

  helper_method :app_config
  def app_config
    Rails.application.config.x.app
  end

  helper_method :current_alliance
  def current_alliance
    current_user.alliance
  end

  def append_info_to_payload(payload)
    super

    payload[:host] = request.host
    payload[:x_forwarded_for] = request.env['HTTP_X_FORWARDED_FOR']
  end

  def check_rack_mini_profiler
    if params[:rmp] && current_user&.admin?
      Rack::MiniProfiler.authorize_request
    end
  end
end
