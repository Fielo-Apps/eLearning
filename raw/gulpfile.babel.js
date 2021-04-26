/**
 *
 *  Web Starter Kit
 *  Copyright 2015 Google Inc. All rights reserved.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      https://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

'use strict';

// This gulpfile makes use of new JavaScript features.
// Babel handles this without us having to do anything. It just works.
// You can read more about the new JavaScript features here:
// https://babeljs.io/docs/learn-es2015/


import fs from 'fs';
import path from 'path';
import gulp from 'gulp';
import del from 'del';
import runSequence from 'run-sequence';
import browserSync from 'browser-sync';
import swPrecache from 'sw-precache';
import gulpLoadPlugins from 'gulp-load-plugins';
import {output as pagespeed} from 'psi';
import pkg from './package.json';

var shell = require('gulp-shell')

const $ = gulpLoadPlugins();
const reload = browserSync.reload;


/* ***************************** PLATFORM TASKS ***************************** */

// Sources
var platformSalesforceCss = [
  {
    src: [
      'resources/FieloElr_Salesforce/styles/**/**/*.scss'
    ],
    dest: '../force-app/main/default/staticresources/FieloElr_Salesforce/styles'
 }
];

var platformSalesforceCssSources = [];
platformSalesforceCss.forEach(function (obj) {
  platformSalesforceCssSources = platformSalesforceCssSources.concat(obj.src);
});

var platformSalesforceJs = [{
    // CORE
    src: [
      // vendor
      'resources/FieloElr_Backend/vendor/cropper/cropper.min.js',
      // polyfill para navegadores incompatibles
      'resources/FieloElr_Backend/scripts/polyfill/date.js',
      'resources/FieloElr_Backend/scripts/polyfill/classList.js',
      'resources/FieloElr_Backend/scripts/polyfill/remove.js',
      'resources/FieloElr_Backend/scripts/polyfill/assign.js',
      'resources/FieloElr_Backend/vendor/svg4everybody/svg4everybody.min.js',
      // Utils - los tiene que inicializar un controlador externo
      'resources/FieloElr_Backend/scripts/helpers/main.js',
      'resources/FieloElr_Backend/scripts/helpers/ComponentHandler.js',
      'resources/FieloElr_Backend/scripts/utils/ckeditor.js',
      'resources/FieloElr_Backend/scripts/utils/notify.js',
      'resources/FieloElr_Backend/scripts/utils/formElement.js',
      'resources/FieloElr_Backend/scripts/utils/output.js',

      // Helpers - se inicializan solos
      'resources/FieloElr_Backend/scripts/helpers/spinner.js',
      'resources/FieloElr_Backend/scripts/helpers/button.js',
      'resources/FieloElr_Backend/scripts/helpers/select.js',
      'resources/FieloElr_Backend/scripts/helpers/menu.js',
      'resources/FieloElr_Backend/scripts/helpers/tabs.js',
      'resources/FieloElr_Backend/scripts/helpers/paginator.js',
      'resources/FieloElr_Backend/scripts/helpers/filter.js',
      'resources/FieloElr_Backend/scripts/helpers/form.js',
      'resources/FieloElr_Backend/scripts/helpers/recentRecords.js',
      'resources/FieloElr_Backend/scripts/helpers/relatedRecords.js',
      'resources/FieloElr_Backend/scripts/helpers/photoUpload.js'


    ],
    name: 'core.min.js',
    dest: '../force-app/main/core/staticresources/FieloSalesforce_Backend/fielo/scripts'
  },
  {
    src: [
      'resources/FieloElr_Salesforce/scripts/programSelector.js',
      'resources/FieloElr_Salesforce/scripts/elearning.js',
      'resources/FieloElr_Salesforce/scripts/recentOrder.js',
      'resources/FieloElr_Salesforce/scripts/questionManage.js',
      'resources/FieloElr_Salesforce/scripts/questionWizard.js',
      'resources/FieloElr_Salesforce/scripts/answerOptions.js',
      'resources/FieloElr_Salesforce/scripts/formElement.js'
    ],
    name: 'core.js',
    dest: '../force-app/main/default/staticresources/FieloElr_Salesforce/scripts'
  }
];

var platformSalesforceJsSources = [];
platformSalesforceJs.forEach(function (obj) {
  platformSalesforceJsSources = platformSalesforceJsSources.concat(obj.src);
});

// CSS
gulp.task('css', () => {
  const AUTOPREFIXER_BROWSERS = [
    'ie >= 11',
    'ff >= 30',
    'chrome >= 34',
    'safari >= 7',
    'ios >= 7',
    'android >= 4.4'
  ];
  return platformSalesforceCss.forEach(function (bundle) {
    return gulp.src(bundle.src)
      .pipe($.sourcemaps.init())
      .pipe($.sass({
        precision: 10
     }).on('error', $.sass.logError))
      .pipe($.autoprefixer(AUTOPREFIXER_BROWSERS))
      .pipe($.if('*.css', $.minifyCss()))
      .pipe($.size({title: 'styles'}))
      .pipe($.sourcemaps.write('./'))
      .pipe(gulp.dest(bundle.dest));
 });
});

// JavaScript concat and minify
gulp.task('js', ['lint'],
  () => {
    return platformSalesforceJs.forEach(function (bundle) {
      return gulp.src(bundle.src)
        .pipe($.sourcemaps.init())
        .pipe($.babel())
        .pipe($.sourcemaps.write())
        .pipe($.concat(bundle.name))
        .pipe($.uglify({preserveComments: 'some'}))
        // Output files
        .pipe($.size({title: 'scripts'}))
        .pipe($.sourcemaps.write('.'))
        .pipe(gulp.dest(bundle.dest))
   });
 });

// Local server
gulp.task('serve', ['css', 'js'], () => {
  browserSync({
    notify: false,
    // Customize the BrowserSync console logging prefix
    logPrefix: 'WSK',
    // Run as an https by uncommenting 'https: true'
    // Note: this uses an unsigned certificate which on first access
    //       will present a certificate warning in the browser.
    // https: true,
    server: ['resources', 'app'],
    port: 3000,
    ui: {
      weinre: {
        port: 3001
     }
   }
 });

  gulp.watch(['app/**/*.html'], reload);
  gulp.watch([
    'resources/FieloElr_Salesforce/styles/**/*.{scss,css}'
    ], [
    'css', reload ]);
  gulp.watch([
    'resources/FieloElr_Salesforce/scripts/**/*.js'
    ], [
    'js', reload ]);
});

// Watch
gulp.task('watch', () => {
  gulp.watch(platformSalesforceCssSources, ['css']);
  gulp.watch(platformSalesforceJsSources, ['js']);
});

// Copy Images
gulp.task('images', ['cleanImages'], () => {
  // CORE
  gulp.src(['resources/FieloElr_Backend/images/**'], {
      dot: true
    })
    .pipe(gulp.dest('../force-app/main/core/staticresources/FieloSalesforce_Backend/images'))
    .pipe($.size({
      title: 'copy'
    }));

  // PLT
  gulp.src(['resources/FieloElr_Salesforce/images/**'], {
      dot: true
    })
    .pipe(gulp.dest('../plt/main/default/staticresources/FieloElr_Salesforce/images'))
    .pipe($.size({
      title: 'copy'
    }));
});

// Clean Images
gulp.task('cleanImages', () => del([
  '../force-app/main/core/staticresources/FieloSalesforce_Backend/images/**'
], {
  dot: true,
  force: true
}));

// Javascript documentation
gulp.task('doc', ['cleanDoc'], () => {
  gulp.src([
    'resources/FieloElr_Salesforce/scripts/'    ]
    )
    .pipe(shell(
      [
        './node_modules/.bin/jsdoc <%=(file.path)%> --recurse --private' +
        ' --template node_modules/jsdoc/templates/default' +
        ' --destination docs'
      ],
      {verbose: true})
    );
});

// JavaScript Linter
gulp.task('lint', () =>
  gulp.src(platformSalesforceJsSources)
  .pipe($.eslint())
  .pipe($.eslint.format())
);

// Clean Docs
gulp.task('cleanDoc', () => del([
  'docs/**',
  '!docs'
], {dot: true}));

// Clean Static Resource
gulp.task('clean', () => del([
  '../force-app/main/default/staticresources/FieloElr_Salesforce/**',
  '!../force-app/main/default/staticresources/FieloElr_Salesforce',
  '../force-app/main/core/staticresources/FieloSalesforce_Backend/**',
  '!../force-app/main/core/staticresources/FieloSalesforce_Backend'
], {
  dot: true,
  force: true
}));

// Copy vendor files
gulp.task('vendor', ['cleanVendor'], () => {
  return gulp.src(
      ['resources/FieloElr_Backend/vendor/**/*'], {
        dot: true
      })
    .pipe(gulp.dest('../force-app/main/core/staticresources/FieloSalesforce_Backend/'))
    .pipe($.size({
      title: 'copy'
    }));
});

// Clean Vendor
gulp.task('cleanVendor', () => del([
  '../force-app/main/core/staticresources/FieloSalesforce_Backend/**',
  '!../force-app/main/core/staticresources/FieloSalesforce_Backend/',
  '!../force-app/main/core/staticresources/FieloSalesforce_Backend/fielo/**',
  '!../force-app/main/core/staticresources/FieloSalesforce_Backend/images/**'
], {
  dot: true,
  force: true
}));

// Build production site files
gulp.task('build', ['clean'], cb => {
  runSequence(
    'vendor', 'images', 'js', 'css',
    cb
  );
});


// Gulp default task
gulp.task('default', cb => {
  runSequence(
    'build',
    cb
  );
});