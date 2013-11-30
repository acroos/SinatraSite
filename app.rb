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

class Job
  include MongoMapper::Document
  key :order,			Integer
  key :company_name, 	String
  key :job_title, 		String
  key :start_date, 		Time
  key :end_date, 		Time
  key :desc, 			Array
end

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
	@title = 'Home'
	erb :home
end

get '/work' do
	@title = 'Work'
	@jobs = Job.sort :id.desc
	erb :work
end

get '/school' do
	@title = 'School'
	erb :school
end

get '/projects' do
	@projects = Project.sort :id.desc
	@title = 'Projects'
	if @projects.empty?
		redirect '/'
	else
		erb :projects
	end
end

get '/projects/:id' do
	@project = Project.find_by_id params[:id]
	@title = @project.name
	if @project
		erb :project
	else
		redirect '/'
	end
end

get '/work/:id' do
	@job = Job.find_by_id params[:id]
	@title = @job.company_name
	if @job
		erb :job
	else
		redirect '/'
	end
end

get '/contact' do
	@title = 'Contact'
	erb :contact
end

get '/add-job' do
	@title = "Admin only"
	erb :add_job
end

post '/add-job' do
	@p = Job.new
	@p.company_name 	= params[:company_name]
	@p.job_title 		= params[:job_title]
	@p.start_date     	= DateTime.parse(params[:start_date])
	@p.end_date  		= DateTime.parse(params[:end_date])
	@p.desc 			= params[:desc].each.split '.  ' do |d|
		@p.desc.push d
	end
	if params[:password] == SITE_PASSWORD
		@p.save
		redirect '/work'
	else
		redirect '/add-job'
	end
end

get '/add-project' do
	@title = "Admin only"
	erb :add_project
end

post '/add-project' do
	@j = Project.new
	@j.name        = params[:name]
	@j.description = params[:description]
	@j.content     = params[:content]
	@j.created_at  = Time.now
	if params[:password] == SITE_PASSWORD
		@j.save
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