class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :sync, :cycle_times, :wip]
  before_action :set_filter, only: [:cycle_times, :wip]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST /projects/1/sync
  # POST /projects/1/sync.json
  def sync
    job = SyncProjectJob.new
    job.async.sync_project(@project, params)
    render nothing: true
  end

  def cycle_times
    epics = @project.issues.includes(:issues).
        where(issue_type: 'Epic').
        select{ |epic| epic.cycle_time && @filter.allow_issue(epic) }.
        sort_by{ |epic| epic.completed }

    respond_to do |format|
      format.json { render json: epics.to_json(:methods => [:cycle_time, :issues]) }
    end
  end

  # GET /projects/1/wip_histories
  # GET /projects/1/wip_histories.json
  def wip
    history = @project.complete_wip_history.
        select{ |date, _| @filter.allow_date(date) }

    respond_to do |format|
      format.json { render json: history.to_json }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:domain, :board_id, :name)
    end

  def set_filter
    @filter = DateFilter.new(params[:filter] || "")
  end
end
