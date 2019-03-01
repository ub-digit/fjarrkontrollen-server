class StatisticsController < ApplicationController
  def index

    # Validate parameters TBD

    orders = Order.all

    if params[:pickup_location] && params[:pickup_location].present?
      orders = orders.where("pickup_location_id = (?)", PickupLocation.find_by_label(params[:pickup_location].strip).id)
    end

    if params[:start] && params[:start].present?
      orders = orders.where("DATE(created_at) >= (?)", params[:start].strip)
    end

    if params[:end] && params[:end].present?
      orders = orders.where("DATE(created_at) <= (?)", params[:end].strip)
    end

    incoming_total = orders.count
    incoming_per_day_tmp = orders.count(group: ["DATE(created_at)"])

    # Fill empty days with zeros
    start_day = params[:start] && params[:start].present? ? params[:start].strip : incoming_per_day_tmp.keys.min
    end_day = params[:end] && params[:end].present? ? params[:end].strip : incoming_per_day_tmp.keys.max
    incoming_per_day = Hash[start_day.to_datetime.upto(end_day.to_datetime).map {|day| [day.strftime("%F"), 0]}].merge(incoming_per_day_tmp)


    incoming = {total: incoming_total, per_day: incoming_per_day}
    
    statuses = orders.count(group: "status_id").map{|k, v| { !k.nil? && !Status.find_by_id(k).nil? ? Status.find_by_id(k).name_sv.to_sym : "Okänd".to_sym => v }}

    completed_orders = orders.where(status_id: [Status.find_by_label("delivered").id, Status.find_by_label("returned").id])

    order_types = completed_orders.count(group: "order_type_id").map{|k, v| { !k.nil? && !OrderType.find_by_id(k).nil? ? OrderType.find_by_id(k).name_sv.to_sym : "Okänd".to_sym => v }}
    delivery_sources = completed_orders.count(group: "delivery_source_id").map{|k, v| { !k.nil? && !DeliverySource.find_by_id(k).nil? ? DeliverySource.find_by_id(k).name.to_sym : "Ej vald".to_sym => v }}
    pickup_locations = completed_orders.count(group: "pickup_location_id").map{|k, v| { !k.nil? && !PickupLocation.find_by_id(k).nil? ? PickupLocation.find_by_id(k).label.to_sym : "Okänd".to_sym => v }}
    order_paths = completed_orders.count(group: "order_path").map{|k, v| { !k.nil? ? k.to_sym : "Okänd".to_sym => v }}

    render json: {incoming: incoming, statuses: statuses, order_types: order_types, delivery_sources: delivery_sources, pickup_locations: pickup_locations, order_paths: order_paths}, status: 200

  end
end

