ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'gauges' do |gauges|
    gauges.connect 'projects/:project_id/gauges', :action => 'index'
  end
end