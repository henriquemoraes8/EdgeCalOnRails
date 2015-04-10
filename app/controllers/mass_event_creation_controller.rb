class MassEventCreationController < ApplicationController
  def index
    @users = User.where.not(:id => current_user.id)
    @groups = current_user.groups
  end

  def help
  end

  def show
  end

  def process_events

  end
end
