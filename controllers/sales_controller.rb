class SalesController < ApplicationController

  helpers SalesHelper

  before do
    pass if %w[pictures].include? request.path_info.split('/')[2]
    content_type :json
    @current_user ||= User.find_by_token(params[:key]) unless params[:key].nil?
    error 401 unless @current_user
  end

  before '/:id' do
    pass if %w[pictures].include? request.path_info.split('/')[2]
    begin
      @sale = Sale.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      return status 404
    end
  end

  # 功能：返回自己要出的二手物品
  # 参数：params[:key]
  # 用法：http://localhost:3000/sales?key=5408afee03ca8c52a780570a4322cae3
  # 返回值：用户认证通过：返回用户自己发布的二手物品json
  #         用户认证失败：返回http状态为401
  get '/' do
    values = []
    @sales = Sale.where(:user_id => @current_user.id)
    @sales.each do |sale|
      tmp = sale_to_hash(sale, 2)
      tmp["picture_id"] = sale.pictures.first.id
      values << tmp
    end
    values.to_json
  end

  # 功能：返回某个特定待出的二手物品
  # 参数：params[:key]
  # 用法：http://localhost:3000/sales/1?key=5408afee03ca8c52a780570a4322cae3
  # 返回值：用户认证通过：返回id为1的二手物品json
  #         用户认证失败：返回http状态为401
  #         二手物品不存在或已被删除：返回http状态为404
  get '/:id' do
    value = sale_to_hash(@sale, 1)
    value["picture_ids"] = @sale.pictures.collect(&:id)
    value.to_json
  end

  # 功能：新发布一个要出的二手物品
  # 参数：params[:key] params[:sale] params[:file]
  # 用法：http://localhost:3000/sales?key=5408afee03ca8c52a780570a4322cae3&sale[subject]=test&sale[description]=test...
  # 返回值：用户认证通过并且数据库存储成功：返回新发布的待出二手物品json，http状态为201
  #         数据库存储错误：返回http状态为500
  #         用户认证失败：返回http状态为401
  # 说明：params[:file]为需要上传的图片参数
  post '/' do
    @sale = Sale.new(params[:sale])
    @sale.user_id = @current_user.id

    if params[:file] && (tmpfile = params[:file][:tempfile]) && (name = params[:file][:filename])
      directory = "public/files"

      name_array = name.split('.')
      file_unique_name = name_array[0] + "_" + Time.now.to_i.to_s + rand(999999).to_s + "." + name_array[1]

      path = File.join(directory, file_unique_name)
      File.open(path, "wb") { |f| f.write(tmpfile.read)}
      size = File.new(path).size

      @picture = Picture.new(:name => name, :path => path, :size => size)

      @sale.pictures << @picture
    else
      @error = "No file selected"
    end
    
    if @sale.save
      status 201
	    value = sale_to_hash(@sale, 1)
      value["picture_ids"] = @sale.pictures.collect(&:id)
      value.to_json
    else
      status 500
    end
  end

  # 功能：更新一个待出的二手物品
  # 参数：params[:key] params[:sale]
  # 用法：http://localhost:3000/sales/1?key=5408afee03ca8c52a780570a4322cae3&sale[subject]=test&sale[description]=test...
  # 返回值：用户认证通过并且数据库存储成功：返回更新的待出二手物品json, http状态为202
  #         数据库存储错误：返回http状态为500
  #         用户认证失败：返回http状态为401
  #         待出二手物品不存在或已被删除：返回http状态为404
  put '/:id' do
    begin
      @sale = Sale.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      return status 404
    end
    if @sale.user_id == @current_user.id
      @sale.update_attributes(params[:sale])
      if @sale.save
        status 202
        value = sale_to_hash(@sale, 1)
        value["picture_ids"] = @sale.pictures.collect(&:id)
        value.to_json
      else
        status 500
      end
    else
      status 401
    end
  end

  # 功能：删除一个待出的二手物品
  # 参数：params[:key]
  # 用法：http://localhost:3000/sales/1?key=5408afee03ca8c52a780570a4322cae3
  # 返回值：用户认证通过并且删除成功：返回http状态为202
  #         用户认证失败：返回http状态为401
  #         待出二手物品不存在或已被删除：返回http状态为404
  delete '/:id' do
    if @sale.user_id == @current_user.id
      @sale.destroy
      status 202
    else
      status 401
    end
  end
end
