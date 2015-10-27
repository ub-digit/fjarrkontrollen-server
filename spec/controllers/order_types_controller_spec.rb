require 'rails_helper'

RSpec.configure do |c|
  c.include TestHelper
end

RSpec.describe OrderTypesController, :type => :controller do
  
  describe "index" do
    it "should return a valid order_types list" do
      get :index, {:token => @token}
      expect(json).to have_key('order_types')
      expect(json['order_types']).to be_kind_of Array
      expect(json['order_types'].first).to be_kind_of Hash
    end

  end

  describe "show" do
    it "should return an order_types" do
      get :show, {:id => OrderType.find_by_name_en('Loan').id, :token => @token}
      expect(json).to have_key('order_type')
      expect(json['order_type']).to be_kind_of Hash  
    end
  end
end