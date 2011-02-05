
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
    @base_date = params.include?(:base_date) ? Date.strptime(params[:base_date]) : Date.today
    @gauge_type = params.include?(:gauge_type) ? params[:gauge_type] : :by_amount
p @gauge_type
    @members = Member.with_week_issues(@base_date)
    retrieve_query
    sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    if @query.valid?
      @issues = @query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
        :order => sort_clause)
      respond_to do |format|
        format.html { render :template => 'gauges/index.html.erb', :layout => !request.xhr? }
      end
    end
  end

  def move_issue
    new_member_id = params[:where].split("_")[0]
    new_date = params[:where].split("_")[1]
    Issue.transaction do
      params[:dropped].split(",").each do |element_id|
        issue_id = element_id.split("_")[1]
        issue = Issue.find_by_id(issue_id)
        issue.assigned_to_id = new_member_id
        issue.start_date = new_date
        if !issue.save
          flash[:error] = issue.errors
        end
      end
    end
    @base_date = Date.strptime(params[:base_date])
    show_week
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  end
end
