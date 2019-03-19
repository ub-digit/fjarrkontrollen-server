require 'test_helper'

class OrdersControllerTest < ActionController::TestCase

  # assert(test) -> Passes if test is true
  # assert_block block -> Passes if associated block returns true
  # assert_equal(expected, actual) -> Passes if expected == actual
  # assert_includes(collection, object) -> Passes if collection.include?(object)
  # assert_match(expected, actual) -> Passes if expected =~ actual
  # assert_raises(exception) block -> Passes if the associated block raises the exception
  test "should list orders" do
    @request.headers["Accept"] = "application/json"

    get :index
    assert_response 200
  end

  test "should filter currentLocation" do
    skip "Test when figured out how to count the number of filtered orders found."
    orders = Order.where(id: 1..5)
    orders.each do |order|
      order.pickup_location = PickupLocation.find_by_label('Gm')
      order.save
    end

    get :index, {currentLocation: locations(:Gm).id}
    # TODO Find out a way to count the results
    body = JSON.parse(response.body)
    #body["id"].should == @company.id
    assert_response 200
  end

  test "should create an order" do
    @request.headers["Accept"] = "application/json"
    @request.headers["Content-Type"] = "application/json"

    obj = Order.new
    obj.title = "Hulan bulan"
    obj.order_id = "20100102-201102.1"
    obj.order_type = 2
    obj.status_id = 1
    obj.location = Location.find_by_label('Gm')
    obj.form_library = 'Gm'
    json = { order: obj.as_json }

    post :create, json
    assert_response 201

    order = Order.last
    assert_equal("Hulan bulan", order.title)
  end

  test "should show an order" do
    @request.headers["Accept"] = "application/json"
    get :show, {id: 1}
    assert_response 200
  end

  test "should update the order" do
    @request.headers["Accept"] = "application/json"
    @request.headers["Content-Type"] = "application/json"

    obj = Order.find(1)
    obj.title = "Kalaset i skogen"
    obj.status_id = 3

    put :update, {id: 1, order: obj.as_json}, "CONTENT_TYPE" => 'application/json'
    assert_response 200

    get :show, {id: 1}
    assert_response 200
  end

  test "should not delete anything" do
    count_before = Order.all.count
    @request.headers["Accept"] = "application/json"
    delete :destroy, {id: 1}
    assert_response 501
    count_after = Order.all.count

    assert_equal(count_before, count_after, "Orders are not to be deleted.")
  end

end
