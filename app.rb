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
  key :order,				Integer
  key :name,				String
  key :description,	String
  key :content,			Array
  key :created_at,	Time
  key :pics,				Array 
end

class Job
	include MongoMapper::Document
	key :order,				Integer
	key :name,				String
	key :description,	Array
	key :start_date,	String
	key :end_date,		String
end


helpers do 
	include Rack::Utils
	alias_method :h, :escape_html
end

def split_paragraphs(text)
	items = Array.new
	text.split('\r\n').each do |paragraph|
		items.push paragraph
	end
	return items
end

get '/welcome' do 
		@title = 'Welcome'
		erb :welcome, :layout => :layout_welcome
end

get '/' do
	redirect '/index.html'
end

['/index', '/index.html'].each do |path|
	get path do
		@header = 'Austin C. Roos'
		@title = 'Home'
		@label = 'Home'
		erb :home
	end
end

['/about', '/about.html'].each do |path|
	get path do
		@header = 'About Me'
		@title = 'About Me'
		@label = 'About'
		erb :about
	end
end

get '/experience/?' do
	@header = 'Experience'
	@title = 'Experience'
	@label = 'Experience'
	erb :experience
end

get '/experience/:id' do
	@job = Job.find_by_id params[:id]
	@header = @job.name
	@title = @job.name
	@label = 'Experience'
	if @job
		erb :job 
	else
		redirect '/'
	end
end

get '/projects/?' do
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

['/contact', '/contact.html'].each do |path|
	get path do
		@title = 'Contact'
		@label = 'Contact'
		erb :contact
	end
end

get '/add-project' do
	if settings.development?
		@title = "Admin only"
		erb :add_project
	else
		redirect '/'
	end
end

post '/add-project' do
	@p = Project.new
	@p.name        = params[:name]
	@p.description = params[:description]
	@p.content     = split_paragraphs(params[:content])
	@p.order	   = params[:order].to_i
	@p.created_at  = Time.now
	if params[:password] == SITE_PASSWORD
		@p.save
		redirect '/projects'
	else
		redirect '/add-project'
	end
end

not_found do
	halt 404, 'this page does not exist'
end