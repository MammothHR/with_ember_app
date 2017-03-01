module WithEmberApp
  class AppController < ApplicationController
    skip_before_action :authenticate_user!
    before_action :authenticate_deploy!, only: [:create]

    def create
      files = params[:files]

      if files.present?
        files.each do |filename, data|
          WithEmberApp.write filename, data, is_canary?
        end

        render json: {}, status: :ok
      else
        render json: {}, status: :unprocessable_entity
      end
    end

    private

    def authenticate_deploy!
      key = params[:key]

      invalid_link unless key.present? && WithEmberApp.deploy_key == key
    end

    def is_canary?
      params[:canary] == 'true'
    end

    def invalid_link
      redirect_to root_path, error: "Invalid Link"
    end
  end
end
