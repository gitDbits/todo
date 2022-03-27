# frozen_string_literal: true

Rails.application.routes.draw do
  resources :todos do
    patch :change_status, on: :member
  end
end
