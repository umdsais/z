# controllers/groups_controller.rb
class Admin::GroupsController < ApplicationController
  # before_action :set_group, only: [:show, :edit, :update, :destroy]
  before_action :ensure_is_admin

  def index
    @groups = Group.not_default
  end
end
