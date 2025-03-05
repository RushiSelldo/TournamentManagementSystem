
class Host::TournamentsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show, :count ]
  before_action :set_tournament, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_tournament, only: [ :new, :create ]
  before_action :authorize_existing_tournament, only: [ :edit, :update, :destroy ]
  include Pundit::Authorization
  def count
    authorize Tournament # Ensure public access
    total_tournaments = Tournament.count
    render json: { total_tournaments: total_tournaments }
  end

  # def size
  #   authorize Tournament # Ensure public access
  #   total_tournaments = Tournament.count
  #   render json: { total_tournaments: total_tournaments }
  # end

  def index
    @tournaments = Tournament.order(created_at: :desc) # Newest first
    authorize Tournament

    respond_to do |format|
      format.html { render :index }
      format.json { render json: @tournaments }
    end
  end

  def show
    authorize @tournament

    respond_to do |format|
      format.html { render :show }
      format.json { render json: @tournament }
    end
  end

  def new
    @tournament = Tournament.new
    authorize @tournament
  end

  def create
    @tournament = current_user.hosted_tournaments.build(tournament_params)
    authorize @tournament

    if @tournament.save
      respond_to do |format|
        format.html { redirect_to host_tournament_path(@tournament), notice: "Tournament created successfully!" }
        format.json { render json: @tournament, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: { errors: @tournament.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # def edit
  #   authorize @tournament
  # end

  # def update
  #   authorize @tournament
  #   if @tournament.update(tournament_params)
  #     respond_to do |format|
  #       format.html { redirect_to host_tournament_path(@tournament), notice: "Tournament updated successfully!" }
  #       format.json { render json: @tournament }
  #     end
  #   else
  #     respond_to do |format|
  #       format.html { render :edit }
  #       format.json { render json: { errors: @tournament.errors.full_messages }, status: :unprocessable_entity }
  #     end
  #   end
  # end


  def edit
    @tournament = Tournament.find(params[:id])
    authorize @tournament # Ensure user is authorized to edit
  rescue Pundit::NotAuthorizedError
    redirect_to root_path, alert: "You are not authorized to edit this tournament."
  end

  def update
    @tournament = Tournament.find_by(id: params[:id])

    unless @tournament
      redirect_to host_tournaments_path, alert: "Tournament not found!" and return
    end

    authorize @tournament

    if @tournament.update(tournament_params)
      respond_to do |format|
        format.html { redirect_to host_tournament_path(@tournament), notice: "Tournament updated successfully!" }
        format.json { render json: @tournament }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @tournament.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  rescue Pundit::NotAuthorizedError
    redirect_to root_path, alert: "You are not authorized to update this tournament."
  end



  def destroy
    authorize @tournament

    if @tournament.destroy
      respond_to do |format|
        format.html { redirect_to host_tournaments_path, notice: "Tournament deleted successfully!" }
        format.json { render json: { message: "Tournament deleted successfully!" }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to host_tournaments_path, alert: "Failed to delete tournament!" }
        format.json { render json: { errors: @tournament.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_tournament
    @tournament = Tournament.find(params[:id])
  end

  def tournament_params
    params.require(:tournament).permit(:name, :location, :start_date)
  end

  def authorize_tournament
    authorize Tournament
  end

  def authorize_existing_tournament
    authorize @tournament
  end
end
