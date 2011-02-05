require 'member'
require 'gauges_helper'

module MemberPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)
    base.extend(GaugesHelper)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      has_many :issues, :primary_key => 'user_id', :foreign_key => "assigned_to_id"
    end

  end

  module ClassMethods
    def with_week_issues(date)
      Member.find(:all, :joins =>
            " LEFT JOIN users ON members.user_id = users.id " +
            " LEFT JOIN issues ON members.user_id = issues.assigned_to_id " +
            " AND issues.start_date BETWEEN '#{get_start_of_week(date)}' AND '#{get_end_of_week(date)}'" +
            " LEFT JOIN issue_statuses ON issues.status_id = issue_statuses.id ",
          :select => 'distinct members.*',
          :order => "users.firstname, users.lastname, issues.start_date, issue_statuses.position desc"
      )
    end
  end

  module InstanceMethods
    def issues_by_date(date)
      issues.find_all {|i| i.start_date == date}
    end

    def closed_issues_by_date(date)
      issues_by_date(date) & closed_issues
    end

    def open_issues_by_date(date)
      issues_by_date(date) & open_issues
    end

    def closed_issues
      issues.find_all {|i| i.closed?}
    end

    def open_issues
      issues.find_all {|i| !i.closed?}
    end

    def completed_pourcent_by_date(date, gauge_type)
      return 0 if issues_by_date(date).size == 0
      return 100 if open_issues_by_date(date).size == 0
      issues_progress_by_date(date, false, gauge_type) +
        issues_progress_by_date(date, true, gauge_type)
    end

    def closed_pourcent_by_date(date, gauge_type)
      return 0 if issues_by_date(date).size == 0
      issues_progress_by_date(date, false, gauge_type)
    end

    def issues_progress_by_date(date, open, gauge_type)
      progress = 0
      if gauge_type == :by_amount
        if issues_by_date(date).size > 0
          average = estimated_average(date)
          ratio = open ? 'done_ratio' : 100
          done = issues.sum("COALESCE(estimated_hours, #{average}) * #{ratio}",
                                    :include => :status,
                                    :conditions => ["is_closed = ? and start_date = ?", !open, date]).to_f
          progress = done / (average * issues_by_date(date).size)
        end
      else
        issues = open ? open_issues_by_date(date) : closed_issues_by_date(date)
        progress = issues.inject(0){|ret, i|ret + i.hours_for_gauge} / 8 * 100
      end
      progress
    end

    def estimated_average(date)
      average = issues.average(:estimated_hours, :conditions => ["start_date = ?", date]).to_f
      if average == 0
        average = 1
      end
      average
    end

  end
end

Member.send(:include, MemberPatch)