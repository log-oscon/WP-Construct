import gulp from 'gulp';
import plumber from 'gulp-plumber';
import svgSprite from 'gulp-svg-sprite';
import config from '../config';

gulp.task('svg-sprite', () =>
  gulp.src(config.svgSprite.src)
    .pipe(plumber())
    .pipe(svgSprite(config.svgSprite.config))
      .on('error', function(error){ console.log(error); })
    .pipe(gulp.dest(config.svgSprite.dest))
);
