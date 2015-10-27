require 'rails_helper'

RSpec.configure do |c|
  c.include TestHelper
end

RSpec.describe LocationsController, :type => :controller do
  fixtures :all

  describe "index" do
    it "should return a list of locations" do
      get :index, {:token => @token}
      expect(json).to have_key('locations')
      expect(json['locations']).to be_kind_of Array
      expect(json['locations'].first).to be_kind_of Hash
    end
    it "should return a list containing location G" do 
      get :index, {:token => @token}
      expect(json["locations"].to_a.find { |location| location["label"].eql?("G") }).to_not be_nil
    end
  end
  describe "show" do
    it "should return a location" do
      get :show, {:id => Location.find_by_label("G")[:id], :token => @token}
      expect(json).to have_key "location"
      expect(json['location']).to be_kind_of Hash
    end
  end
end