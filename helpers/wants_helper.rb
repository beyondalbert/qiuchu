module WantsHelper

  # 功能：根据type类型返回want的hash格式，用于转换json格式
  # 参数：want：sale对象；
  #      type：hash类型，1包含want的全部字段信息；2只包含部分（id subject description phone user_id status）
  def want_to_hash(want, type)
    if type == 1
      value = {"id" => want.id, 
              "subject" => want.subject, 
              "description" => want.description,
              "phone" => want.phone,
              "user_id" => want.user_id,
              "seller" => want.seller,
              "status" => want.status,
              "longitude" => want.longitude,
              "latitude" => want.latitude,
              "location" => want.location,
              "created_at" => want.created_at,
              "updated_at" => want.updated_at}
    elsif type == 2
      value = {"id" => want.id, 
              "subject" => want.subject, 
              "description" => want.description,
              "phone" => want.phone,
              "user_id" => want.user_id,
              "status" => want.status,}
    end      
  end
end