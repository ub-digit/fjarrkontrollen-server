require 'rails_helper'

RSpec.configure do |c|
  c.include TestHelper
end

RSpec.describe PickupLocationsController, :type => :controller do
  fixtures :all

  describe "index" do
    it "should return a list of pickup_locations" do
      get :index, {:token => @token}
      expect(json).to have_key('pickup_locations')
      expect(json['pickup_locations']).to be_kind_of Array
      expect(json['pickup_locations'].first).to be_kind_of Hash
    end
    it "should return a list containing pickup_location G" do 
      get :index, {:token => @token}
      expect(json["pickup_locations"].to_a.find { |pickup_location| pickup_location["label"].eql?("G") }).to_not be_nil
    end
  end
  describe "show" do
    it "should return a pickup_location" do
      get :show, {:id => Location.find_by_label("G")[:id], :token => @token}
      expect(json).to have_key "pickup_location"
      expect(json['pickup_location']).to be_kind_of Hash
    end
  end
end