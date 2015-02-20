class ToDosController < ApplicationController
  def index
    @todos = ToDo
  end

  def edit
    @todo = ToDo.find(params[:id])
  end

  def new
    @todo = ToDo.new
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
