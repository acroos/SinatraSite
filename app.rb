require 'rubygems'
require 'sinatra'
require 'data_mapper'

SITE_TITLE = "Austin C. Roos"
SITE_PASSWORD = "WhoTheWhoTheFuckAskedYouNiggas"

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/acr.db")

class Job
  include DataMapper::Resource
  property :id, Serial
  property :company_name, Text, :required => true
  property :job_title, Text, :required => true
  property :start_date, Text, :required => true
  property :end_date, Text, :required => true
  property :desc, Text, :required => true
end

class Project
  include DataMapper::Resource
  property :id, Serial
  property :name, Text, :required => true
  property :description, Text, :required => true
  property :content, Text, :required => true
  property :created_at, DateTime
end

DataMapper.finalize.auto_upgrade!

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
	@jobs = Job.all :order => :id.desc
	erb :Work
end

get '/school' do
	@title = 'School'
	erb :school
end

get '/projects' do
	@projects = Project.all :order => :id.desc
	@title = 'Projects'
	if @projects.empty?
		redirect '/'
	else
		erb :projects
	end
end

get '/projects/:id' do
	@project = Project.get params[:id]
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
	p = Project.new
	p.name        = params[:name]
	p.description = params[:description]
	p.content     = params[:content]
	p.created_at  = Time.now
	if params[:password] == SITE_PASSWORD
		p.save
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