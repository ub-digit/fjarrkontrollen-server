require 'rails_helper'

RSpec.configure do |c|
  c.include TestHelper
end

RSpec.describe OrdersController, :type => :controller do
  fixtures :all

  before :each do
    user = User.create(xkonto: "valid_username", name: "Valid User")
    user.save
    AccessToken.all.destroy_all
    @user = User.find_by_xkonto("valid_username")
    @user.clear_expired_tokens
    @user.authenticate("valid_password")
    @token = @user.access_tokens.first.token

    @user_trazan = User.find_by_xkonto('xyzxyz')
    #puts "TRAZAN: #{@user_trazan.name}"

    @user_king = User.find_by_xkonto('xgurra')

    #@status_group_all = StatusGroup.find_by_label('all').id
    #@status_group_archived = StatusGroup.find_by_label('archived').id
    @location_g = Location.find_by_label('G').id
  end

  describe "get orders (index)" do
    it "should return order list when using valid token" do
      get :index, {:token => @token}
      expect(json).to have_key('orders')
    end

    it "should get error for request with nonsense token" do
      get :index, {:token => "tjottabengtsson"}
      expect(json).to have_key('error')
    end

    # Pagination
    it "should return pagination fields" do
      get :index, {:token => @token}
      expect(json["meta"]).to be_kind_of Hash
      expect(json["meta"]["pagination"]).to be_kind_of Hash
      expect(json["meta"]["pagination"]["pages"]).not_to be_nil
      expect(json["meta"]["pagination"].has_key?("page")).to be_truthy
      expect(json["meta"]["pagination"].has_key?("next")).to be_truthy
      expect(json["meta"]["pagination"].has_key?("previous")).to be_truthy
    end

    # Query
    it "should return total fields" do
      get :index, {:token => @token}
      expect(json["meta"]).to be_kind_of Hash
      expect(json["meta"]["query"]).to be_kind_of Hash
      expect(json["meta"]["query"]["total"]).not_to be_nil
      expect(json["meta"]["query"]["total"]).to be == 10
    end

    # Test pagination values TBD


    it "should return an order with status Archived" do
      get :index, {:token => @token}
      expect(json["orders"].to_a.find { |order| order["id"] == 3 }).not_to be_nil
    end
    it "should  return an order with status Ny" do
      get :index, {:token => @token}
      expect(json["orders"].to_a.find { |order| order["id"] == 2 }).not_to be_nil
    end


    context 'for no requested status group (considered as all)' do
      it "should return an order with status Archived" do
        get :index, {:token => @token}
        expect(json["orders"].to_a.find { |order| order["id"] == 3 }).not_to be_nil
      end
      it "should return an order with status Ny" do
        get :index, {:token => @token}
        expect(json["orders"].to_a.find { |order| order["id"] == 2 }).not_to be_nil
      end
    end
    context 'for requested status group all' do
      it "should return an order with status Archived" do
        get :index, {:token => @token, :status_group => 'all'}
        expect(json["orders"].to_a.find { |order| order["id"] == 3 }).not_to be_nil
      end
      it "should return an order with status Ny" do
        get :index, {:token => @token, :status_group => 'all'}
        expect(json["orders"].to_a.find { |order| order["id"] == 2 }).not_to be_nil
      end
    end
    context 'for requested status archived i.e. no-existing status group' do
      it "should return all orders" do
        get :index, {:token => @token, :status_group => 'archived'}
        expect(json["orders"].to_a.count).to be == 10
      end
    end

    context 'for no requested currentLocation (considered as all)' do
      it "should return an order with location G" do
        get :index, {:token => @token, :currentLocation => @location_g}
        expect(json["orders"].to_a.find { |order| order["id"] == 2 }).not_to be_nil
      end
    end
    context 'for requested currentLocation all' do
      it "should return an order with location G" do
        get :index, {:token => @token, :currentLocation => @location_g}
        expect(json["orders"].to_a.find { |order| order["id"] == 2 }).not_to be_nil
      end
    end
    context 'for a requested currentLocation G' do
      it "should return an order with location G" do
        get :index, {:token => @token, :currentLocation => @location_g}
        expect(json["orders"].to_a.find { |order| order["id"] == 2 }).not_to be_nil
      end
    end

    context 'when a valid sticky note id exists' do
      it "should return a valid sticky note subject" do
        get :index, {:token => @token}
        expect(json["orders"].to_a.find { |order| order["id"] == 9 }["sticky_note_subject"]).to eq 'Sticky Note Test Subject'
      end
      it "should return a valid sticky note message" do
        get :index, {:token => @token}
        expect(json["orders"].to_a.find { |order| order["id"] == 9 }["sticky_note_message"]).to eq 'Sticky Note Test Message'
      end
    end
    context 'when an invalid sticky note id exists' do
      it "should return sticky note subject with nil value" do
        get :index, {:token => @token}
        expect(json["orders"].to_a.find { |order| order["id"] == 4 }["sticky_note_subject"]).to eq nil
      end
      it "should return sticky note message with nil value" do
        get :index, {:token => @token}
        expect(json["orders"].to_a.find { |order| order["id"] == 4 }["sticky_note_message"]).to eq nil
      end
    end
  end

  #
  # index method should currentLocation=null
  # http://fjarrkontrollen-server-test.ub.gu.se/orders?search_term=&currentLocation=null&status=&mediaType%5B%5D=2&mediaType%5B%5D=1&user=&sortfield=order_number&sortdir=DESC&token=77df61d7f515652a81503f0b432b5d0a
  #                                            /orders?search_term=&currentLocation=2&status=&mediaType%5B%5D=2&mediaType%5B%5D=1&user=&sortfield=order_number&sortdir=DESC&token=db1cd64b6c8702f4cd28501eb15a42fc
  #
  describe "filter" do

    it "should return all orders when currentLocation is missing" do
      get :index, {:token => @token}
      expect(json).not_to have_key('error')
      expect(json["orders"].to_a.count).to be == 10
    end

    it "should return all orders when currentLocation=0" do
      get :index, {:token => @token, :currentLocation => '0'}
      expect(json).not_to have_key('error')
      expect(json["orders"].to_a.count).to be == 10
    end

    it "should return all orders when currentLocation=null" do
      get :index, {:token => @token, :currentLocation => 'null'}
      expect(json).not_to have_key('error')
      expect(json["orders"].to_a.count).to be == 10
    end

    it "should return all orders when currentLocation=" do
      get :index, {:token => @token, :currentLocation => ''}
      expect(json).not_to have_key('error')
      expect(json["orders"].to_a.count).to be == 10
    end


    # is_archived tests
    it "should return 10 orders when is_archived is missing" do
      get :index, {:token => @token}
      expect(json).not_to have_key('error')
      expect(json["orders"].to_a.count).to be == 10
    end
    it "should return 10 orders when is_archived=" do
      get :index, {:token => @token, :is_archived => ''}
      expect(json).not_to have_key('error')
      expect(json["orders"].to_a.count).to be == 10
    end
    it "should return 10 orders when is_archived has a nonsense value " do
      get :index, {:token => @token, :is_archived => 'xyz123'}
      expect(json).not_to have_key('error')
      expect(json["orders"].to_a.count).to be == 10
    end

    it "should return 9 orders when is_archived=false" do
      get :index, {:token => @token, :is_archived => 'false'}
      expect(json).not_to have_key('error')
      expect(json["orders"].to_a.count).to be == 9
    end
    it "should return 9 orders when is_archived=0" do
      get :index, {:token => @token, :is_archived => '0'}
      expect(json).not_to have_key('error')
      expect(json["orders"].to_a.count).to be == 9
    end
    it "should return 1 order when is_archived=true" do
      get :index, {:token => @token, :is_archived => 'true'}
      expect(json).not_to have_key('error')
      expect(json["orders"].to_a.count).to be == 1
    end
    it "should return 1 order when is_archived=1" do
      get :index, {:token => @token, :is_archived => '1'}
      expect(json).not_to have_key('error')
      expect(json["orders"].to_a.count).to be == 1
    end

    # delivery source tests
    it "should return 10 orders when delivery_source is missing" do
      get :index, {:token => @token}
      expect(json).not_to have_key('error')
      expect(json["orders"].to_a.count).to be == 10
    end
    it "should return 10 orders when delivery_source=all" do
      get :index, {:token => @token, :delivery_source => 'all'}
      expect(json).not_to have_key('error')
      expect(json["orders"].to_a.count).to be == 10
    end
    it "should return 10 orders when delivery_source=0" do
      get :index, {:token => @token, :delivery_source => '0'}
      expect(json).not_to have_key('error')
      expect(json["orders"].to_a.count).to be == 10
    end
    it "should return 10 orders when delivery_source=" do
      get :index, {:token => @token, :delivery_source => ''}
      expect(json).not_to have_key('error')
      expect(json["orders"].to_a.count).to be == 10
    end

    it "should return 9 orders when delivery_source=own_collection" do
      get :index, {:token => @token, :delivery_source => 'own_collection'}
      expect(json).not_to have_key('error')
      expect(json["orders"].to_a.count).to be == 9
    end
    it "should return 1 orders when delivery_source=other" do
      get :index, {:token => @token, :delivery_source => 'other'}
      expect(json).not_to have_key('error')
      expect(json["orders"].to_a.count).to be == 1
    end

  end

  describe "search" do

    it "should return one hit when name is Alfred E Neumann" do
      get :index, {:token => @token, :search_term => 'Neuman'}
      expect(json["orders"].to_a.count).to be == 1
      expect(json["orders"].to_a.find { |order| order["id"] == 5 }).not_to be_nil
    end

    it "should return one hit when author is Miller" do
      get :index, {:token => @token, :search_term => 'Miller'}
      expect(json["orders"].to_a.count).to be == 1
      expect(json["orders"].to_a.find { |order| order["id"] == 5 }).not_to be_nil
    end

    it "should return nine hits when name is Henry Jekyll" do
      get :index, {:token => @token, :search_term => 'y Jeky'}
      expect(json["orders"].to_a.count).to be == 9
      expect(json["orders"].to_a.find { |order| order["id"] == 5 }).to be_nil
    end

    it "should get hit when title matches search_term" do
      get :index, {:token => @token, :search_term => 'choklad'}
      expect(json["orders"].to_a.count).to be == 1
      expect(json["orders"].to_a.find { |order| order["id"] == 6 }).not_to be_nil

      get :index, {:token => @token, :search_term => 'odern'}
      expect(json["orders"].to_a.count).to be == 1
      expect(json["orders"].to_a.find { |order| order["id"] == 6 }).not_to be_nil
    end

    it "should get hit when publication_year matches search_term" do
      get :index, {:token => @token, :search_term => '1912'}
      expect(json["orders"].to_a.find { |order| order["id"] == 6 }).not_to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 3 }).to be_nil

      get :index, {:token => @token, :search_term => '2010'}
      expect(json["orders"].to_a.find { |order| order["id"] == 3 }).not_to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 6 }).to be_nil
    end

    it "should get hit when journal_title matches search_term" do
      get :index, {:token => @token, :search_term => 'Journal_4'}
      expect(json["orders"].to_a.count).to be == 1
      expect(json["orders"].to_a.find { |order| order["id"] == 4 }).not_to be_nil
    end

    it "should get hit when issn_isbn matches search_term" do
      get :index, {:token => @token, :search_term => '1234-1234'}
      expect(json["orders"].to_a.count).to be == 1
      expect(json["orders"].to_a.find { |order| order["id"] == 7 }).not_to be_nil

      get :index, {:token => @token, :search_term => '1111-1111'}
      expect(json["orders"].to_a.count).to be == 9
      expect(json["orders"].to_a.find { |order| order["id"] == 6 }).not_to be_nil
    end

    it "should get hit when library_card_number exactly matches search_term" do
      get :index, {:token => @token, :search_term => '5001242102'}
      expect(json["orders"].to_a.find { |order| order["id"] == 5 }).not_to be_nil
      expect(json["orders"].to_a.count).to be == 1
    end

    it "should get hit when reference_information matches search_term" do
      get :index, {:token => @token, :search_term => 'jenx'}
      expect(json["orders"].to_a.count).to be == 10
    end

    it "should get hit when order_number exactly matches match search_term" do
      get :index, {:token => @token, :search_term => '20140101-000000.4'}
      expect(json["orders"].to_a.find { |order| order["id"] == 4 }).not_to be_nil
      expect(json["orders"].to_a.count).to be == 1
    end

    it "should get hit when search_term matches comments" do
      get :index, {:token => @token, :search_term => 'ing test'}
      expect(json["orders"].to_a.find { |order| order["id"] == 4 }).not_to be_nil
      expect(json["orders"].to_a.count).to be == 10
    end

    it "should get hit when search_term matches libris_lf_number" do
      get :index, {:token => @token, :search_term => 'G-141121-0001'}
      expect(json["orders"].to_a.find { |order| order["id"] == 4 }).not_to be_nil
      expect(json["orders"].to_a.count).to be == 1
    end

    it "should get hit when search_term matches libris_request_id" do
      get :index, {:token => @token, :search_term => '246708'}
      expect(json["orders"].to_a.find { |order| order["id"] == 4 }).not_to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 5 }).to be_nil

      get :index, {:token => @token, :search_term => '250005'}
      expect(json["orders"].to_a.find { |order| order["id"] == 4 }).to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 5 }).not_to be_nil
      expect(json["orders"].to_a.count).to be == 1
    end

    it "should get hit when search_term matches libris_id" do
      get :index, {:token => @token, :search_term => '12345'}
      expect(json["orders"].to_a.find { |order| order["id"] == 4 }).not_to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 5 }).to be_nil
      expect(json["orders"].to_a.count).to be == 1

      get :index, {:token => @token, :search_term => '13005'}
      expect(json["orders"].to_a.find { |order| order["id"] == 4 }).to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 5 }).not_to be_nil
    end

    it "should get hit when search_term matches librismisc" do
      get :index, {:token => @token, :search_term => 'diwerz'}
      expect(json["orders"].to_a.find { |order| order["id"] == 4 }).not_to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 5 }).to be_nil
      expect(json["orders"].to_a.count).to be == 1

      get :index, {:token => @token, :search_term => 'tt o an'}
      expect(json["orders"].to_a.find { |order| order["id"] == 4 }).to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 5 }).not_to be_nil
    end

    it "should get hit when search_term matches xkonto of a user" do
      the_order = Order.find_by_id(4)
      the_order.user = @user_trazan
      the_order.save
      #puts "Trazan: #{@user_trazan.xkonto}"
      #puts "Fyran: order_number:#{the_order.order_number}, user:#{the_order.user_id}"

      the_order = Order.find_by_id(5)
      the_order.user = @user_king
      the_order.save
      #puts "Gustaf: #{@user_king.xkonto}"
      #puts "Femman: order_number:#{the_order.order_number}, user:#{the_order.user_id}"

      get :index, {:token => @token, :search_term => 'xyzxyz'}
      expect(json["orders"].to_a.find { |order| order["id"] == 4 }).not_to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 5 }).to be_nil

      get :index, {:token => @token, :search_term => 'xgurra'}
      expect(json["orders"].to_a.find { |order| order["id"] == 4 }).to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 5 }).not_to be_nil
    end

    it "should get hit when search_term matches name of a user" do
      the_order = Order.find_by_id(4)
      the_order.user = @user_trazan
      the_order.save

      the_order = Order.find_by_id(5)
      the_order.user = @user_king
      the_order.save

      get :index, {:token => @token, :search_term => 'Apanz'}
      expect(json["orders"].to_a.find { |order| order["id"] == 4 }).not_to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 5 }).to be_nil

      get :index, {:token => @token, :search_term => 'Wasa'}
      expect(json["orders"].to_a.find { |order| order["id"] == 4 }).to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 5 }).not_to be_nil
    end

    it "should get hit when search_term matches message of a note" do
      get :index, {:token => @token, :search_term => 'fyra ben och en snabel'}
      expect(json["orders"].to_a.find { |order| order["id"] == 4 }).not_to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 5 }).to be_nil
    end

    it "should get several hits when search_term matches message of a note for several orders" do
      get :index, {:token => @token, :search_term => 'urk'}
      expect(json["orders"].to_a.find { |order| order["id"] == 4 }).not_to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 5 }).not_to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 6 }).not_to be_nil

      get :index, {:token => @token, :search_term => 'UrKeN'}
      expect(json["orders"].to_a.find { |order| order["id"] == 4 }).not_to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 5 }).not_to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 6 }).to be_nil
    end

    it "should get hit when search_term matches subject of a note" do
      get :index, {:token => @token, :search_term => 'elefanter'}
      expect(json["orders"].to_a.find { |order| order["id"] == 4 }).not_to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 5 }).to be_nil
    end

    it "should get several hits when search_term matches subject of a note for several orders" do
      get :index, {:token => @token, :search_term => 'nummer'}
      expect(json["orders"].to_a.find { |order| order["id"] == 4 }).to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 5 }).to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 6 }).not_to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 7 }).not_to be_nil

      get :index, {:token => @token, :search_term => 'numero'}
      expect(json["orders"].to_a.find { |order| order["id"] == 4 }).not_to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 5 }).not_to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 6 }).not_to be_nil
      expect(json["orders"].to_a.find { |order| order["id"] == 7 }).to be_nil
    end
  end

  describe "update" do
    it "should get error for request with nonsense token" do
      put :update, {:token => "tjottabengtsson", :id => 1, :order => {:is_archived => 'true'}}
      expect(json).to have_key('error')
    end

    it "should save and return the order" do
      put :update, {:token => @token, :id => 1, :order => {:is_archived => 'true'}}
      expect(json["order"]["is_archived"] == true).to be_truthy
    end
  end
end
