module UsersHelper

  def user_to_hash(user, type)
    if type == 1
      value = {
        "id" => user.id,
        "email" => user.email,
        "longitude" => user.longitude,
        "latitude" => user.latitude,
        "location" => user.location,
        "picture_id" => user.picture.id
      }
    elsif type == 2
      value = {
        "id" => user.id,
        "email" => user.email,
        "longitude" => user.longitude,
        "latitude" => user.latitude,
        "location" => user.location,
        "picture_id" => user.picture.id
      }
    end
  end
end
