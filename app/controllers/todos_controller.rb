# frozen_string_literal: true

class TodosController < ApplicationController
  before_action :set_todo, only: %i[show edit update destroy change_status]

  def index
    @todos = Todo.where(status: params[:status].presence || 'incomplete')
  end

  def show; end

  def new
    @todo = Todo.new
  end

  def edit; end

  def create
    @todo = Todo.new(todo_params)

    respond_to do |format|
      if @todo.save
        format.turbo_stream
        format.html { redirect_to(todo_url(@todo), notice: 'Todo was successfully created.') }
      else
        format.turbo_stream { render(turbo_stream: turbo_stream.replace("#{helpers.dom_id(@todo)}_form", partial: 'form', locals: { todo: @todo })) }
        format.html { render(:new, status: :unprocessable_entity) }
      end
    end
  end

  def update
    respond_to do |format|
      if @todo.update(todo_params)
        format.turbo_stream
        format.html { redirect_to(todo_url(@todo), notice: 'Todo was successfully updated.') }
        format.json { render(:show, status: :ok, location: @todo) }
      else
        format.turbo_stream { render(turbo_stream: turbo_stream.replace("#{helpers.dom_id(@todo)}_form", partial: 'form', locals: { todo: @todo })) }
        format.html { render(:edit, status: :unprocessable_entity) }
        format.json { render(json: @todo.errors, status: :unprocessable_entity) }
      end
    end
  end

  def destroy
    @todo.destroy

    respond_to do |format|
      format.turbo_stream { render(turbo_stream: turbo_stream.remove("#{helpers.dom_id(@todo)}_container")) }
      format.html { redirect_to(todos_url, notice: 'Todo was successfully destroyed.') }
      format.json { head(:no_content) }
    end
  end

  def change_status
    @todo.update(status: todo_params[:status])

    respond_to do |format|
      format.turbo_stream { render(turbo_stream: turbo_stream.remove("#{helpers.dom_id(@todo)}_container")) }
      format.html { redirect_to(todos_path, notice: 'Updated todo status.') }
    end
  end

  private

  def set_todo
    @todo = Todo.find(params[:id])
  end

  def todo_params
    params.require(:todo).permit(:name, :status)
  end
end
