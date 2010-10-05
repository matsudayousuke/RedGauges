require 'user'
require 'gauges_helper'

module UserPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)
    base.extend(GaugesHelper)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      has_many :issues, :foreign_key => "assigned_to_id"

    end

  end

  module ClassMethods
    def with_week_issues(date)
      User.find(:all, :joins =>
          "LEFT JOIN issues ON users.id = issues.assigned_to_id " +
          "AND issues.start_date BETWEEN #{get_start_of_week(date)} AND #{get_end_of_week(date)}")
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

    def completed_pourcent_by_date(date)
      return 0 if issues_by_date(date).size == 0
      return 100 if open_issues_by_date(date).size == 0
      issues_progress_by_date(date, false) +
        issues_progress_by_date(date, true)
    end

    def closed_pourcent_by_date(date)
      return 0 if issues_by_date(date).size == 0
      issues_progress_by_date(date, false)
    end

    def issues_progress_by_date(date, open)
        progress = 0
        if issues_by_date(date).size > 0
          progress = open ?
            open_issues_by_date(date).size.to_f / issues_by_date(date).size :
            closed_issues_by_date(date).size.to_f / issues_by_date(date).size
        end
        progress * 100
    end

  end
end

User.send(:include, UserPatch)