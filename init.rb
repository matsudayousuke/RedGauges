require 'redmine'

require 'member_patch'

Redmine::Plugin.register :redmine_red_gauges do
  name 'Redmine RedGauges plugin'
  author 'Yousuke Matsuda'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://github.com/matsudayousuke/RedGauges'
  author_url 'http://example.com/about'

  project_module :gauges do
    permission :gauges, {:gauges => [:index]}, :public => false
  end
  menu :project_menu, :gauges, { :controller => 'gauges', :action => 'index' },
     :caption => :label_gauges, :after => :activity, :param => :project_id
end
