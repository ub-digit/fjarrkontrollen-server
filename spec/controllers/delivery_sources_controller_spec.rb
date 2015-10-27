require 'rails_helper'


RSpec.configure do |c|
  c.include ControllerHelper
end
RSpec.describe DeliverySourcesController, :type => :controller do

  describe "index" do
    it "should return a correct list of delivery sources" do
      get :index, {}
      expect(json).to have_key "delivery_sources"
      expect(json['delivery_sources']).to be_kind_of Array
      expect(json['delivery_sources'].first).to be_kind_of Hash
      expect(json['delivery_sources'].first['label'].present?).to be_truthy
    end
  end
  describe "show" do
  	context "for an existing delivery source id" do
      it "should return a delivery source" do
        get :show, {:id => DeliverySource.find_by_label('own_collection').id}
        expect(json).to have_key "delivery_source"
        expect(json['delivery_source']).to be_kind_of Hash
        expect(json['delivery_source']['label'].present?).to be_truthy
      end
    end
  	context "for a non-existing delivery source id" do
      it "should return a delivery source" do
        get :show, {:id => 1234}
        expect(response.status).to eq 404
      end
    end
  end

end
