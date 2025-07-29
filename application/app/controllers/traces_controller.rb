class TracesController < ApplicationController
  def index
    entity_type = params[:entity_type]
    ids = extract_ids(entity_type, params)
    traces = Trace.all(entity_type, ids)
    render json: traces.map(&:to_h)
  rescue ArgumentError => e
    render json: { error: e.message }, status: :bad_request
  end

  def show
    entity_type = params[:entity_type]
    ids = extract_ids(entity_type, params)
    trace = Trace.find(entity_type, ids, params[:id])
    if trace
      render json: trace.to_h
    else
      head :not_found
    end
  rescue ArgumentError => e
    render json: { error: e.message }, status: :bad_request
  end

  def create
    entity_type = params[:entity_type]
    ids = extract_ids(entity_type, params)
    trace = Trace.add(entity_type: entity_type, entity_ids: ids, message: params[:message])
    if trace
      render json: trace.to_h, status: :created
    else
      render json: { error: 'invalid trace' }, status: :unprocessable_entity
    end
  rescue ArgumentError => e
    render json: { error: e.message }, status: :bad_request
  end

  private

  def extract_ids(entity_type, params)
    case entity_type
    when 'project'
      [params[:project_id] || params[:id]]
    when 'download_file'
      [params[:project_id], params[:download_file_id] || params[:file_id]]
    when 'upload_bundle'
      [params[:project_id], params[:upload_bundle_id] || params[:id]]
    when 'upload_file'
      [params[:project_id], params[:upload_bundle_id], params[:upload_file_id] || params[:id]]
    else
      raise ArgumentError, 'Invalid entity_type'
    end.compact
  end
end
