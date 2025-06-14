class Zenodo::LandingPageController < ApplicationController
  def index
    @query = params[:q]
    @page = params[:page] ? params[:page].to_i : 1
    if @query.present?
      service = Zenodo::RecordService.new
      @results = service.search_records(@query, page: @page, per_page: 10)
    end
  rescue => e
    Rails.logger.error("Zenodo search error: #{e}")
    flash[:alert] = t('.zenodo_service_error')
    redirect_to root_path
  end
end
