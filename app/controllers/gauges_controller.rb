
class GaugesController < ApplicationController
  unloadable
  helper :sort
  include SortHelper
  helper :queries
  include QueriesHelper
  helper :issues
  include IssuesHelper

  def index
    @project = Project.find(params[:project_id])
    @base_date = Date.today
    @members = User.with_week_issues(@base_date)
    retrieve_query
    sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    if @query.valid?
      @issues = @query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
        :order => sort_clause)
    end
  end

  def prev_week
    @base_date = Date.strptime(params[:base_date])
    @base_date = @base_date - 1.weeks
    move_week
  end

  def next_week
    @base_date = Date.strptime(params[:base_date])
    @base_date = @base_date + 1.weeks
    move_week
  end

  def move_week
    @project = Project.find(params[:project_id])
    @members = User.with_week_issues(@base_date)
    render :layout => false, :partial => 'gauges/gauges'
  end
end
