class Host::MatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tournament
  before_action :set_match, only: [ :edit, :update, :destroy ]
  before_action :authorize_match, only: [ :new, :create, :edit, :update, :destroy ]


  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorized
  rescue_from StandardError, with: :handle_internal_server_error

  def new
    @match = @tournament.matches.new
  end

  def create
    service = Host::MatchService.new(@tournament, match_params)
    result = service.create_match

    if result[:success]
      redirect_to host_tournament_path(@tournament), notice: "Match created successfully."
    else
      flash.now[:alert] = result[:errors].join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    service = Host::MatchService.new(@tournament, match_params)
    result = service.update_match(@match)

    if result[:success]
      redirect_to host_tournament_path(@tournament), notice: "Match updated successfully."
    else
      flash.now[:alert] = result[:errors].join(", ")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    service = Host::MatchService.new(@tournament)
    result = service.delete_match(@match)

    if result[:success]
      redirect_to host_tournament_path(@tournament), notice: "Match deleted successfully."
    else
      redirect_to host_tournament_path(@tournament), alert: result[:errors].join(", ")
    end
  end

  private

  def set_tournament
    @tournament = Tournament.find(params[:tournament_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Tournament not found."
  end

  def set_match
    @match = Host::MatchService.new(@tournament).find_match(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to host_tournament_path(@tournament), alert: "Match not found."
  end

  def match_params
    params.require(:match).permit(:team_1_id, :team_2_id, :scheduled_at, :score_team_1, :score_team_2)
  rescue ActionController::ParameterMissing
    flash.now[:alert] = "Invalid match parameters."
    render :new, status: :unprocessable_entity
  end

  def authorize_match
    authorize @match || Match.new(tournament: @tournament)
  rescue Pundit::NotAuthorizedError
    redirect_to root_path, alert: "You are not authorized to perform this action."
  end


  def handle_record_not_found(exception)
    logger.error(exception.message)
    redirect_to root_path, alert: "Record not found."
  end

  def handle_unauthorized(exception)
    logger.warn(exception.message)
    redirect_to root_path, alert: "You are not authorized to access this page."
  end

  def handle_internal_server_error(exception)
    logger.error("Internal Server Error: #{exception.message}")
    logger.error(exception.backtrace.join("\n"))
    redirect_to root_path, alert: "Something went wrong. Please try again later."
  end
end
