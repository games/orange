var gulp = require('gulp'),
    connect = require('gulp-connect'),
    minify = require('gulp-minifier'),
    ts = require('gulp-typescript'),
    del = require('del'),
    rename = require('gulp-rename'),
    config = require('./config.js'),
    watch = require('gulp-watch'),
    changed = require('gulp-changed');

var appfile = config.appfile;
var output = config.output;
var scripts_dir = config.scripts_dir;
// var assets_dir = config.assets_dir;
var example_dir = config.example_dir;

gulp.task('clean', function (cb) {
  del([output], cb);
});

gulp.task('scripts', function() {
  return gulp.src(['./src/**/*.ts'])
             .pipe(ts({ noImplicitAny: true,
                        out: appfile })).js
             .pipe(gulp.dest(example_dir))
             .pipe(minify({
                minify: true,
                collapseWhitespace: true,
                conservativeCollapse: true,
                minifyJS: true,
                minifyCSS: true
              }))
             .pipe(gulp.dest(scripts_dir));
});

// gulp.task('copy:html', function() {
//   return gulp.src(['./src/**/*.html']).pipe(minify({
//           minify: true,
//           collapseWhitespace: true,
//           conservativeCollapse: true,
//           minifyJS: true,
//           minifyCSS: true
//         })).pipe(gulp.dest(output));
// });
//
// gulp.task('copy:assets', function(cb) {
//   gulp.src('./src/assets/**/*.*')
//       .pipe(changed(assets_dir))
//       .pipe(gulp.dest(assets_dir));
// });

gulp.task('copy:vendor', function () {
  return gulp.src(config.vendorFiles)
              .pipe(rename(function (path) {
                  path.dirname = '';
              }))
              .pipe(gulp.dest(scripts_dir));
});

gulp.task('copy', ['copy:vendor']);

gulp.task('serve', function() {
    return connect.server({
        root: example_dir,
        port: 9527,
        livereload: true
    });
});

gulp.task('test', function() {});

gulp.task('build', ['clean'], function() {
  gulp.start('scripts', 'copy');
});

function watchCMD(pattern, distdir) {
  watch(pattern, function(vinul) {
      switch (vinul.event) {
        case 'add':
        case 'change':
          gulp.src(pattern)
              .pipe(changed(distdir))
              .pipe(gulp.dest(distdir));
          break;
        case 'unlink':
          del(vinul.relative.replace('src', output));
          break;
        default:
          console.error(vinul.event + ' > ' + vinul.path);
      }
  });
}

gulp.task('dev', ['build', 'serve'], function () {
    //watchCMD('./src/assets/**/*.*', assets_dir);

    //gulp.watch('./src/**/*.html', ['copy:html']);
    gulp.watch('./src/**/*.ts', ['build']);
    //gulp.watch('./src/less/**/*.less', ['less']);
    //gulp.watch('./src/assets/**/*.png', ['assets:imagemin']);
    //gulp.watch('./src/assets/**/*.{json,tmx}', ['assets:tilemap-pack', 'assets:jsonmin', 'assets:copy']);
    //gulp.watch(config.vendorFiles, ['copy:vendor']);
});
