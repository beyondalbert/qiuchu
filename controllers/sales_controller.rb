class SalesController < ApplicationController

  before do
    content_type :json
    @current_user ||= User.find_by_token(params[:key]) unless params[:key].nil?
    error 401 unless @current_user
  end

  before '/:id' do
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
    Sale.where(:user_id => @current_user.id).to_json
  end

  # 功能：返回某个特定待出的二手物品
  # 参数：params[:key]
  # 用法：http://localhost:3000/sales/1?key=5408afee03ca8c52a780570a4322cae3
  # 返回值：用户认证通过：返回id为1的二手物品json
  #         用户认证失败：返回http状态为401
  #         二手物品不存在或已被删除：返回http状态为404
  get '/:id' do
    @sale.to_json
  end

  # 功能：新发布一个要出的二手物品
  # 参数：params[:key] params[:sale]
  # 用法：http://localhost:3000/sales?key=5408afee03ca8c52a780570a4322cae3&sale[subject]=test&sale[description]=test...
  # 返回值：用户认证通过并且数据库存储成功：返回新发布的待出二手物品json，http状态为201
  #         数据库存储错误：返回http状态为500
  #         用户认证失败：返回http状态为401
  post '/' do
    @sale = Sale.new(params[:sale])
    @sale.user_id = @current_user.id
    if @sale.save
      status 201
	    @sale.to_json
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
        @sale.to_json
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
      @sale.delete
      status 202
    else
      status 401
    end
  end
end
