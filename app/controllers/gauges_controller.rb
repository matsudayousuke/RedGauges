class GaugesController < ApplicationController
  unloadable


  def index
    @project = Project.find(params[:project_id])
    @members = User.with_this_week_issues()
  end
end
