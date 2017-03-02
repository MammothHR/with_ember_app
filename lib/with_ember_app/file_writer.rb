module WithEmberApp
  class FileWriter < ActiveInteraction::Base
    hash :files, strip: false
    boolean :canary, default: false

    def execute
      files.each_pair do |app_name, data|
        WithEmberApp.write app_name, data, canary: canary
      end
    end
  end
end
