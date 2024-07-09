Rails.application.routes.draw do
  root 'index#index' 
  get 'index/index'
  get 'questions/index', as: 'questions_index'
  get 'author/index' , as: 'author_index'
  get 'authoraide/index' , as: 'authoraide_index'
  get 'reports/index', as: 'reports_index'
  get 'items/index', as: 'items_index'
#   get 'abc' , to: "index#index"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
