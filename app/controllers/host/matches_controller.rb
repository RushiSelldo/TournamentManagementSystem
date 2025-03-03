class Host::MatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tournament
  before_action :set_match, only: [ :edit, :update, :destroy ]
  before_action :authorize_match, only: [ :new, :create, :edit, :update, :destroy ]

  def new
    @match = @tournament.matches.new
  end

  def create
    @match = @tournament.matches.new(match_params)

    if @match.save
      redirect_to host_tournament_path(@tournament), notice: "Match created successfully."
    else
      puts @match.errors.full_messages # 👈 Debugging step: prints errors in logs
      render :new, status: :unprocessable_entity
    end
  end


  def edit; end

  def update
    if @match.update(match_params)
      redirect_to host_tournament_path(@tournament), notice: "Match updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @match.destroy
    redirect_to host_tournament_path(@tournament), notice: "Match deleted successfully."
  end

  private

  def set_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end

  def set_match
    @match = @tournament.matches.find(params[:id])
  end

  def match_params
    params.require(:match).permit(:team_1_id, :team_2_id, :scheduled_at, :score_team_1, :score_team_2)
  end

  def authorize_match
    authorize @match || Match.new(tournament: @tournament)
  end
end
