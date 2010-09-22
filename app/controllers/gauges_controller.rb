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
    @members = User.with_this_week_issues()
    retrieve_query
    sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)

    if @query.valid?
      @issues = @query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
        :order => sort_clause)
    end
  end
end
