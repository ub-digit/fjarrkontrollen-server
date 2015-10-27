require 'rails_helper'

RSpec.configure do |c|
  c.include TestHelper
end

RSpec.describe UsersController, :type => :controller do
  fixtures :all

  describe "index" do
    it "should return a valid list of users" do
      get :index, {:token => @token}
      expect(json).to have_key('users')
      expect(json['users']).to be_kind_of Array
      expect(json['users'].first).to be_kind_of Hash
    end
    it "should return a list of users where each entry has an xkonto" do 
      get :index, {:token => @token}
      expect(json["users"].to_a.each { |user| user["xkonto"].present? }).to be_truthy
    end

    it "should return a list of users where each user except system user has a location" do 
      get :index, {:token => @token}
      expect(json["users"].to_a.each { |user| !user["xkonto"].eql?("systemet") && user["location_id"].present? }).to be_truthy
    end
  end


  describe "show" do
    context "for a standard user" do
      it "should return id, xkonto, name and location" do
        get :show, {:id => 1, :token => @token}
        expect(json).to have_key('user')
        expect(json['user']['id'].present?).to be_truthy
        expect(json['user']['xkonto'].present?).to be_truthy
        expect(json['user']['name'].present?).to be_truthy
        expect(json['user']['location_id'].present?).to be_truthy
      end    
    end
    context "for system user (id 0)" do
      it "should return id, xkonto and name" do
        get :show, {:id => 0, :token => @token}        
        expect(json).to have_key('user')
        expect(json['user']['id'].present?).to be_truthy
        expect(json['user']['xkonto'].present?).to be_truthy
        expect(json['user']['name'].present?).to be_truthy
      end
    end  
  end

  describe "show_by_xkonto" do
    context "for a standard user" do
      it "should return id, xkonto, name and location" do
        get :show_by_xkonto, {:xkonto => User.find_by_id(1)[:xkonto], :token => @token}
        expect(json).to have_key('user')
        expect(json['user']['id'].present?).to be_truthy
        expect(json['user']['xkonto'].present?).to be_truthy
        expect(json['user']['name'].present?).to be_truthy
        expect(json['user']['location_id'].present?).to be_truthy
      end    
    end
    context "for system user (id 0)" do
      it "should return id, xkonto and name" do
        get :show_by_xkonto, {:xkonto =>  User.find_by_id(1)[:xkonto], :token => @token}        
        expect(json).to have_key('user')
        expect(json['user']['id'].present?).to be_truthy
        expect(json['user']['xkonto'].present?).to be_truthy
        expect(json['user']['name'].present?).to be_truthy
      end
    end  
  end


end
