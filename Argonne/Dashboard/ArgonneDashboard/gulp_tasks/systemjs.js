const gulp = require('gulp');
const replace = require('gulp-replace');
const rename = require("gulp-rename");
const Builder = require('jspm').Builder;
const conf = require('../conf/gulp.conf');

gulp.task('systemjs', systemjs);
gulp.task('systemjs:html', updateIndexHtml);

function systemjs(done) {
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
      `${'wwwroot/index.ts'} + ${conf.path.dist('templateCacheHtml.ts')}`,
      conf.path.dist('index.js'),
      {
          production: true,
          browser: true
      }
    ).then(() => {
        done();
    }, done);
}

function updateIndexHtml() {
    return gulp.src(conf.path.src(conf.path.srcIndexHtml()))
      .pipe(replace(
        /<script src="jspm_packages\/system.js">[\s\S]*System.import.*\n\s*<\/script>/,
        `<script src="index.js"></script>`
      ))
        .pipe(rename(conf.path.outIndexHtml()))
        .pipe(gulp.dest(conf.path.dist()));
}
