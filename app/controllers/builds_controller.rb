class BuildsController < ApplicationController
  accept_api_auth :index, :show, :create, :update, :destroy
  before_action :find_project_by_project_id
  before_action :authorize
  before_action :find_build, only: [:show, :edit, :update, :destroy]
  
  
  def index
    @limit = per_page_option
    @project_and_ancestors = @project.self_and_ancestors
    @builds_scope = Build.where(project_id: @project_and_ancestors.map(&:id))
    @builds_count = @builds_scope.count
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
      format.json { render json: @builds.map { |build| build_to_api_json(build) } }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.api
      format.json { render json: build_to_api_json(@build) }
    end
  end
  
  def new
    @build = @project.builds.build
  end

   def create
    @build = @project.builds.build
    @build.safe_attributes = build_params

    respond_to do |format|
      if @build.save
        format.html {
          flash[:notice] = l(:notice_successful_create)
          redirect_to project_builds_path(@project)
        }
        format.api  { render action: 'show', status: :created, location: project_build_url(@project, @build) }
        format.json { render json: build_to_api_json(@build), status: :created }
      else
        format.html { render action: 'new' }
        format.api  { render_validation_errors(@build) }
        format.json { render json: @build.errors, status: :unprocessable_entity }
      end
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

  private

  def find_build
    @build = @project.builds.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def build_params
    params.require(:build).permit(:name, :project_id)
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