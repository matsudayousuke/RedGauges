
class GaugesController < ApplicationController
  unloadable
  helper :sort
  include SortHelper
  helper :queries
  include QueriesHelper
  helper :issues
  include IssuesHelper

  before_filter :find_project, :authorize, :only => :index

  def index
    @base_date ||= Date.today
    @members = Member.with_week_issues(@base_date)
    logger.debug('aaa')
    logger.debug(@members)
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
    show_week
  end

  def next_week
    @base_date = Date.strptime(params[:base_date])
    @base_date = @base_date + 1.weeks
    show_week
  end

  def show_week
    @members = Member.with_week_issues(@base_date)
    render :layout => false, :partial => 'gauges/gauges'
  end

  def move_issue
    new_member_id = params[:where].split("_")[0]
    new_date = params[:where].split("_")[1]
    issue_id = params[:dropped].split("_")[1]
    issue = Issue.find_by_id(issue_id)
    issue.assigned_to_id = new_member_id
    issue.start_date = new_date
    issue.save
    @base_date = Date.strptime(params[:base_date])
    show_week
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  end
end
