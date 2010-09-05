require 'redmine'

Redmine::Plugin.register :redmine_red_gauges do
  name 'Redmine RedGauges plugin'
  author 'Yousuke Matsuda'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://github.com/matsudayousuke/RedGauges'
  author_url 'http://example.com/about'

   permission :gauges, {:gauges => [:index]}, :public => true
   menu :project_menu, :gauges, { :controller => 'gauges', :action => 'index' },
     :caption => 'Gauges', :after => :activity, :param => :project_id
end
