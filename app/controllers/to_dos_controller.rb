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
    # puts "GOT TO LINE BEFORE EMAIL NOTIFICATION"
    # NotificationMailer.to_do_reminder_email('guy', 'guy2').deliver_now
    # NotificationMailer.send_notification_email.deliver_now
  end

  def edit
    @todo = ToDo.find(params[:id])
    @todo_count = current_user.to_dos.count
  end

  def new
    @todo = ToDo.new
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
    puts "DURATION #{@todo.duration}"
    puts "*** GOT TO TO DO CREATE ***"

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
      @todo = ToDo.new
      @todo_count = current_user.to_dos.count + 1
      render('new')
    end
  end

  def update
    @todo = ToDo.find(params[:id])

    if @todo.update_attributes(todo_params)
      flash[:notice] = "To-do '#{@todo.title}' updated successfully"
      redirect_to(:action => 'index')
    else
      @todo = ToDo.new
      @todo_count = current_user.to_dos.count + 1
      render('new')
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

  private

  def todo_params
    params.require(:to_do).permit(:title,:description,:position,:recurrence)
  end

end
