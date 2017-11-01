require 'spec_helper'

describe WithEmberApp do
  it 'has a version number' do
    expect(WithEmberApp::VERSION).not_to be nil
  end

  describe 'setup' do
    it 'is configurable' do
      WithEmberApp.setup do |config|
        config.loading_classes    = 'give'
        config.error_classes      = 'you'
        config.error_hide_class   = 'up'
        config.deploy_key         = '!'
      end

      expect(WithEmberApp.loading_classes).to  eq('give')
      expect(WithEmberApp.error_classes).to    eq('you')
      expect(WithEmberApp.error_hide_class).to eq('up')
      expect(WithEmberApp.deploy_key).to       eq('!')
    end

    it 'exposes a url parser' do
      WithEmberApp.setup do |config|
        config.url_prep = -> (data) do
          data.gsub('foo', 'bar')
        end
      end

      expect(Rails.cache).to receive(:write).with('ember-app-name', hash_including(:timestamp, data: 'fo-bar-baz'))

      WithEmberApp.write 'app-name', 'fo-foo-baz'
    end
  end

  describe 'redis-adapter' do
    it 'has the correct adapter' do
      WithEmberApp.setup {}
      expect(WithEmberApp.adapter).to eq(WithEmberApp::Adapter::Redis)
    end

    it 'writes' do
      WithEmberApp.write 'app-name', 'fo-ba-ba'
      result = Rails.cache.fetch('ember-app-name')

      expect(result[:data]).to eq('fo-ba-ba')
    end

    it 'fetches' do
      Rails.cache.write 'ember-app-name', { data: 'fo-ba-ba' }
      result = WithEmberApp.fetch 'app-name'

      expect(result).to eq('fo-ba-ba')
    end

    it 'retrives a timestamp' do
      WithEmberApp.write 'app-name', 'fo-ba-ba'
      result = WithEmberApp.fetch_version('app-name')

      expect(result).to_not be_blank
    end

    context 'with canary' do
      it 'stores under a different key' do
        WithEmberApp.setup {}

        WithEmberApp.write 'app-name', 'foo'
        WithEmberApp.write 'app-name', 'bar', canary: true

        expect(WithEmberApp.fetch('app-name')).to eq('foo')
        expect(WithEmberApp.fetch('app-name', canary: true)).to eq('bar')
      end
    end
  end

  describe 'file adapter' do
    before(:each) do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
      WithEmberApp.setup {}
    end

    subject do
      WithEmberApp.fetch 'app'
    end

    it 'has the correct adapter' do
      expect(WithEmberApp.adapter).to eq(WithEmberApp::Adapter::File)
    end

    it 'fetches' do
      expect(subject).to be_present
    end

    context 'when a dev_index is provided' do
      before(:each) do
        root = File.dirname __dir__
        path = File.join root, 'spec', 'mocks', 'test.html'

        WithEmberApp.add_custom_default_asset_rules_for 'app', prefix_vendor: false, dev_index: path
      end

      it 'can have ad hoc assets' do
        result = subject.to_s
        expect(result).to eq("<foo><bar><baz>\n")
      end
    end

    context 'when dev_index is not present and no inferred-index is possible' do
      def has_a_script_tag_for(result, app)
        result =~ /(script)[^\<]*(#{ app }.js)[^\<]*(<\/script>)/
      end

      def has_a_style_tag_for(result, app)
        result =~ /(link)[^\<]*(#{ app }.css)[^\>]*(>)/
      end

      it 'works with no settings' do
        result = subject.to_s

        expect(has_a_script_tag_for(result, 'app')).to be_truthy
        expect(has_a_script_tag_for(result, 'app-vendor')).to be_truthy
        expect(has_a_style_tag_for(result, 'app')).to be_truthy
        expect(has_a_style_tag_for(result, 'app-vendor')).to be_truthy
      end

      it 'works with a rule for no app-name' do
        WithEmberApp.add_custom_default_asset_rules_for 'app', app: false
        result = subject.to_s

        expect(has_a_script_tag_for(result, 'app')).to be_falsey
        expect(has_a_script_tag_for(result, 'app-vendor')).to be_truthy
        expect(has_a_style_tag_for(result, 'app')).to be_falsey
        expect(has_a_style_tag_for(result, 'app-vendor')).to be_truthy
      end

      it 'works with a rule for no vendor' do
        WithEmberApp.add_custom_default_asset_rules_for 'app', vendor: false
        result = subject.to_s

        expect(has_a_script_tag_for(result, 'app')).to be_truthy
        expect(has_a_script_tag_for(result, 'vendor')).to be_falsey
        expect(has_a_style_tag_for(result, 'app')).to be_truthy
        expect(has_a_style_tag_for(result, 'vendor')).to be_falsey
      end

      it 'works with a rule for no css' do
        WithEmberApp.add_custom_default_asset_rules_for 'app', css: false
        result = subject.to_s

        expect(has_a_script_tag_for(result, 'app')).to be_truthy
        expect(has_a_script_tag_for(result, 'app-vendor')).to be_truthy
        expect(has_a_style_tag_for(result, 'app')).to be_falsey
        expect(has_a_style_tag_for(result, 'app-vendor')).to be_falsey
      end

      it 'works with a rule for another app' do
        WithEmberApp.add_custom_default_asset_rules_for 'app-2', app: false
        result = subject.to_s

        expect(has_a_script_tag_for(result, 'app')).to be_truthy
        expect(has_a_script_tag_for(result, 'app-vendor')).to be_truthy
        expect(has_a_style_tag_for(result, 'app')).to be_truthy
        expect(has_a_style_tag_for(result, 'app-vendor')).to be_truthy
      end

      it 'can disable vendor-prefixing' do
        WithEmberApp.add_custom_default_asset_rules_for 'app', prefix_vendor: false
        result = subject.to_s

        expect(has_a_script_tag_for(result, 'vendor')).to be_truthy
        expect(has_a_style_tag_for(result, 'vendor')).to be_truthy
        expect(has_a_script_tag_for(result, 'app-vendor')).to be_falsey
        expect(has_a_style_tag_for(result, 'app-vendor')).to be_falsey
      end
    end
  end

  describe 'assets' do
    describe 'builder' do
      let(:service) { WithEmberApp::Assets::Builder }

      it 'works with just a name' do
        results = service.run! name: 'foo', loading_spinner: false
        expect(results.to_s).to include('<script type="text/javascript">window.envName = "test"; </script>')
      end

      it 'validates that at least one name is present' do
        expect{ service.run! }.to raise_error(ActiveInteraction::InvalidInteractionError)
      end

      it 'fetches assets' do
        expect(WithEmberApp).to receive(:fetch).with('foo').and_return('<bar-script-baz>')

        results = service.run! name: 'foo'
        expect(results.to_s).to include('bar-script-baz')
      end

      it 'works with an array of names' do
        expect(WithEmberApp).to receive(:fetch).with('foo').and_return('<foo-script-baz>')
        expect(WithEmberApp).to receive(:fetch).with('bar').and_return('<bar-script-baz>')

        result = service.run!(names: ['foo', 'bar']).to_s
        expect(result).to include('foo-script-baz')
        expect(result).to include('bar-script-baz')
      end

      it 'inlines globals' do
        results = service.run! name: 'foo', globals: { foo: 123, bar: [1,2,3] }
        expect(results.to_s).to include('window.foo = 123; window.bar = [1,2,3];')
      end
    end
  end
end
