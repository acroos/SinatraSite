require 'rubygems'
require 'sinatra'
require 'mongo'
require 'mongo_mapper'
# require 'data_mapper'

SITE_TITLE = "Austin C. Roos"
SITE_PASSWORD = "a"

configure do 
	MongoMapper.database = 'projects'
end

# DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/acr.db")

class Job
  include MongoMapper::Document
  key :id,				Integer
  key :company_name, 	String
  key :job_title, 		String
  key :start_date, 		String
  key :end_date, 		String
  key :desc, 			String
end

class Project
  include MongoMapper::Document
  key :name, 		String
  key :description, String
  key :content, 	String
  key :created_at, 	Time
end

# DataMapper.finalize.auto_upgrade!

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
	erb :Work
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
	@project = Project.where :id=>params[:id]
	@title = @project.name
	if @project
		erb :project
	else
		redirect '/'
	end
end

get '/contact' do
	@title = 'Contact'
	erb :contact
end

get '/add' do
	@title = "Admin only"
	erb :add_project
end

post '/add' do
	@p = Project.new
	@p.name        = params[:name]
	@p.description = params[:description]
	@p.content     = params[:content]
	@p.created_at  = Time.now
	if params[:password] == SITE_PASSWORD
		@p.save
		redirect '/projects'
	else
		redirect '/add'
	end
end

get '/edit/:id' do
	@project = Project.get params[:id]
	@title = "Edit project #{params[:name]}"
	if @project
		erb :edit
	else 
		redirect '/'
	end
end

put '/edit/:id' do
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