#= require try_api/bower_components/highlightjs/highlight.pack.min.js
#= require try_api/bower_components/angular-bootstrap/ui-bootstrap.js
#= require try_api/bower_components/angular-bootstrap/ui-bootstrap-tpls.js
#= require try_api/bower_components/angular-highlightjs/angular-highlightjs.min.js
#= require try_api/bower_components/ladda/dist/spin.min.js
#= require try_api/bower_components/ladda/dist/ladda.min.js
#= require try_api/bower_components/angular-ladda/dist/angular-ladda.min.js
#= require try_api/params.directive
#= require try_api/param.directive
#= require try_api/paramsarray.directive
#= require try_api/image.directive
#= require try_api/url.directive

$ ->
  $('pre code').each (i, block) ->
    hljs.highlightBlock(block)


  $('.try-api-sidebar-menu').slimScroll
    height: '100%'

  Ladda.bind '.progress-demo button', callback: (instance) ->
    progress = 0
    interval = setInterval((->
      progress = Math.min(progress + Math.random() * 0.1, 1)
      instance.setProgress progress
      if progress == 1
        instance.stop()
        clearInterval interval
      return
    ), 200)
    return


TryApiApp = angular.module('TryApiApp', [
  'ui.bootstrap'
  'ngAnimate'
  'TryApi'
  'angular-ladda'
  'hljs'
])
TryApiApp.config [
  '$httpProvider'
  'hljsServiceProvider'
  ($httpProvider, hljsServiceProvider) ->
    hljsServiceProvider.setOptions
      tabReplace: '  '
]
TryApiApp.run [
  '$http'
  '$rootScope'
  ($http, $rootScope) ->
]

TryApiApp.controller 'HomeController', [
  '$scope'
  '$timeout'
  '$sce'
  '$http'
  ($scope, $timeout, $sce, $http) ->

    $scope.getStatusCodeClass = (code) ->
      switch true
        when code >= 200 && code < 300
          return 'text-success'
        when code >= 300 && code < 400
          return 'text-warning'
        when code >= 400 && code < 500
          return 'text-danger'
        when code >= 500
          return 'text-danger'
        else
          return 'text-info'

    $scope.headers = []
    $scope.params = []

]

TryApiApp.controller 'HomeController', [
  '$scope'
  '$timeout'
  '$sce'
  '$http'
  ($scope, $timeout, $sce, $http) ->


    $scope.getHtml = (html) ->
      return $sce.trustAsHtml(html)

    $scope.getStatusCodeClass = (code) ->
      switch true
        when code >= 200 && code < 300
          return 'text-success'
        when code >= 300 && code < 400
          return 'text-warning'
        when code >= 400 && code < 500
          return 'text-danger'
        when code >= 500
          return 'text-danger'
        else
          return 'text-info'

    $scope.headers = []
    $scope.global_headers = {}
    $scope.params = []

    $http.get('/developers/projects.json').success (data) ->
      $scope.project = data.project
      $.each $scope.project.menu_items, () ->
        menu_item = this
        $.each menu_item.methods, ()->
          method = this
          method.pending = false
          method.response_handler = (data, status, headers, config) ->
            method.pending = false
            try # TODO catch different types of response
              data = JSON.stringify(data, null, 2)
            catch e

            method.response =
              data: data
              headers: JSON.stringify(config.headers, null, 2)
              status: status

          method.submit = ->
            method.pending = true
            headers = {'Content-Type': undefined}

            $.each method.headers, (i)->
              header = this
              headers[header.name] = header.value

            switch method.method.toLowerCase()
              when 'post'
                fd = new FormData
                fd.append 'a', 'a' # TODO sending empty array causes EOFError

                $.each method.parameters, (i) ->
                  if this.value
                    $scope.addParameterToForm fd, this

                $http.post method.submit_path, fd,
                  transformRequest: angular.identity
                  headers: headers
                .success method.response_handler
                .error method.response_handler
              when 'delete'
                $http.delete method.submit_path,
                  transformRequest: angular.identity
                  headers: headers
                .success method.response_handler
                .error method.response_handler
              when 'get'
                fd = ''

                $.each method.parameters, (i) ->
                  parameter = this
                  if this.value
                    fd = fd + parameter.name + '=' + (parameter.value || '') + '&'

                $http.get method.submit_path + '?' + fd,
                  transformRequest: angular.identity
                  headers: headers
                .success method.response_handler
                .error method.response_handler
              when 'put'
                fd = new FormData
                fd.append 'a', 'a' # TODO sending empty array causes EOFError

                $.each method.parameters, (i) ->
                  if this.value
                    $scope.addParameterToForm fd, this

                $http.put method.submit_path, fd,
                  transformRequest: angular.identity
                  headers: headers
                .success method.response_handler
                .error method.response_handler

    $scope.addParameterToForm = (form, parameter) -> # TODO implement multidimentional parameters
      if parameter.type == 'array'
        form.append 'a', 'a' # TODO sending empty array causes EOFError
        $.each parameter.values, ->
          value = this
          $.each value, ->
            subparameter = this
            switch subparameter.type
              when 'boolean'
                form.append parameter.name + '[]' + subparameter.name, subparameter.value || false
              else
                form.append parameter.name + '[]' + subparameter.name, subparameter.value || ''
      else
        form.append parameter.name, parameter.value || ''
]
