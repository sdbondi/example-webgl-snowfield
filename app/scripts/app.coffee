'use strict'

angular.module('webglExamples', [])
  .config ($routeProvider) ->
    $routeProvider
    	.when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .otherwise
        redirectTo: '/'
