const gulp = require('gulp');
const HubRegistry = require('gulp-hub');
const conf = require('./conf/gulp.conf');

// Load some files into the registry
const hub = new HubRegistry([conf.path.tasks('*.js')]);

// Tell gulp to use the tasks just loaded
gulp.registry(hub);

gulp.task('build', gulp.series('partials', gulp.parallel('systemjs', 'systemjs:html'), 'build'));

function reloadBrowserSync(cb) {
  browserSync.reload();
  cb();
}

function watch(done) {
  gulp.watch(conf.path.src('**/*.html'), reloadBrowserSync);
  gulp.watch([
    conf.path.src('**/*.scss'),
    conf.path.src('**/*.css')
  ], gulp.series('styles'));
  gulp.watch(conf.path.src('**/*.ts'), gulp.series('scripts'));
  done();
}
