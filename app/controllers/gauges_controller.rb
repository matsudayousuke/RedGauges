class GaugesController < ApplicationController
  unloadable


  def index
    @issues = Issue.find(:all)
  end
end
