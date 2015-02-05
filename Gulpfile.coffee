# Load us some modules
gulp        = require 'gulp'
gutil       = require 'gulp-util'
combine     = require 'stream-combiner'
less        = require 'gulp-less'
cssmin      = require 'gulp-cssmin'
coffee      = require 'gulp-coffee'
sourcemaps  = require 'gulp-sourcemaps'
changed     = require 'gulp-changed'
concat      = require 'gulp-concat'
rename      = require 'gulp-rename'
uglify      = require 'gulp-uglify'
rev         = require 'gulp-rev'
usemin      = require 'gulp-usemin'
git         = require 'gulp-git'
bump        = require 'gulp-bump'
filter      = require 'gulp-filter'
tap         = require 'gulp-tap'
replace     = require 'gulp-replace'
del         = require 'del'
livereload  = require 'gulp-livereload'
connect     = require 'gulp-connect'
clean       = require 'gulp-clean'
fileinclude = require 'gulp-file-include' # consider switching to gulp-assemble
_           = require 'lodash'
karma       = require 'karma'
  .server

root = "app"

paths = {
  less        : [ "#{root}/bower_components/lesshat/build/lesshat.less", "#{root}/less/*.less" ]
  css         : "#{root}/public/stylesheets/**/*.css"
  coffee      : "#{root}/coffeescripts/**/*.coffee"
  js          : "#{root}/public/javascripts/**/*.js"
  markup      : "#{root}/public/**/*.{html,xml}"
  views       : "#{root}/views/*.html"
  partials    : "#{root}/views/partials/**/*.html"
  test        : "#{root}/test/**/*.spec.coffee"
}

dests = {
  css         : "#{root}/public/stylesheets"
  js          : "#{root}/public/javascripts"
  fonts       : "#{root}/public/fonts"
  markup      : "#{root}/public"
}

vroot = "#{root}/bower_components"

vendor = {
  css         : [
    "#{vroot}/normalize-css/normalize.css",
    "#{vroot}/bootstrap/dist/css/bootstrap.css"
  ]
  fonts       : [
    "#{vroot}/bootstrap/dist/fonts/**/*.*"
  ]
  js          : [
    "#{vroot}/angular/angular.min.js",
    "#{vroot}/angular-route/angular-route.min.js",
    "#{vroot}/angular-sanitize/angular-sanitize.min.js",
    "#{vroot}/showdown/src/showdown.js",
    "#{vroot}/angular-markdown-directive/markdown.js",
    "#{vroot}/lodash/dist/lodash.min.js"
  ]
}


gulp.task 'coffee', () ->
  gulp.src paths.coffee
    .pipe concat 'all.coffee'
    .pipe changed paths.js, { extension: '.js' }
    .pipe do sourcemaps.init
    .pipe coffee { bare: true }
    .on 'error', (err) ->
      gutil.log(err)
      do this.end
    .pipe do sourcemaps.write
    .pipe gulp.dest dests.js

gulp.task 'uglify', () ->
  gulp.src paths.js
    .pipe rename { suffix: '.min' }
    .pipe do uglify
    .pipe gulp.dest dests.js

gulp.task 'less', () ->
  gulp.src paths.less
    .pipe concat 'all.less'
    .pipe do sourcemaps.init
    .pipe do less
    .on 'error', (err) ->
      gutil.log(err)
      do this.end
    .pipe do sourcemaps.write
    .pipe gulp.dest dests.css

gulp.task 'views', () ->
  gulp.src paths.views
    .pipe do fileinclude
    .pipe gulp.dest dests.markup

gulp.task 'prepare', ['less', 'coffee', 'views', 'vendor'], (cb) ->
  del ["#{dests.css}/min", "#{dests.js}/min"], () ->
    gulp.src "#{dests.markup}/*.html"
      .pipe usemin {
        css: [cssmin(), 'concat', rev()]
        js: [ 'concat', rev() ]
        # TODO: Why is uglify breaking btf-markdown?
        #js: [uglify(), rev()]
      }
      .pipe replace /(<link.*)\/>/g, '$1 type="text/css" media="screen"/>'
      .pipe gulp.dest dests.markup

inc = (importance) ->
  gulp.src './package.json'
    .pipe bump { type: importance }
    .pipe gulp.dest './'
    .pipe git.commit "bump to new #{importance} release"
    .pipe filter 'package.json'

gulp.task 'patch', () -> inc 'patch'
gulp.task 'feature', () -> inc 'feature'
gulp.task 'release', () -> inc 'release'

gulp.task 'vendor', () ->
  gulp.src vendor.css
    .pipe concat 'vendor.css'
    .pipe gulp.dest dests.css
  gulp.src vendor.js
    .pipe concat 'vendor.js'
    .pipe gulp.dest dests.js
  gulp.src vendor.fonts, { base: "#{vroot}/bootstrap/dist/fonts" }
    .pipe gulp.dest dests.fonts

gulp.task 'watch', () ->

  do livereload.listen
  gulp.watch [ paths.js, paths.css, paths.markup ]
    .on 'change', livereload.changed

  gulp.watch paths.coffee, [ 'coffee' ]
  gulp.watch paths.less, [ 'less' ]
  gulp.watch [ paths.views, paths.partials ], [ 'views' ]

gulp.task 'connect', () ->
  connect.server {
    root: dests.markup,
    port: 8000,
    livereload: false
  }

gulp.task 'clean', () ->
  gulp.src [ dests.js, dests.css ], { read: false }
    .pipe(clean())

gulp.task 'default', [ 'coffee', 'less', 'views', 'watch', 'connect' ]
