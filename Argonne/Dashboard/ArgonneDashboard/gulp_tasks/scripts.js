const gulp = require('gulp');
const tslint = require('gulp-tslint');
const browserSync = require('browser-sync');

const conf = require('../conf/gulp.conf');

gulp.task('scripts', scripts);
gulp.task('scripts:dev', scripts);

function scripts() {
  return gulp.src(conf.path.src('**/*.ts'))
    .pipe(tslint())
    .pipe(tslint.report('verbose'))
    .pipe(browserSync.stream());
}
