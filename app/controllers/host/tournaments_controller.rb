class Host::TournamentsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show, :count ]
  before_action :set_tournament, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_tournament, only: [ :new, :create ]
  before_action :authorize_existing_tournament, only: [ :edit, :update, :destroy ]
  include Pundit::Authorization


  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorized
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  rescue_from StandardError, with: :handle_internal_server_error


  def count
    authorize Tournament
    service = Host::TournamentService.new(current_user)
    total_tournaments = service.count

    render json: { total_tournaments: total_tournaments }
  end

  def index
    authorize Tournament
    service = Host::TournamentService.new(current_user)
    @tournaments = service.list_tournaments

    respond_to do |format|
      format.html
      format.json { render json: @tournaments, status: :ok }
    end
  end

  def show
    authorize @tournament

    respond_to do |format|
      format.html
      format.json { render json: @tournament, status: :ok }
    end
  end

  def new
    @tournament = Tournament.new
    authorize @tournament
  end

  def my_tournaments
    @tournaments = Tournament.where(host_id: current_user.id)
    authorize :tournament, :my_tournaments?
  end

  def create
    service = Host::TournamentService.new(current_user, tournament_params)
    result = service.create_tournament

    if result[:success]
      respond_to do |format|
        format.html { redirect_to host_tournament_path(result[:tournament]), notice: "Tournament created successfully!" }
        format.json { render json: result[:tournament], status: :created }
      end
    else
      handle_service_errors(result[:errors], :new)
    end
  end


  def edit
    authorize @tournament
  end


  def update
    authorize @tournament
    service = Host::TournamentService.new(current_user, tournament_params)
    result = service.update_tournament(@tournament)

    if result[:success]
      respond_to do |format|
        format.html { redirect_to host_tournament_path(result[:tournament]), notice: "Tournament updated successfully!" }
        format.json { render json: result[:tournament], status: :ok }
      end
    else
      handle_service_errors(result[:errors], :edit)
    end
  end


  def destroy
    authorize @tournament
    service = Host::TournamentService.new(current_user)
    result = service.delete_tournament(@tournament)

    if result[:success]
      respond_to do |format|
        format.html { redirect_to host_tournaments_path, notice: "Tournament deleted successfully!" }
        format.json { render json: { message: "Tournament deleted successfully!" }, status: :ok }
      end
    else
      handle_service_errors(result[:errors], :index, "Failed to delete tournament!")
    end
  end

  private


  def tournament_params
    params.require(:tournament).permit(:name, :location, :start_date)
  end

  def set_tournament
    @tournament = Host::TournamentService.new(current_user).find_tournament(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to host_tournaments_path, alert: "Tournament not found."
  end

  def authorize_tournament
    authorize Tournament
  rescue Pundit::NotAuthorizedError
    redirect_to root_path, alert: "You are not authorized to create a tournament."
  end

  def authorize_existing_tournament
    authorize @tournament
  rescue Pundit::NotAuthorizedError
    redirect_to root_path, alert: "You are not authorized to modify this tournament."
  end

  def handle_service_errors(errors, action, alert_message = nil)
    flash.now[:alert] = alert_message || errors.join(", ")

    respond_to do |format|
      format.html { render action, status: :unprocessable_entity }
      format.json { render json: { errors: errors }, status: :unprocessable_entity }
    end
  end

  def handle_record_not_found(exception)
    logger.error(exception.message)
    respond_to do |format|
      format.html { redirect_to host_tournaments_path, alert: "Tournament not found." }
      format.json { render json: { error: "Tournament not found" }, status: :not_found }
    end
  end

  def handle_unauthorized(exception)
    logger.warn(exception.message)
    respond_to do |format|
      format.html { redirect_to root_path, alert: "You are not authorized to perform this action." }
      format.json { render json: { error: "Not authorized" }, status: :forbidden }
    end
  end

  def handle_parameter_missing(exception)
    logger.error(exception.message)
    respond_to do |format|
      format.html { redirect_to root_path, alert: "Invalid parameters." }
      format.json { render json: { error: "Invalid parameters" }, status: :bad_request }
    end
  end

  def handle_internal_server_error(exception)
    logger.error("Internal Server Error: #{exception.message}")
    logger.error(exception.backtrace.join("\n"))
    respond_to do |format|
      format.html { redirect_to root_path, alert: "Something went wrong. Please try again later." }
      format.json { render json: { error: "Internal server error" }, status: :internal_server_error }
    end
  end
end
