module SalesHelper

  # 功能：根据type类型返回sale的hash格式，用于转换json格式
  # 参数：
  #      sale：sale对象；
  #      type：hash类型，1包含sale的全部字段信息；2只包含部分（id subject description price condition status）
  def sale_to_hash(sale, type)
    if type == 1
      value = { "id" => sale.id, 
              "subject" => sale.subject, 
              "description" => sale.description,
              "price" => sale.price,
              "user_id" => sale.user_id,
              "condition" => sale.condition, 
              "phone" => sale.phone,
              "buyer" => sale.buyer,
              "status" => sale.status,
              "longitude" => sale.longitude,
              "latitude" => sale.latitude,
              "location" => sale.location,
              "created_at" => sale.created_at,
              "updated_at" => sale.updated_at}
    elsif type == 2     
      value = { "id" => sale.id, 
              "subject" => sale.subject, 
              "description" => sale.description,
              "price" => sale.price,
              "condition" => sale.condition, 
              "status" => sale.status}
    end
  end
end