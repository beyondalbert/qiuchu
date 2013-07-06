class WantsController < ApplicationController
  helpers WantsHelper
  before do
    content_type :json
    @current_user ||= User.find_by_token(params[:key]) unless params[:key].nil?
    error 401 unless @current_user
  end

  before '/:id' do
    begin
      @want = Want.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      return status 404
    end
  end

  # 功能：返回自己在求的二手物品
  # 参数：params[:key]
  # 用法：http://localhost:3000/wants?key=5408afee03ca8c52a780570a4322cae3
  # 返回值：用户认证通过：返回用户自己要求的二手物品json
  #         用户认证失败：返回http状态为401
  get '/' do 
    values = []
    @wants = Want.where(:user_id => @current_user.id)
    @wants.each do |want|
      tmp = want_to_hash(want, 2)
      values << tmp
    end
    values.to_json
  end

  # 功能：返回某在求的二手物品
  # 参数：params[:key]
  # 用法：http://localhost:3000/wants/1?key=5408afee03ca8c52a780570a4322cae3
  # 返回值：用户认证通过：返回id为1的在求的物品json
  #         用户认证失败：返回http状态为401
  #         在求物品不存在或已被删除：返回http状态为404
  get '/:id' do
    value = want_to_hash(@want, 1)
    value.to_json
  end

  # 功能：新发布一个要求的二手物品
  # 参数：params[:key] params[:want]
  # 用法：http://localhost:3000/wants?key=5408afee03ca8c52a780570a4322cae3&want[subject]=test&want[description]=test...
  # 返回值：用户认证通过并且数据库存储成功：返回新发布的要求的二手物品json，http状态为201
  #         数据库存储错误：返回http状态为500
  #         用户认证失败：返回http状态为401
  post '/' do
    @want = Want.new(params[:want])
    @want.user_id = @current_user.id
    if @want.save
      status 201
      value = want_to_hash(@want, 1)
      value.to_json
    else
      status 500
    end
  end

  # 功能：更新一个在求的二手物品
  # 参数：params[:key] params[:want]
  # 用法：http://localhost:3000/wants/1?key=5408afee03ca8c52a780570a4322cae3&want[subject]=test&want[description]=test...
  # 返回值：用户认证通过并且数据库存储成功：返回更新的在求的二手物品json, http状态为202
  #         数据库存储错误：返回http状态为500
  #         用户认证失败：返回http状态为401
  #         在求二手物品不存在或已被删除：返回http状态为404
  put '/:id' do
    begin
      @want = Want.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      return status 404
    end
    if @sale.user_id == @current_user.id
      @want.update_attributes(params[:want])
      if @want.save
        status 202
        value = want_to_hash(@want, 1)
        value.to_json
      else
        status 401
      end
    else
      status 401
    end
  end

  # 功能：删除一个在求的二手物品
  # 参数：params[:key]
  # 用法：http://localhost:3000/wants/1?key=5408afee03ca8c52a780570a4322cae3
  # 返回值：用户认证通过并且删除成功：返回http状态为202
  #         用户认证失败：返回http状态为401
  #         在求二手物品不存在或已被删除：返回http状态为404
  delete '/:id' do
    if @sale.user_id == @current_user.id
      @want.destroy
      status 202
    else
      status 401
    end
  end
end
