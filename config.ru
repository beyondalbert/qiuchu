require 'sinatra/base'
require 'sinatra/activerecord'
require './helpers/application_helper.rb'
require './controllers/application_controller.rb'

Dir.glob('./{helpers,controllers,models}/*.rb').each {|file| require file}

map('/sales') { run SalesController }
map('/wants') { run WantsController }
map('/users') { run UsersController }
map('/pictures') { run PicturesController }
map('/') { run ApplicationController }
