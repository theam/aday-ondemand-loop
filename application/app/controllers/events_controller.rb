class EventsController < ApplicationController
  def index
    project_id = params[:project_id] || params[:id]
    project = Project.find(project_id)
    if project.nil?
      render json: { error: "Project #{project_id} not found" }, status: :not_found
      return
    end

    events = apply_filters(project.events).sort_by(&:creation_date).reverse

    respond_to do |format|
      format.json { render json: events.map(&:to_h) }
      format.html { render partial: 'events/table', locals: { events: events } }
    end
  end

  private

  def apply_filters(events)
    filtered = events

    if params[:type].present?
      begin
        event_type = EventType.get(params[:type])
        filtered = filtered.select { |e| e.type == event_type }
      rescue ArgumentError
        filtered = []
      end
    end

    metadata_filters = params.to_unsafe_h.except(:type, :project_id, :id, :controller, :action, :format)
    metadata_filters.each do |key, value|
      filtered = filtered.select { |e| e.metadata[key.to_s].to_s == value.to_s }
    end

    filtered
  end
end
