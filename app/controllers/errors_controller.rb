class ErrorsController < ApplicationController

  def unsupported_request  
    render json: { errors:
      [
        "status"=>"400",
        "title"=>"Bad Request",
        "detail"=>"Request is not recognized by application",
      ]
    },
    status: :bad_request
  end
end
