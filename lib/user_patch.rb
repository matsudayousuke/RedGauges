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
    def issues_count_by_date(date)
      issues_by_date(date).size
    end

    def issues_by_date(date)
      issues_by {|i| i.start_date == date}
    end

    def issues_by(&condition_block)
      ret = []
      issues.each {|i| ret << i if condition_block.call(i)}
      ret
    end

    def closed_issues_count_by_date(date)
      closed_issues_by_date(date).size
    end
  end
end

User.send(:include, UserPatch)