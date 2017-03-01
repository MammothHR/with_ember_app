/**
  This is an example ember-deploy config file.  Your deploy will likely differ in significant ways, however the key step is to use ember-deploy-webhooks to notify Rails about your asset's final location.  It is necessary to read the generated HTML file from Ember-CLI to know the exact asset URLs.
*/

var fs = require('fs');

/**
  Read my-app.html asset names into a payload for Rails.
*/
module.exports = function buildNotifyPayload(context) {
  var rootPath = context.project.root;
  var distPath = context.config.build.outputPath;
  var payload = {};
  var filename = 'my-app.html';
  var filePath = [rootPath, distPath, filename].join('/');

  data = fs.readFileSync(filePath);

  if (!data) {
    console.log('Error!')
  }

  payload[name] = data.toString();

  return payload;
}

module.exports = function(deployTarget) {
  return {
    build: {
      environment: 'production',
    },

    webhooks: {
      apiKey: '585db5171c59a47f68b0de27b8c40c2341b52cdbc60d3083d4e8958532',

      services: {
        'rails-notify': {
          url: 'https://www.my-app.com/app/assets',
          headers: {},
          method: 'POST',

          body: function(context) {
            var body = buildNotifyPayload(context);

            return {
              files: body,
              key: context.config.webhooks.apiKey
            };
          },
          didUpload: true
        }
      }
    },

    rsync: {
       type: 'rsync',
       ssh: true,
       recursive: true,
       delete: false,
       args: [ '-azv' ],
       dest: '/srv/deploy/my_app/current/public/ember_assets',
       host: 'deploy@0.0.0.0'
    }
  }
}
