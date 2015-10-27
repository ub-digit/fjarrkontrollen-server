require 'rails_helper'

RSpec.configure do |c|
  c.include TestHelper
end

RSpec.describe NotesController, :type => :controller do
  fixtures :all

  before :each do
    user = User.create(xkonto: "valid_username", name: "Valid User")
    user.save
    AccessToken.all.destroy_all
    @user = User.find_by_xkonto("valid_username")
    @user.clear_expired_tokens
    @user.authenticate("valid_password")
    @token = @user.access_tokens.first.token

  end

  describe "get notes (index)" do
    it "should return note list when using valid token" do
      get :index, {:token => @token}
      expect(json).to have_key('notes')
    end

    it "should get error for request with nonsense token" do
      get :index, {:token => "tjottabengtsson"}
      expect(json).to have_key('error')
    end
  end

  describe "index" do
    it "should return a list of notes" do
      get :index, {:token => @token}
      expect(json).to have_key('notes')
      expect(json['notes']).to be_kind_of Array
      expect(json['notes'].first).to be_kind_of Hash
    end

  end
  describe "show" do
    it "should return a note" do
      get :show, {:id => 1, :token => @token}
      expect(json).to have_key "note"
      expect(json['note']).to be_kind_of Hash
      expect(json['note']['order_id']).to eq 4
      expect(json['note']['user_id']).to eq 1
      expect(json['note']['subject']).to eq 'Viktigt att veta om elefanter'
      expect(json['note']['message']).to eq 'Elefanterna har fyra ben och en snabel.'

    end
  end
end
