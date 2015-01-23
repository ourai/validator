module.exports = ( grunt ) ->
  pkg = grunt.file.readJSON "package.json"
  info =
    name: pkg.name.charAt(0).toUpperCase() + pkg.name.substring(1)
    version: pkg.version
  npmTasks = [
      "grunt-contrib-coffee"
      "grunt-contrib-uglify"
      "grunt-contrib-concat"
      "grunt-contrib-copy"
      "grunt-contrib-clean"
    ]

  grunt.initConfig
    repo: info
    pkg: pkg
    meta:
      base: "src/javascripts/base"

      modules: "src/javascripts/modules"
      mod_cmpt: "<%= meta.modules %>/Component"

      temp: ".<%= pkg.name %>-cache"
      image: "src/images"

      dest: "dest"
      dest_script: "<%= meta.dest %>/javascripts"

      tests: "test"
    concat:
      coffee:
        files:
          "<%= meta.temp %>/<%= pkg.name %>.coffee": [
              "src/validator.coffee"
              "src/form.coffee"
            ]
      js_normal:
        options:
          process: ( src, filepath ) ->
            return src.replace /@(NAME|VERSION)/g, ( text, key ) ->
              return info[key.toLowerCase()]
        src: [
            "build/intro.js"
            "<%= meta.temp %>/<%= pkg.name %>.js"
            "build/outro.js"
          ]
        dest: "<%= meta.dest_script %>/<%= pkg.name %>.js"
    coffee:
      options:
        bare: true
        separator: "\x20"
      build_normal:
        src: "<%= meta.temp %>/<%= pkg.name %>.coffee"
        dest: "<%= meta.temp %>/<%= pkg.name %>.js"
      test:
        src: "<%= meta.tests %>/test.coffee"
        dest: "<%= meta.tests %>/test.js"
    uglify:
      options:
        banner: "/*!\n" +
                " * <%= repo.name %> UI Library v<%= repo.version %>\n" +
                " * <%= pkg.homepage %>\n" +
                " *\n" +
                " * Copyright 2013, <%= grunt.template.today('yyyy') %> Ourairyu, http://ourai.ws/\n" +
                " *\n" +
                " * Date: <%= grunt.template.today('yyyy-mm-dd') %>\n" +
                " */\n"
        sourceMap: true
      build_normal:
        src: "<%= meta.dest_script %>/<%= pkg.name %>.js"
        dest: "<%= meta.dest_script %>/<%= pkg.name %>.min.js"
    copy:
      test:
        expand: true
        cwd: "<%= meta.dest %>"
        src: ["images/*", "javascripts/*"]
        dest: "<%= meta.tests %>"
    clean:
      compiled:
        src: ["<%= meta.temp %>/**"]

  grunt.loadNpmTasks task for task in npmTasks

  # Tasks about CoffeeScript
  grunt.registerTask "compile_coffee", [
      "concat:coffee"
      "coffee:build_normal"
      "concat:js_normal"
      "uglify"
    ]
  grunt.registerTask "test", [
      # "coffee:test"
      "copy:test"
    ]
  # Default task
  grunt.registerTask "default", [
      "compile_coffee"
      "clean"
      "test"
    ]