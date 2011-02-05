require 'issue'

module IssuePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    def hours_for_gauge
      actual = time_entries.find_all {|t| t.spent_on == start_date}.inject(0) {|ret, t| ret + t.hours}
      closed? || actual > estimated_hours ? actual : estimated_hours
    end
  end
end

Issue.send(:include, IssuePatch)