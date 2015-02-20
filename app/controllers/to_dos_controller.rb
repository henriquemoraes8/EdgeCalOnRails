class ToDosController < ApplicationController
  def index
    @todos = current_user.to_dos
  end

  def edit
    @todo = ToDo.find(params[:id])
    @todo_count = current_user.to_dos.count
  end

  def new
    @todo = ToDo.new
    @todo_count = current_user.to_dos.count + 1
  end

  def create

  end

  def destroy
    @todo = ToDo.find(params[:id])
    @todo.destroy
    flash[:notice] = "To-do '#{@todo.title}' deleted successfully"
    redirect_to(to_dos_index_path)
  end
end
