class DomainsController < ApplicationController
  before_action :set_domain, only: [:show, :edit, :update, :destroy, :sync, :dashboards]

  # GET /domains
  # GET /domains.json
  def index
    @domains = Domain.all
  end

  # GET /domains/1
  # GET /domains/1.json
  def show
  end

  # GET /domains/new
  def new
    @domain = Domain.new
  end

  # GET /domains/1/edit
  def edit
  end

  # POST /domains
  # POST /domains.json
  def create
    @domain = Domain.new(domain_params)

    respond_to do |format|
      if @domain.save
        format.html { redirect_to @domain, notice: 'Domain was successfully created.' }
        format.json { render :show, status: :created, location: @domain }
      else
        format.html { render :new }
        format.json { render json: @domain.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /domains/1
  # PATCH/PUT /domains/1.json
  def update
    respond_to do |format|
      if @domain.update(domain_params)
        format.html { redirect_to @domain, notice: 'Domain was successfully updated.' }
        format.json { render :show, status: :ok, location: @domain }
      else
        format.html { render :edit }
        format.json { render json: @domain.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /domains/1
  # DELETE /domains/1.json
  def destroy
    @domain.destroy
    respond_to do |format|
      format.html { redirect_to domains_url, notice: 'Domain was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def sync
    client = Jira::Client.new(@domain.domain, params.permit(:username, :password))
    pending_dashboards = @domain.dashboards.to_a
    client.get_rapid_boards.each do |rapid_board|
      dashboard = Dashboard.find_or_initialize_by(board_id: rapid_board.id, domain_id: @domain.id)
      dashboard.name = rapid_board.name
      dashboard.domain = @domain
      dashboard.save
      pending_dashboards.delete(dashboard)
    end

    pending_dashboards.each do |dashboard|
      dashboard.destroy
    end

    @domain.last_synced = DateTime.now
    @domain.save

    respond_to do |format|
      format.html { redirect_to @domain }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_domain
      @domain = Domain.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def domain_params
      params.require(:domain).permit(:name, :domain, :last_synced)
    end
end
