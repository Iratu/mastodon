# frozen_string_literal: true

class Api::V1::Timelines::PublicController < ApiController
  after_action :insert_pagination_headers, unless: -> { @statuses.empty? }

  respond_to :json

  def show
    @statuses = load_statuses
    render 'api/v1/timelines/show'
  end

  private

  def load_statuses
    cached_public_statuses.tap do |statuses|
      set_maps(statuses)
    end
  end

  def cached_public_statuses
    cache_collection public_statuses, Status
  end

  def public_statuses
    public_timeline_statuses.paginate_by_max_id(
      limit_param(DEFAULT_STATUSES_LIMIT),
      params[:max_id],
      params[:since_id]
    )
  end

  def public_timeline_statuses
    Status.as_public_timeline(current_account, params[:local])
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def pagination_params(core_params)
    params.permit(:local, :limit).merge(core_params)
  end

  def next_path
    api_v1_timelines_public_url pagination_params(max_id: pagination_max_id)
  end

  def prev_path
    api_v1_timelines_public_url pagination_params(since_id: pagination_since_id)
  end

  def pagination_max_id
    @statuses.last.id
  end

  def pagination_since_id
    @statuses.first.id
  end
end
