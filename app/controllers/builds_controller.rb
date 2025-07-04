class BuildsController < ApplicationController
  before_action :find_project_by_project_id
  before_action :authorize
  before_action :find_build, only: [:edit, :update, :destroy]

  #def index
  #  @limit = per_page_option
  #  @builds_count = @project.builds.count
  #  @builds_pages = Paginator.new @builds_count, @limit, params['page']
  #  @offset = @builds_pages.offset
  #  @builds = @project.builds.includes(:project).sorted.limit(@limit).offset(@offset)
  #end

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
  end
  
  def new
    @build = @project.builds.build
  end

  def create
    @build = @project.builds.build(build_params)
    if @build.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to project_builds_path(@project)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @build.update(build_params)
      flash[:notice] = l(:notice_successful_update)
      redirect_to project_builds_path(@project)
    else
      render :edit
    end
  end

  def destroy
    @build.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to project_builds_path(@project)
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
    params.require(:build).permit(:name)
  end
end