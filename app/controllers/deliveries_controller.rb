class DeliveriesController < ApplicationController
  
  before_filter :restrict_to_development_mode
  
  def index
    load_delivery
  end
  
  def show
    if (@delivery = load_delivery).nil?
      redirect_to :action => :index
    else
      render :action => :index
    end
  end
  
  def destroy
    delivery = load_delivery
    @deliveries.delete delivery if delivery
    redirect_to :action => :index
  end
  
  def destroy_all
    load_delivery
    @deliveries.clear
    redirect_to :action => :index
  end
  
  private
  
  def load_delivery
    @deliveries = ActionMailer::Base.deliveries
    if params[:id]
      matching = @deliveries.collect { |d| d if d.object_id.to_s == params[:id] }.compact
      return matching.empty? ? nil : matching[0]
    end
  end
  
  def restrict_to_development_mode
    return true if RAILS_ENV == 'development'
    raise "This is only allowed in DEV mode"
  end
  
end
