module WithEmberApp
  module Helper
    # @option [Boolean]         loading_spinner
    # @option [Boolean]         timeout_page
    # @option kwargs [String]   name
    # @option kwargs [<String>] names
    # @option kwargs [Hash]     payload
    # @return [String]
    def with_ember_app(loading_spinner: true, timeout_page: false, **kwargs)
      assets = Assets::Builder.run! **kwargs
      options = WithEmberApp

      render(partial: 'with_ember_app/loading_template', locals: {
        options: options,
        loading_spinner: loading_spinner,
        timeout_page: timeout_page
      }) + assets
    end
  end
end
