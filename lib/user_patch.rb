require 'user'

module UserPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      has_many :issues, :foreign_key => "assigned_to_id"

    end

  end

  module ClassMethods
    def with_this_week_issues
      start_of_week = Date.today - Date.today.wday
      end_of_week = start_of_week + 6
      User.find(:all, :include => :issues, :conditions =>
          ["issues.id is null or issues.start_date between ? and ?",
            start_of_week, end_of_week])
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