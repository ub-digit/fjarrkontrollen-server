class Export
  def self.create

    query = "SELECT
  orders.id as id,
  orders.order_number as order_number,
  to_char(orders.created_at, 'YYYY-MM-DD HH24:MI') as created,
  to_char(orders.created_at, 'YYYY') as year,
  to_char(orders.created_at, 'MM') as month,
  pickup_locations.name_sv as pickup_location,
  managing_groups.name as managing_group,
  statuses.name_sv as status,
  order_types.name_sv as type,
  orders.order_path as order_path,
  delivery_sources.name as delivery_source,
  orders.lending_library as lending_library,
  customer_types.name_sv as customer_type,
  delivery_methods.name as delivery_method,
  orders.journal_title as journal_title
FROM
  public.orders
  LEFT JOIN pickup_locations
    ON pickup_locations.id = orders.pickup_location_id
  INNER JOIN managing_groups
    ON managing_groups.id = orders.managing_group_id
  INNER JOIN statuses
    ON statuses.id = orders.status_id
  INNER JOIN order_types
    ON order_types.id = orders.order_type_id
  LEFT JOIN delivery_sources
    ON delivery_sources.id = orders.delivery_source_id
  LEFT JOIN customer_types
  ON customer_types.id = orders.customer_type_id
  LEFT JOIN delivery_methods
    ON delivery_methods.id = orders.delivery_method_id
ORDER BY orders.created_at ASC;"

    result = ActiveRecord::Base.connection.exec_query(query)

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => 'Fjärrkontrollen - beställningar') do |sheet|
        sheet.add_row(result.columns.map{ |column| export_column_name_mappings(column) })
        result.rows.each do |row|
          sheet.add_row(row)
        end
      end
      return p
    end
  end

  def self.export_column_name_mappings name
    case name
    when "id"
      return "ID"
    when "order_number"
      return "Ordernummer"
    when "created"
      return "Skapad"
    when "year"
      return "År"
    when "month"
      return "Månad"
    when "pickup_location"
      return "Avhämtningsbibliotek"
    when "managing_group"
      return "Handläggningsgrupp"
    when "status"
      return "Status"
    when "type"
      return "Typ"
    when "order_path"
      return "Beställd genom"
    when "delivery_source"
      return "Beställd från"
    when "lending_library"
      return "Utlånande bibliotek"
    when "customer_type"
      return "Kundtyp"
    when "delivery_method"
      return "Leveransmetod"
    when "journal_title"
      return "Tidskriftstitel"
    else
      return ""
    end
  end
end
