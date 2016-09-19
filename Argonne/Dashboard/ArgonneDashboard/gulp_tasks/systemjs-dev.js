const gulp = require('gulp');
const replace = require('gulp-replace');

const Builder = require('jspm').Builder;
const conf = require('../conf/gulp.conf');

gulp.task('systemjs:dev', systemjsDev);
gulp.task('systemjs:dev:html', updateIndexHtmlDev);

function systemjsDev(done) {
  const builder = new Builder('./', 'jspm.config.js');
  builder.config({
    paths: {
      "github:*": "jspm_packages/github/*",
      "npm:*": "jspm_packages/npm/*"
    },
    packageConfigPaths: [
      'npm:@*/*.json',
      'npm:*.json',
      'github:*/*.json'
    ]
  });
  builder.buildStatic(
    `${'src/index.ts'}`,
    conf.path.tmp('index.js'),
    {
      production: false,
      browser: true
    }
  ).then(() => {
    done();
  }, done);
}

function updateIndexHtmlDev() {
  return gulp.src(conf.path.src('index.html'))
    .pipe(replace(
      /<script src="jspm_packages\/system.js">[\s\S]*System.import.*\n\s*<\/script>/,
      `<script src="index.js"></script>`
    ))
    .pipe(gulp.dest(conf.path.tmp()));
}
