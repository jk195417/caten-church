class Admin::EventsController < AdminController
  load_and_authorize_resource # cancancan
  before_action :set_event, only: [:show, :edit, :update, :destroy, :show_list]

  def index
    @events = Admin::Event.all
  end

  def show
  end

  def new
    @event = Admin::Event.new
  end


  def edit
  end

  
  def create
    @event = current_user.events.new(resource_params)
    if @event.save
      redirect_to admin_event_path(@event)
      flash[:success] = "活動發起成功"
    else
      render :new
    end
  end

  def update
    if @event.update(resource_params)
      redirect_to admin_event_path(@event)
      flash[:success] = "活動修改成功"
    else
      render :edit 
    end
  end

  def destroy
    @event.destroy
    redirect_to admin_events_path
    flash[:danger] = "活動已刪除"
  end

  def show_list
    @participants = @event.participants.includes(:profile)
    respond_to do |format|
        format.html
        format.json { render :json => @participants.to_json(include: :profile) }    
    end
  end
  private
    def set_event
      @event = Admin::Event.find(params[:id])
    end

    def resource_params
      params.require(:admin_event).permit(:name, :nature, :description, :max_sign_up_number, :min_sign_up_number, :sign_up_begin, :sign_up_end, :start, :over)
    end
end