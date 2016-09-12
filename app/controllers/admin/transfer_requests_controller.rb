class Admin::TransferRequestsController < ApplicationController
  before_action :set_admin_view
  def new
    @transfer_request = TransferRequest.new

    @urls = Url
            .where(keyword: params[:keywords])
            .order('created_at DESC')

    @transfer_request.urls = @urls

    respond_to do |format|
      format.html
      format.js { render 'transfer_requests/new', layout: false }
    end
  end

  def create
    @transfer_request = TransferRequest.new(
      from_group_id: current_user.context_group_id
    )

    @transfer_request.to_group_id =
      User.find_or_create_by(
        uid: params['transfer_request']['to_group']
      ).default_group_id

    @urls = Url
            .where(keyword: params[:keywords])
            .order('created_at DESC')

    @transfer_request.urls = @urls

    respond_to do |format|
      if @transfer_request.save && @transfer_request.approve!
        format.js do
          redirect_to admin_urls_path
        end
      else
        format.js { render 'transfer_requests/new', layout: false }
      end
    end
  end
end
