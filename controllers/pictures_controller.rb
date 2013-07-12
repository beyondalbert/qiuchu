class PicturesController < ApplicationController
  
  before do
    content_type :json
    @current_user ||= User.find_by_token(params[:key]) unless params[:key].nil?
    error 401 unless @current_user
  end

  # 功能：用于给指定的资源添加一个图片
  # 参数：params[:key] params[:item_id] params[:item_type] params[:file]
  # 用法：http://localhost:3000/pictures?key=5408afee03ca8c52a780570a4322cae3
  # 返回值：用户认证失败：返回401
  #        下载成功：    返回200
  # 说明：资源包括要出的物品（Sale）、要求的物品（Want）和用户（User）
  post '/' do
	  case params[:item_type]
	  when "Sale"
	    @item = Sale.find(params[:item_id])
		directory = "public/files/sales"
	    return status 401 if @item.user_id != @current_user.id
	  when "Want"
	    @item = Want.find(params[:item_id])
		directory = "public/files/wants"
	    return status 401 if @item.user_id != @current_user.id
	  when "User"
	    @item = User.find(params[:item_id])
		directory = "public/files/users"
	    return status 401 if @item.id != @current_user.id
      end
	
	  if params[:file] && (tmpfile = params[:file][:tempfile]) && (name = params[:file][:filename])

      name_array = name.split('.')
      file_unique_name = name_array[0] + "_" + Time.now.to_i.to_s + rand(999999).to_s + "." + name_array[1]

      path = File.join(directory, file_unique_name)
      File.open(path, "wb") { |f| f.write(tmpfile.read)}
      size = File.new(path).size

      @picture = Picture.new(:name => name, :path => path, :size => size)

	    if params[:item_type] == "User"
        if !@item.picture.nil?
	        @item.picture.destroy
        end
        @item.picture = @picture
	    else
        @item.pictures << @picture
	    end
    else
      @error = "No file selected"
    end

	  if @item.save
	    status 201
	  else
	    status 500
	  end
  end


  # 功能：用于图片的下载的URL
  # 参数：params[:key] params[:size]
  # 用法：http://localhost:3000/pictures/1?key=5408afee03ca8c52a780570a4322cae3
  # 返回值：用户认证失败：返回401
  #        下载成功：    返回200
  # 说明：parmas[:size]用于控制下载图片的尺寸，为空时，返回原图片，为small时，返回50x50大小的缩略图
  get '/:id' do
    @picture = Picture.find(params[:id])
    if params[:size] == "small"
      image = MiniMagick::Image.open(@picture.path)
      image.resize "50x50"
      image.write "public/files/tmp/#{@picture.name}"
      send_file "public/files/tmp/#{@picture.name}"
    else
      send_file @picture.path, :filename => @picture.name, :type => :jpg
    end
  end

  # 功能：用于图片的删除
  # 参数：params[:key]
  # 用法：http://localhost:3000/pictures/1?key=5408afee03ca8c52a780570a4322cae3
  # 返回值：用户认证失败：返回401
  #        删除成功：    返回200
  delete '/:id' do
    @picture = Picture.find(params[:id])
    if @picture.item.user_id == @current_user.id
      @picture.destroy
      status 202
    else
      status 401
    end
  end
end
