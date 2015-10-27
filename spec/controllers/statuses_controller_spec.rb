require 'rails_helper'

RSpec.configure do |c|
  c.include TestHelper
end

RSpec.describe StatusesController, :type => :controller do
  
  describe "index" do
    it "should return a valid status list" do
      get :index, {:token => @token}
      expect(json).to have_key('statuses')
      expect(json['statuses']).to be_kind_of Array
      expect(json['statuses'].first).to be_kind_of Hash
    end
    it "should return a status list where each entry has a label value" do 
      get :index, {:token => @token}
      expect(json["statuses"].to_a.each { |status| status["label"].present? }).to be_truthy
    end

    it "should return a list containing status Ny / New" do 
      get :index, {:token => @token}
      expect(json["statuses"].to_a.find { |status| status["name_sv"].eql?("Ny") }).to_not be_nil
      expect(json["statuses"].to_a.find { |status| status["name_en"].eql?("New") }).to_not be_nil
      expect(json["statuses"].to_a.find { |status| status["label"].eql?("new") }).to_not be_nil
    end
    it "should return a list containing status Arkiverad / Archived" do 
      get :index, {:token => @token}
      expect(json["statuses"].to_a.find { |status| status["name_sv"].eql?("Arkiverad") }).to_not be_nil
      expect(json["statuses"].to_a.find { |status| status["name_en"].eql?("Archived") }).to_not be_nil
      expect(json["statuses"].to_a.find { |status| status["label"].eql?("archived") }).to_not be_nil
    end
    it "should return Beställd / Requested as position 2  in the list" do 
      get :index, {:token => @token}
      expect(json["statuses"].to_a[1]["label"].eql?("requested")).to be_truthy
    end
  end

  describe "show" do
    it "should return a status" do
      get :show, {:id => Status.find_by_label('new').id, :token => @token}
      expect(json).to have_key('status')
      expect(json['status']).to be_kind_of Hash  
    end
  end
end