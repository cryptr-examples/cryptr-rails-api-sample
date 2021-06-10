class ApiV1Controller < ApplicationController
 
  before_action :set_access_control_headers
  def index
    render json: [
      {
        "id" => 1,
        "user_id" =>
        "eba25511-afce-4c8e-8cab-f82822434648",
        "title" => "learn git",
        "tags" => ["colaborate", "git" ,"cli", "commit", "versionning"],
        "img" => "https://carlchenet.com/wp-content/uploads/2019/04/git-logo.png",
        "desc" => "Learn how to create, manage, fork, and collaborate on a project. Git stays a major part of all companies projects. Learning git is learning how to make your project better everyday",
        "date" => '5 Nov',
        "timestamp" => 1604577600000,
        "teacher" => {
            "name" => "Max",
            "picture" => "https://images.unsplash.com/photo-1558531304-a4773b7e3a9c?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=634&q=80"
        }
      }
    ]
  end
  
  private
  
  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = ENV['CRYPTR_AUDIENCE']
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Max-Age'] = '1000'
    headers['Access-Control-Allow-Headers'] = '*,x-requested-with'
  end
end
 