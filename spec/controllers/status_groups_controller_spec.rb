require 'rails_helper'

RSpec.configure do |c|
  c.include TestHelper
end

RSpec.describe StatusGroupsController, :type => :controller do
  describe "index" do
    it "should return a valid status group list" do
      get :index, {:token => @token}
      expect(json).to have_key('status_groups')
      expect(json['status_groups']).to be_kind_of Array
      expect(json['status_groups'].first).to be_kind_of Hash
    end
    it "should return a status group list where each entry has a label value" do
      get :index, {:token => @token}
      expect(json["status_groups"].to_a.each { |status_group| status_group["label"].present? }).to be_truthy
    end

    it "should return a list containing status group Ny / New" do
      get :index, {:token => @token}
      expect(json["status_groups"].to_a.find{ |status_group| status_group["name_sv"].eql?("Ny") }).to_not be_nil
      expect(json["status_groups"].to_a.find { |status_group| status_group["name_en"].eql?("New") }).to_not be_nil
      expect(json["status_groups"].to_a.find { |status_group| status_group["label"].eql?("new") }).to_not be_nil
    end
    it "should return a list containing status group Alla / All" do
      get :index, {:token => @token}
      expect(json["status_groups"].to_a.find{ |status_group| status_group["name_sv"].eql?("Alla statusar") }).to_not be_nil
      expect(json["status_groups"].to_a.find{ |status_group| status_group["name_en"].eql?("All statuses") }).to_not be_nil
      expect(json["status_groups"].to_a.find{ |status_group| status_group["label"].eql?("all") }).to_not be_nil
    end
    it "should return Beställd / Requested as position 3 in the list" do
      get :index, {:token => @token}
      expect(json["status_groups"].to_a[2]["label"].eql?("requested")).to be_truthy
    end
  end
  describe "show" do
    it "should return a status group" do
      get :show, {:id => Status.find_by_label('new').id, :token => @token}
      expect(json).to have_key('status_group')
      expect(json['status_group']).to be_kind_of Hash
    end
  end
end
