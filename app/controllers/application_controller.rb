class ApplicationController < ActionController::Base
  include H1Rails
  
  # Ensure all controllers use English by default (ActiveAdmin, etc.)
  before_action :set_default_locale
  
  private
  
  def set_default_locale
    if self.kind_of? ActiveAdmin::BaseController
      I18n.locale = :en
    elsif params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)
      I18n.locale = params[:locale]
    end
  end
end