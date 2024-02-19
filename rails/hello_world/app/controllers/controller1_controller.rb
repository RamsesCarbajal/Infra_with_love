class Controller1Controller < ApplicationController
  attr_accessor :controller_var, :env_var
  def index
    @controller_var = "from Controller1Controller"
    @env_var = ENV["CUSTOM_ENV_LOVE"]
  end
end
