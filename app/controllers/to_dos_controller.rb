class ToDosController < ApplicationController

  ################################################################
  # The To-Dos controller deals with Present Until Done events,
  # which we call To-Dos in our project.  Each To-Do can have its
  # own reminder, which will send an email reminder to the user
  # about their to-do.  To-Dos will remain on the user's calendar
  # until they're done.
  ################################################################
    
  def index
    @todos = current_user.to_dos.sorted
  end

  def edit
    @todo = ToDo.find(params[:id])
    @todo_count = current_user.to_dos.count
  end

  def new
    @todo = ToDo.new(:escalation_step => 1)
    @todo_count = current_user.to_dos.count + 1
  end

  def done
    @todo = ToDo.find(params[:id])
    @todo.update_attributes(:done => true)
    @todos = current_user.to_dos.sorted
    flash[:notice] = "To-do '#{@todo.title}' is done"
    render('index')
  end

  def create
    @todo = ToDo.new(todo_params)
    @todo.creator_id = current_user.id
    @todo.duration = params['to_do']['duration(4i)'].to_i*3600 + params['to_do']['duration(5i)'].to_i*60
    @todo.expiration = correct_time_from_datepicker(params[:to_do][:expiration])
    puts "*** GOT TO TO DO CREATE TODO EXP IS #{@todo.expiration} ***"

    step_error = validate_to_do
    unless step_error.blank?
      puts "STEP ERROR"
      flash[:error] = step_error
      @todo_count = current_user.to_dos.count + 1
      render('new')
      return
    end

    if @todo.save
      flash[:notice] = "To-do '#{@todo.title}' created successfully"

      if !params[:to_do][:reminder][:next_reminder_time].blank?
        puts "WILL CREATE REMINDER"
        if !@todo.set_reminder(params[:to_do][:reminder])
          @todo_count = current_user.to_dos.count + 1
          render('new')
          return
        end
      end

      redirect_to(:action => 'index')
    else
      @todo_count = current_user.to_dos.count + 1
      flash[:error] = @todo.errors.full_messages
      render('new')
    end
  end

  def validate_to_do
    if @todo.expiration.nil? # or @todo.expiration.empty?
      return ''
    end

    if @todo.escalation_step <= 0
      return 'priority raise must be an integer greater then or equal to 1'
    end
    ''
  end

  def update
    @todo = ToDo.find(params[:id])
    @todo.assign_attributes(todo_params)
    @todo.expiration = correct_time_from_datepicker(params[:to_do][:expiration])

    step_error = validate_to_do
    unless step_error.blank?
      flash[:error] = step_error
      @todo_count = current_user.to_dos.count + 1
      render('edit')
      return
    end

    if @todo.save
      flash[:notice] = "To-do '#{@todo.title}' updated successfully"
      redirect_to(:action => 'index')
    else
      @todo = ToDo.new
      @todo_count = current_user.to_dos.count + 1
      render('edit')
    end
  end

  def destroy
    @todo = ToDo.find_by_id(params[:id])
    @todo.destroy
    flash[:notice] = "To-do '#{@todo.title}' deleted successfully"

    redirect_to(to_dos_index_path)
  end

  def get_to_do_list
    index
  end
  
  ######################
  ### MODALS ##########
  ######################


  private

  def todo_params
    params.require(:to_do).permit(:title,:description,:position,:recurrence, :expiration, :escalation_prior, :escalation_recurrence,:escalation_step)
  end

end
