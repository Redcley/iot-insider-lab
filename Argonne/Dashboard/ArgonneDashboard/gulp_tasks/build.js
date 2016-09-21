const gulp = require('gulp');
const filter = require('gulp-filter');
const useref = require('gulp-useref');
const rev = require('gulp-rev');
const revReplace = require('gulp-rev-replace');
const uglify = require('gulp-uglify');
const cssnano = require('gulp-cssnano');
const htmlmin = require('gulp-htmlmin');
const sourcemaps = require('gulp-sourcemaps');
const uglifySaveLicense = require('uglify-save-license');
const ngAnnotate = require('gulp-ng-annotate');
const rename = require("gulp-rename");


const conf = require('../conf/gulp.conf');

gulp.task('build', build);

function build() {
    const htmlFilter = filter(conf.path.dist('*.html'), { restore: true });
    const jsFilter = filter(conf.path.dist('**/*.js'), { restore: true });
    const cssFilter = filter(conf.path.dist('**/*.css'), { restore: true });

    return gulp.src(conf.path.dist(conf.path.srcIndexHtml()))
    .pipe(useref())
    .pipe(jsFilter)
    .pipe(sourcemaps.init())
    .pipe(ngAnnotate())
    .pipe(uglify({preserveComments: uglifySaveLicense})).on('error', conf.errorHandler('Uglify'))
    //.pipe(rev())
    .pipe(sourcemaps.write('maps'))
    .pipe(jsFilter.restore)
    .pipe(cssFilter)
    //.pipe(sourcemaps.init())
    .pipe(cssnano())
    //.pipe(rev())
    //.pipe(sourcemaps.write('maps'))
    .pipe(cssFilter.restore)
    //.pipe(revReplace())
    .pipe(htmlFilter)
    .pipe(htmlmin())
    .pipe(htmlFilter.restore)
    .pipe(rename(conf.path.outIndexHtml()))
    .pipe(gulp.dest(conf.path.dist()));
}
