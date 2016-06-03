import gulp from 'gulp';
import autoprefixer from 'gulp-autoprefixer';
import browserSync from 'browser-sync';
import gulpIf from 'gulp-if';
import nano from 'gulp-cssnano';
import plumber from 'gulp-plumber';
import postcss from 'gulp-postcss';
import postcssScss from 'postcss-scss';
import reporter from 'postcss-reporter';
import sass from 'gulp-sass';
import sourcemaps from 'gulp-sourcemaps';
import stylelint from 'stylelint';
import handleErrors from '../util/handle-errors';
import config from '../config';

const preprocessors = [
  stylelint(),
  reporter({
    clearMessages: true,
    throwError:    false,
  }),
];

gulp.task('sass', ['images'], () =>
  gulp.src(config.sass.src)
    .pipe(plumber())
    .pipe(gulpIf(config.environment.debug, sourcemaps.init()))
    .pipe(postcss(preprocessors, {syntax: postcssScss}))
    .pipe(sass(config.sass.settings))
    .on('error', handleErrors)
    .pipe(autoprefixer(config.autoprefixer))
    .pipe(nano())
    .pipe(gulpIf(config.environment.debug, sourcemaps.write()))
    .pipe(gulp.dest(config.sass.dest))
    .pipe(browserSync.reload({
      stream: true
    }))
);
