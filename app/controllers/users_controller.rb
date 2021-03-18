class UsersController < ApplicationController
    
    def create
        user = User.new(username: params["username"], email: params["email"],
            password: params["password"])

        if user.save
            render json: user, status: 200
        else
            render json: {error: "Couldnt create"}, status: 500
        end
    end
end
