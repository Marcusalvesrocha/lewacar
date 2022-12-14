require 'qrcode_pix_ruby'

class MatchesController < ApplicationController
  before_action :set_ride, only: %i[new create]
  #after_action :qrcode_pix, only: %i[new]
  #after_action :can_matche?, only: :new

  def new
    if @ride.user.id == current_user.id
      redirect_to ride_path(@ride)
    else
      @matches = Match.where(ride_id: @ride) || Match.new
      @match = Match.new
      @can_match = can_match?
      qrcode_pix
      authorize @match
    end
  end

  def create
    @ride = Ride.find(params[:ride_id])
    @match = Match.new(match_params)
    @match.ride = @ride
    @match.user = current_user
    authorize @match
    if @match.save
      redirect_to ride_path(@ride)
      flash[:notice] = "Reserva Realizada!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def match_params
    params.require(:match).permit(:transaction_pix)
  end

  def set_ride
    @ride = Ride.find(params[:ride_id])
  end

  def can_match?
    @matches.each do |m|
      return false if m.user.id == current_user.id
    end
  end

  def qrcode_pix
    @pix = QrcodePixRuby::Payload.new(
      pix_key:        @ride.user.email,
      merchant_name:  @ride.user.first_name,
      merchant_city:  'Brasil',
      country_code:   'BR',
      currency:       '986',
      amount:         @ride.price,
      repeatable:     false
    )
  end

end
