require 'rails_helper'

RSpec.configure do |c|
  c.include ControllerHelper
end
RSpec.describe EmailTemplatesController , :type => :controller do

  describe "GET email_templates (index)" do
    it "should return a list of correct email template json data" do
      et_tmp = EmailTemplate.first
      subject_en = et_tmp.subject_en

      get :index, {:token => @token}

      expect(json).to have_key "email_templates"
      expect(json['email_templates']).to be_kind_of Array
      expect(json['email_templates'].first).to be_kind_of Hash
      expect(json['email_templates'].first['subject_en']).to eq subject_en
    end
  end
  describe "GET email_template (show)" do
    it "should return correct json email template data" do
      et_tmp = EmailTemplate.first
      id = et_tmp.id
      subject_en = et_tmp.subject_en

      get :show, {:id => id, :token => @token}

      expect(json).to have_key "email_template"
      expect(json['email_template']).to be_kind_of Hash
      expect(json['email_template']['subject_en']).to eq subject_en
    end
  end
end
