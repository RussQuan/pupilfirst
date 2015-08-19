class IncubationController < ApplicationController
  before_action :authenticate_user!
  before_action :ready_for_incubation_wizard?
  before_action :authorize_step!

  include Wicked::Wizard

  steps 'user_profile', 'startup_profile', 'launch'

  def show
    return if prevent_repeat!

    @startup = current_user.startup
    @user = current_user
    render_wizard
  end

  def update
    return if prevent_repeat!

    @startup = current_user.startup
    @user = current_user

    # Save update_from so as to use for conditional validations during params update.
    @startup.updated_from = step
    @startup.save! validate: false

    # Update startup (and user) with received params.
    if @startup.update(incubation_startup_params)
      # Finish the incubation flow if submitting from startup profile page.
      if step == 'startup_profile'
        @startup.finish_incubation_flow!
      end
    end

    render_wizard @startup
  end

  # Wicked uses this method to find out where to redirect to once the wizard finishes.
  def finish_wizard_path
    current_user.startup
  end

  # Attempt to a co-founder, and return to the launch page.
  def add_cofounder
    begin
      current_user.add_as_founder_to_startup!(params[:cofounder][:email])
    rescue Exceptions::UserNotFound
      flash[:error] = "Couldn't find a user with the SV ID you supplied. Please verify founder's registered email address."
    rescue Exceptions::UserAlreadyMemberOfStartup
      flash[:info] = 'The SV ID you supplied is already linked to your startup!'
    rescue Exceptions:: UserAlreadyHasStartup
      flash[:notice] = 'The SV ID you supplied is already linked to another startup. Are you sure you have the right e-mail address?'
    else
      flash[:success] = "SV ID #{params[:email]} has been linked to your startup as founder."
    end

    redirect_to incubation_path(:launch)
  end

  private

  def incubation_startup_params
    params.require(:startup).permit(:name, :registration_type, :about, :incubation_location, :website,
      :presentation_link, :team_size, :women_employees, :updated_from,  { category_ids: [] }, admin_attributes: [
        :id, :gender, :born_on, :roll_number, :communication_address, :district, :state, :pin,
        :linkedin_url, :twitter_url, :slack_username, :university_id
      ])
  end

  def prevent_repeat!
    unless current_user.startup.unready?
      if step != 'launch'
        flash[:info] = "You've already completed the incubation process. You don't need to repeat that!"
        redirect_to root_url and return true
      end
    end

    false
  end

  def ready_for_incubation_wizard?
    redirect_to new_user_startup_url(current_user) and return unless current_user.ready_for_incubation_wizard?
  end

  def authorize_step!
    case params[:id]
    when 'startup_profile'
      unless current_user.incubation_parameters_available?
        flash[:info] = "Please complete your user profile first!"
        redirect_to incubation_path(:user_profile) and return
      end
    when 'launch'
      unless current_user.incubation_parameters_available?
        flash[:info] = "Please complete your user profile first!"
        redirect_to incubation_path(:user_profile) and return
      end
      unless current_user.startup.incubation_parameters_available?
        flash[:info] = "Please complete your startup profile first!"
        redirect_to incubation_path(:startup_profile) and return
      end
    end
  end
end
