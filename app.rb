require 'rubygems'
require 'sinatra'
require 'mongo'
require 'mongo_mapper'
require 'date'

SITE_TITLE = "Austin C. Roos"
SITE_PASSWORD = "a"
MONGOLAB_URI = "mongodb://acr:soapy323@ds039507.mongolab.com:39507/acr-site"

regex_match = /.*:\/\/(.*):(.*)@(.*):(.*)\//.match(MONGOLAB_URI)
host = "ds039507.mongolab.com"
port = "39507"
db_name = "acr-site"
user = "acr"
pw = "soapy323"

MongoMapper.connection = Mongo::Connection.new(host, port)
MongoMapper.database = db_name
MongoMapper.database.authenticate(user, pw)

class Project
  include MongoMapper::Document
  key :order,		Integer
  key :name, 		String
  key :description, String
  key :content, 	String
  key :created_at, 	Time
  key :pics, 		Array 
end

helpers do 
	include Rack::Utils
	alias_method :h, :escape_html
end

get '/' do
	@header = 'Austin C. Roos'
	@title = 'Home'
	@label = 'Home'
	erb :home
end

get '/about' do
	@header = 'About Me'
	@title = 'About Me'
	@label = 'About'
	erb :About
end

get '/projects' do
	@projects = Project.sort(:created_at.desc)
	@header = 'Projects'
	@title = 'Projects'
	@label = 'Projects'
	if @projects.empty?
		redirect '/'
	else
		erb :projects
	end
end

get '/projects/:id' do
	@project = Project.find_by_id params[:id]
	@header = @project.name
	@title = @project.name
	@label = 'Projects'
	if @project
		erb :project
	else
		redirect '/'
	end
end

get '/contact' do
	@title = 'Contact'
	@label = 'Contact'
	erb :contact
end

get '/add-project' do
	@title = "Admin only"
	erb :add_project
end

post '/add-project' do
	@p = Project.new
	@p.name        = params[:name]
	@p.description = params[:description]
	@p.content     = params[:content]
	@p.order	   = params[:order].to_i
	@p.created_at  = Time.now
	if params[:password] == SITE_PASSWORD
		@p.save
		redirect '/projects'
	else
		redirect '/add-project'
	end
end

get '/edit/project/:id' do
	@project = Project.get params[:id]
	@title = "Edit project #{params[:name]}"
	if @project
		erb :edit
	else 
		redirect '/'
	end
end

put '/edit/project/:id' do
	p = Project.get params[:id]
	unless p
		redirect '/'
	end
	p.name = params[:name]
	p.description = params[:description]
	p.content = params[:content]
	p.created_at = Time.now
	if params[:password] == SITE_PASSWORD
		p.save
		redirect '/projects'
	else
		redirect '/edit/:id'
	end
end

not_found do
	halt 404, 'this page does not exist'
end