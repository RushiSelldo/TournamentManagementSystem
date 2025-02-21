class Host::TournamentsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_tournament, only: [ :show, :edit, :update, :destroy ]
  # before_action :authorize_tournament, only: [:new, :create]

  def index
    @tournaments = Tournament.all

    respond_to do |format|
      format.html { render :index }
      format.json { render json: @tournaments }
    end
  end

  def show
    respond_to do |format|
      format.html { render :show }
      format.json { render json: @tournament }
    end
  end

  def new
    @tournament = Tournament.new
    # authorize @tournament
  end

  def create
    @tournament = current_user.hosted_tournaments.build(tournament_params)
    # authorize @tournament

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

  def edit
    # authorize @tournament
  end

  def update
    # authorize @tournament
    if @tournament.update(tournament_params)
      respond_to do |format|
        format.html { redirect_to host_tournament_path(@tournament), notice: "Tournament updated successfully!" }
        format.json { render json: @tournament }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: { errors: @tournament.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    # authorize @tournament
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
    authorize Tournament.new
  end
end
