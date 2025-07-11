class BuildsController < ApplicationController
  accept_api_auth :index, :show, :create, :update, :destroy
  before_action :find_project_by_project_id, except: [:index, :create, :show]
  before_action :find_optional_project, only: [:index]
  before_action :find_project_for_create, only: [:create, :new]
  before_action :authorize, except: [:index, :show]
  before_action :find_build, only: [:show, :edit, :update, :destroy]

  
  def new
    @build = @project ? @project.builds.build : Build.new
    return render_403 unless User.current.allowed_to?(:create_builds, @project)
  end
  
  def index
  @builds_scope = if params[:project_id].present?
    project = Project.find(params[:project_id])
    if params[:only_project] == '1'
      project.builds
    else
      project.all_builds
    end
  else
    Build.all
  end

  if params[:name].present?
    @builds_scope = @builds_scope.where("LOWER(#{Build.table_name}.name) LIKE LOWER(?)", "%#{params[:name]}%")
  end

  @builds_count = @builds_scope.count
  @limit = per_page_option
  @builds_pages = Paginator.new @builds_count, @limit, params['page']
  @offset = @builds_pages.offset

  @builds = @builds_scope
    .includes(:project)
    .sorted
    .limit(@limit)
    .offset(@offset)

  respond_to do |format|
    format.html
    format.api
    format.json { render json: { builds: @builds.map { |build| build_to_api_json(build) }, total_count: @builds_count } }
  end
end

  def update
    @build.safe_attributes = build_params

    respond_to do |format|
      if @build.save
        format.html {
          flash[:notice] = l(:notice_successful_update)
          redirect_to project_builds_path(@project)
        }
        format.api  { render_api_ok }
        format.json { render json: build_to_api_json(@build) }
      else
        format.html { render action: 'edit' }
        format.api  { render_validation_errors(@build) }
        format.json { render json: @build.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @build.destroy

    respond_to do |format|
      format.html {
        flash[:notice] = l(:notice_successful_delete)
        redirect_to project_builds_path(@project)
      }
      format.api  { render_api_ok }
      format.json { head :no_content }
    end
  end

  def auto_complete
    @builds = @project.all_builds
    if params[:term].present?
      @builds = @builds.where("LOWER(name) LIKE LOWER(?)", "%#{params[:term]}%")
    end
    @builds = @builds.order(:name).limit(30)

    render json: {
      builds: @builds.map { |build| { id: build.id, name: build.name_with_project } },
      total_count: @builds.count
    }
  end
  
#  def create
#    @build = Build.new
#    @build.safe_attributes = build_params
#    @build.project_id = params[:build][:project_id] if params[:build]
#
#    respond_to do |format|
#      if @build.save
#        format.html {
#          flash[:notice] = l(:notice_successful_create)
#          redirect_to project_builds_path(@build.project)
#        }
#        format.api { render action: 'show', status: :created, location: build_url(@build) }
#        format.json { render json: build_to_api_json(@build), status: :created }
#      else
#        format.html { 
#          @project = @build.project
#          render action: 'new' 
#        }
#        format.api { render_validation_errors(@build) }
#        format.json { render json: @build.errors, status: :unprocessable_entity }
#      end
#    end
#  end
#   def create
#    @build = Build.new
#    @build.safe_attributes = build_params
#    @build.project = @project if @project
#
#    return render_403 unless User.current.allowed_to?(:create_builds, @build.project)
#
#    respond_to do |format|
#      if @build.save
#        format.html {
#          flash[:notice] = l(:notice_successful_create)
#          redirect_to project_builds_path(@build.project)
#        }
#        format.api { render action: 'show', status: :created, location: build_url(@build) }
#        format.json { render json: build_to_api_json(@build), status: :created }
#      else
#        format.html { 
#          @project = @build.project
#          render action: 'new' 
#        }
#        format.api { render_validation_errors(@build) }
#        format.json { render json: @build.errors, status: :unprocessable_entity }
#      end
#    end
#  end

  def create
    @build = Build.new
    @build.safe_attributes = params[:build]
    
    if api_request?
      @build.project_id = params[:build][:project_id] if params[:build]
    else
      @build.project = @project
    end
  
    return render_403 unless User.current.allowed_to?(:create_builds, @build.project)
  
    respond_to do |format|
      if @build.save
        format.html {
          flash[:notice] = l(:notice_successful_create)
          redirect_to project_builds_path(@build.project)
        }
        format.api { render action: 'show', status: :created, location: build_url(@build) }
        format.json { render json: build_to_api_json(@build), status: :created }
      else
        format.html { 
          render action: 'new' 
        }
        format.api { render_validation_errors(@build) }
        format.json { render json: @build.errors, status: :unprocessable_entity }
      end
    end
  end
  
  private
  
  def find_optional_project
    @project = Project.find(params[:project_id]) if params[:project_id]
  end
  
  def authorize_global
    true
  end
  
  
  def find_project_for_create
    if api_request?
      project_id = params[:build][:project_id] if params[:build]
      @project = Project.find(project_id) if project_id
    else
      @project = Project.find(params[:project_id]) if params[:project_id]
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def filters_params
    {
      name: params[:name],
      only_project: params[:only_project],
      created_at_from: params[:created_at_from],
      created_at_to: params[:created_at_to],
      updated_at_from: params[:updated_at_from],
      updated_at_to: params[:updated_at_to]
    }.delete_if { |k, v| v.blank? }
    
  end
  
  def find_build
    @build = @project.builds.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def build_params
    if api_request?
      params.require(:build).permit(:name, :project_id)
    else
      params.require(:build).permit(:name)
    end
  end

  #def build_params
  #  params.require(:build).permit(:name)
  #end

  def build_to_api_json(build)
    {
      id: build.id,
      project_id: build.project_id,
      name: build.name,
      created_on: build.created_at,
      updated_on: build.updated_at,
      project: {
        id: build.project.id,
        name: build.project.name
      }
    }
  end
end