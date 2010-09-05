class GaugesController < ApplicationController
  unloadable


  def index
    @members = User.find(:all)
  end
end
