module WithEmberApp
  class AppController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!
    before_action :authenticate_deploy!, only: [:create]

    def create
      service = WithEmberApp::FileWriter.run files: params[:files].to_hash, canary: params[:canary]

      if service.valid?
        render json: {}, status: :ok
      else
        render json: {}, status: :unprocessable_entity
      end
    end

    private

    def authenticate_deploy!
      invalid_link unless WithEmberApp::Authentication.authenticate params[:key]
    end

    def invalid_link
      render json: {}, status: :not_authorized
    end
  end
end
