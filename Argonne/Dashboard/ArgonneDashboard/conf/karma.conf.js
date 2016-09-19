const conf = require('./gulp.conf');

module.exports = function (config) {
  const configuration = {
    basePath: '../',
    singleRun: true,
    autoWatch: false,
    logLevel: 'INFO',
    junitReporter: {
      outputDir: 'test-reports'
    },
    browsers: [
      'PhantomJS'
    ],
    frameworks: [
      'jasmine',
      'jspm',
      'es6-shim'
    ],
    preprocessors: {
      [conf.path.src('**/*.html')]: [
        'ng-html2js',
        'generic'
      ]
    },
    genericPreprocessor: {
      rules: [
        {
          process(content, file, done) {
            file.path = file.path.replace(/\.js$/, '.ts');
            done(content);
          }
        }
      ]
    },
    ngHtml2JsPreprocessor: {},
    jspm: {
      loadFiles: [
        conf.path.src('app/**/*.ts'),
        conf.path.src('**/*.html')
      ],
      config: 'jspm.config.js',
      browser: 'jspm.test.js'
    },
    plugins: [
      require('karma-jasmine'),
      require('karma-junit-reporter'),
      require('karma-coverage'),
      require('karma-phantomjs-launcher'),
      require('karma-phantomjs-shim'),
      require('karma-ng-html2js-preprocessor'),
      require('karma-jspm'),
      require('karma-generic-preprocessor'),
      require('karma-es6-shim')
    ]
  };

  config.set(configuration);
};
