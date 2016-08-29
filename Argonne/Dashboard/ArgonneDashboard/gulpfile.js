    /// <binding AfterBuild='default' Clean='clean' />

/*
This file is the main entry point for defining Gulp tasks and using Gulp plugins.
Click here to learn more. http://go.microsoft.com/fwlink/?LinkId=518007
*/

var gulp = require('gulp');
var del = require('del');
var ts = require('gulp-typescript');
var tsProject = ts.createProject('tsconfig.json');
var sourcemaps = require('gulp-sourcemaps');
var concat = require('gulp-concat');

var paths = {
    scripts: ['wwwroot/**/*.ts', 'wwwroot/**/*.map'],
    generatedJS: 'wwwroot/app/*.js',
    outDir: 'wwwroot/app'
};

gulp.task('clean', function () {
    return del(paths.generatedJS);
});

gulp.task('build-ts', function () {
    var tsResult = tsProject.src()
        .pipe(sourcemaps.init()) // This means sourcemaps will be generated 
        .pipe(ts(tsProject));

    // below outputs to the same file
    // .pipe(concat('output.js')) // You can use other plugins that also support gulp-sourcemaps 
    return tsResult.pipe(sourcemaps.write()) // Now the sourcemaps are added to the .js file 
        .pipe(gulp.dest(paths.outDir));        
});

gulp.task('default', ['build-ts'], function () {
    //gulp.src(paths.scripts).pipe(gulp.dest('wwwroot/scripts'))
});