---
layout: post
title: Using Grunt with angular-seed
published: 1
categories: [JavaScript, AngularJS]
comments: []
slug: "..."
---

*This post contains step-by-step instructions to enable development and deployment task automation for [angular-seed](https://github.com/angular/angular-seed) projects using [Grunt](http://gruntjs.com/).*

**Step 1 – Preparing to use Grunt**

To make sure that no npm errors will propagate during the installation of npm packages it is recommended to clean the npm cache.

[*".. clear you cache! It might save you from switching professions."*](http://codebetter.com/glennblock/2012/02/27/my-tale-of-npm-woe-when-all-else-fails-clear-you-cache/) -- Glenn Block

```
$ npm cache clean
```

Next, install Grunt's command line interface, [grunt-cli](https://github.com/gruntjs/grunt-cli).

```
$ npm install -g grunt-cli
```

In fact, grunt-cli is the only required globally installed npm module to demo this post.

```
$ npm list -g -depth=0
C:\Users\Nikos\AppData\Roaming\npm
└── grunt-cli@0.1.13
```

**Step 2 - Create a Gruntfile.js in the root directory**

```
'use strict';

module.exports = function (grunt) {

  require('load-grunt-tasks')(grunt);
  require('time-grunt')(grunt);

  grunt.initConfig({

    myApp: {
      app: require('./bower.json').appPath || 'app',
      dist: 'dist'
    },

    typescript: {
      base: {
        src: ['<%= myApp.app %>/js/{,*/}*.ts'],
        options: {
          target: 'es5',
          sourceMap: true
        }
      },
      test: {
        src: ['test/unit/{,*/}*.ts'],
        options: {
          target: 'es5',
          sourceMap: true
        }
      }
    },

    watch: {
      ts: {
        files: ['<%= myApp.app %>/js/{,*/}*.ts'],
        tasks: ['typescript']
      },
      tsTest: {
        files: ['test/unit/{,*/}*.ts'],
        tasks: ['typescript:test']
      },
      js: {
        files: ['<%= myApp.app %>/js/{,*/}*.js'],
        tasks: ['newer:jshint:all'],
        options: {
          livereload: true
        }
      },
      jsTest: {
        files: ['test/unit/{,*/}*.js'],
        tasks: ['newer:jshint:test', 'karma']
      },
      styles: {
        files: ['<%= myApp.app %>/css/{,*/}*.css'],
        tasks: ['newer:copy:styles', 'autoprefixer']
      },
      gruntfile: {
        files: ['Gruntfile.js']
      },
      livereload: {
        options: {
          livereload: '<%= connect.options.livereload %>'
        },
        files: [
          '<%= myApp.app %>/{,*/}*.html',
          '.tmp/css/{,*/}*.css',
          '<%= myApp.app %>/img/{,*/}*.{png,jpg,jpeg,gif,webp,svg}'
        ]
      }
    },

    connect: {
      options: {
        port: 9000,
        hostname: 'localhost',
        livereload: 35729
      },
      livereload: {
        options: {
          open: true,
          base: [
            '.tmp',
            '<%= myApp.app %>'
          ]
        }
      },
      test: {
        options: {
          port: 9001,
          base: [
            '.tmp',
            'test',
            '<%= myApp.app %>'
          ]
        }
      },
      dist: {
        options: {
          base: '<%= myApp.dist %>'
        }
      }
    },

    jshint: {
      options: {
        jshintrc: '.jshintrc',
        reporter: require('jshint-stylish')
      },
      all: [
        'Gruntfile.js',
        '<%= myApp.app %>/js/{,*/}*.js'
      ],
      test: {
        options: {
          jshintrc: '.jshintrc'
        },
        src: ['test/unit/{,*/}*.js']
      }
    },

    clean: {
      dist: {
        files: [{
          dot: true,
          src: [
            '.tmp',
            '<%= myApp.dist %>/*',
            '!<%= myApp.dist %>/.git*'
          ]
        }]
      },
      server: '.tmp'
    },

    autoprefixer: {
      options: {
        browsers: ['last 1 version']
      },
      dist: {
        files: [{
          expand: true,
          cwd: '.tmp/css/',
          src: '{,*/}*.css',
          dest: '.tmp/css/'
        }]
      }
    },

    'bower-install': {
      app: {
        html: '<%= myApp.app %>/index.html',
        ignorePath: '<%= myApp.app %>/'
      }
    },

    rev: {
      dist: {
        files: {
          src: [
            '<%= myApp.dist %>/js/{,*/}*.js',
            '<%= myApp.dist %>/css/{,*/}*.css',
            '<%= myApp.dist %>/img/{,*/}*.{png,jpg,jpeg,gif,webp,svg}',
            '<%= myApp.dist %>/css/fonts/*'
          ]
        }
      }
    },

    useminPrepare: {
      html: '<%= myApp.app %>/index.html',
      options: {
        dest: '<%= myApp.dist %>'
      }
    },

    usemin: {
      html: ['<%= myApp.dist %>/{,*/}*.html'],
      css: ['<%= myApp.dist %>/css/{,*/}*.css'],
      options: {
        assetsDirs: ['<%= myApp.dist %>']
      }
    },

    imagemin: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= myApp.app %>/img',
          src: '{,*/}*.{png,jpg,jpeg,gif}',
          dest: '<%= myApp.dist %>/img'
        }]
      }
    },
    svgmin: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= myApp.app %>/img',
          src: '{,*/}*.svg',
          dest: '<%= myApp.dist %>/img'
        }]
      }
    },
    htmlmin: {
      dist: {
        options: {
          collapseWhitespace: true,
          collapseBooleanAttributes: true,
          removeCommentsFromCDATA: true,
          removeOptionalTags: true
        },
        files: [{
          expand: true,
          cwd: '<%= myApp.dist %>',
          src: ['*.html', 'partials/{,*/}*.html'],
          dest: '<%= myApp.dist %>'
        }]
      }
    },

    ngmin: {
      dist: {
        files: [{
          expand: true,
          cwd: '.tmp/concat/js',
          src: '*.js',
          dest: '.tmp/concat/js'
        }]
      }
    },

    cdnify: {
      dist: {
        html: ['<%= myApp.dist %>/*.html']
      }
    },

    copy: {
      dist: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= myApp.app %>',
          dest: '<%= myApp.dist %>',
          src: [
            '*.{ico,png,txt}',
            '.htaccess',
            '*.html',
            'partials/{,*/}*.html',
            'bower_components/**/*',
            'img/{,*/}*.{webp}',
            'fonts/*'
          ]
        }, {
          expand: true,
          cwd: '.tmp/img',
          dest: '<%= myApp.dist %>/img',
          src: ['generated/*']
        }]
      },
      styles: {
        expand: true,
        cwd: '<%= myApp.app %>/css',
        dest: '.tmp/css/',
        src: '{,*/}*.css'
      }
    },

    concurrent: {
      server: [
        'copy:styles'
      ],
      test: [
        'copy:styles'
      ],
      dist: [
        'copy:styles',
        'imagemin',
        'svgmin'
      ]
    },

    replace: {
      development: {
        options: {
          patterns: [{
            json: grunt.file.readJSON(
              'config.development.json')
          }]
        },
        files: [{
          expand: true,
          flatten: true,
          src: ['config.js'],
          dest: '<%= myApp.app %>/js'
        }]
      },
      azure: {
        options: {
          patterns: [{
            json: grunt.file.readJSON('config.azure.json')
          }]
        },
        files: [{
          expand: true,
          flatten: true,
          src: ['config.js'],
          dest: '<%= myApp.app %>/js'
        }]
      }
    },

    karma: {
      unit: {
        configFile: './test/karma.conf.js',
        singleRun: true
      }
    }
  });

  grunt.registerTask('serve', function (target) {
    if (target === 'dist') {
      return grunt.task.run(['build', 'connect:dist:keepalive']);
    }

    grunt.task.run([
      'clean:server',
      'bower-install',
      'concurrent:server',
      'autoprefixer',
      'connect:livereload',
      'replace:development',
      'watch'
    ]);
  });

  grunt.registerTask('server', function () {
    grunt.log.warn(
      'The `server` task has been deprecated. Use `grunt serve` to start a server.'
    );
    grunt.task.run(['serve']);
  });

  grunt.registerTask('test', [
    'clean:server',
    'concurrent:test',
    'autoprefixer',
    'connect:test',
    'karma'
  ]);

  grunt.registerTask('build', [
    'clean:dist',
    'bower-install',
    'useminPrepare',
    'concurrent:dist',
    'autoprefixer',
    'concat',
    'ngmin',
    'copy:dist',
    'cdnify',
    'cssmin',
    'uglify',
    'rev',
    'usemin',
    'htmlmin'
  ]);

  grunt.registerTask('default', [
    'newer:jshint',
    'test',
    'build'
  ]);
};
```

This is quite a sophisticated Gruntfile, with reasonable defaults and best practises, composed by [generator-angular](https://github.com/yeoman/generator-angular), as well as this [post](http://newtriks.com/2013/11/29/environment-specific-configuration-in-angularjs-using-grunt/), and this [post](http://nikosbaxevanis.com/blog/2014/04/03/typescript-slash-grunt-slash-angular/).

**Step 3 – Add environment specific configuration files**

```
{
  "name": "value"
}
```

Save the above key-value placeholder as **config.azure.json** and **config.development.json** in the root directory.


**Step 4 – Make angular-mocks a Bower development-dependency**

```
diff --git a/bower.json b/bower.json
@@ -9,7 +9,9 @@
     "angular": "1.2.x",
     "angular-route": "1.2.x",
     "angular-loader": "1.2.x",
-    "angular-mocks": "~1.2.x",
     "html5-boilerplate": "~4.3.0"
-  }
+  },
+  "devDependencies": {
+    "angular-mocks": "~1.2.x"
+   }
 }
```

(Currently [bower.json](https://github.com/angular/angular-seed/blob/238b1a9aaa34e6ef98c6aaa0418c24c0c19dd2e3/bower.json) includes `angular-mocks` as an application dependency, although it's really a development/testing dependency.)

**Step 5 – Add the npm packages required by Grunt**

```
diff --git a/package.json b/package.json
@@ -11,12 +11,52 @@
     "http-server": "^0.6.1",
     "bower": "^1.3.1",
     "shelljs": "^0.2.6",
-    "karma-junit-reporter": "^0.2.2"
+    "karma-junit-reporter": "^0.2.2",
+    "grunt": "~0.4.1",
+    "grunt-cli": "~0.1.13",
+    "grunt-autoprefixer": "~0.4.0",
+    "grunt-bower-install": "~0.7.0",
+    "grunt-concurrent": "~0.4.1",
+    "grunt-contrib-clean": "~0.5.0",
+    "grunt-contrib-coffee": "~0.7.0",
+    "grunt-contrib-compass": "~0.6.0",
+    "grunt-contrib-concat": "~0.3.0",
+    "grunt-contrib-connect": "~0.5.0",
+    "grunt-contrib-copy": "~0.4.1",
+    "grunt-contrib-cssmin": "~0.7.0",
+    "grunt-contrib-htmlmin": "~0.1.3",
+    "grunt-contrib-imagemin": "~0.3.0",
+    "grunt-contrib-jshint": "~0.7.1",
+    "grunt-contrib-uglify": "~0.2.0",
+    "grunt-contrib-watch": "~0.5.2",
+    "grunt-google-cdn": "~0.2.0",
+    "grunt-karma": "~0.6.2",
+    "grunt-newer": "~0.5.4",
+    "grunt-ngmin": "~0.0.2",
+    "grunt-replace": "~0.7.6",
+    "grunt-rev": "~0.1.0",
+    "grunt-svgmin": "~0.2.0",
+    "grunt-typescript": "*",
+    "grunt-usemin": "~2.0.0",
+    "jshint-stylish": "~0.1.3",
+    "load-grunt-tasks": "~0.2.0",
+    "requirejs": "~2.1.10",
+    "time-grunt": "~0.2.1",
+    "karma-ng-scenario": "~0.1.0",
+    "karma-html2js-preprocessor": "~0.1.0",
+    "karma-firefox-launcher": "~0.1.3",
+    "karma-script-launcher": "~0.1.0",
+    "karma-chrome-launcher": "~0.1.2",
+    "karma-jasmine": "~0.1.5",
+    "karma-coffee-preprocessor": "~0.1.2",
+    "karma-requirejs": "~0.2.1",
+    "karma-phantomjs-launcher": "~0.1.1",
+    "karma-ng-html2js-preprocessor": "~0.1.0"
   },
   "scripts": {
     "postinstall": "bower install",
 
-    "prestart": "npm install",
+    "prestart": "npm install && grunt bower-install",
     "start": "http-server -a localhost -p 8000",
 
     "pretest": "npm install",
```

**Step 6 – Install locally the npm and Bower packages**

```
npm install
```

This has been pre-configured by angular-seed to also automatically call `bower install`. Two new folders will be created in the project:

* node_modules, containing the required npm packages for the tools
* app/bower_components, containing the AngularJS framework files

This normally takes a while.

**Step 7 – Inject some awesomeness to index.html**

```
diff --git a/app/index.html b/app/index.html
@@ -9,9 +9,15 @@
   <title>My AngularJS App</title>
   <meta name="description" content="">
   <meta name="viewport" content="width=device-width, initial-scale=1">
+  <!-- build:css styles/vendor.css -->
   <link rel="stylesheet" href="bower_components/html5-boilerplate/css/normalize.css">
   <link rel="stylesheet" href="bower_components/html5-boilerplate/css/main.css">
+  <!-- bower:css -->
+  <!-- endbower -->
+  <!-- endbuild -->
+  <!-- build:css({.tmp,app}) styles/main.css -->
   <link rel="stylesheet" href="css/app.css"/>
+  <!-- endbuild -->
   <script src="bower_components/html5-boilerplate/js/vendor/modernizr-2.6.2.min.js"></script>
 </head>
 <body>
@@ -31,12 +37,19 @@
   <!-- In production use:
   <script src="//ajax.googleapis.com/ajax/libs/angularjs/x.x.x/angular.min.js"></script>
   -->
+  <!-- build:js scripts/vendor.js -->
+  <!-- bower:js -->
   <script src="bower_components/angular/angular.js"></script>
   <script src="bower_components/angular-route/angular-route.js"></script>
+  <!-- endbower -->
+  <!-- endbuild -->
+
+  <!-- build:js({.tmp,app}) scripts/scripts.js -->
   <script src="js/app.js"></script>
   <script src="js/services.js"></script>
   <script src="js/controllers.js"></script>
   <script src="js/filters.js"></script>
   <script src="js/directives.js"></script>
+  <!-- endbuild -->
 </body>
 </html>
```

The `build-css` tag bundles and minifies CSS while `build:js` bundles and minifies the scripts.

**Run the angular-seed application**

```
npm start
```

This is already pre-configured by angular-seed with a simple development web server.

In addition, [grunt-bower-install](https://www.npmjs.org/package/grunt-bower-install) is invoked to look at all bower.json components and determine the best order to inject their scripts in the HTML file.

> That is also the reason why we injected `build:js` tags in the index.html.

**Run the angular-seed application – using Grunt**

```
grunt serve
```

Modify the index.html, partial views, TypeScript<sup>1</sup>, or JavaScript files to see everything in action.

**Deploying**

```
grunt
```

This normally takes a few seconds<sup>2</sup>.

```
Done, without errors.

Execution Time (2014-06-02 21:57:42 UTC)
concurrent:test    2.3s  ■■■■■■■■■■■■■■■■■■■■ 14%
karma:unit         4.5s  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 27%
concurrent:dist    6.5s  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 40%
copy:dist         381ms  ■■■■ 2%
uglify:generated   1.9s  ■■■■■■■■■■■■■■■■■ 12%
Total 16.3s
```

Pretty cool!

<br>
<br>

-----

<sup>1</sup>To enable *.ts auto-compilation install TypeScript with `npm install -g TypeScript`.


<sup>2</sup>In case of JSHint errors, under the `globals` directive in `.jshintrc` add the variables below:

```
diff --git a/.jshintrc b/.jshintrc
@@ -1,6 +1,13 @@
 {
   "globalstrict": true,
   "globals": {
-    "angular": false
+    "angular"   : false,
+    "module"    : false,
+    "require"   : false,
+    "describe"  : false,
+    "beforeEach": false,
+    "it"        : false,
+    "inject"    : false,
+    "expect"    : false
   }
 }
```