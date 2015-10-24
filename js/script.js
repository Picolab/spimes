var app=angular.module('single-page-app',['ngRoute']);


app.config(function($routeProvider){


      $routeProvider
          .when('/',{
                templateUrl: 'pages/home.html'
          })
          .when('/spimes',{
                templateUrl: 'pages/spimes.html'
          })
          .when('/about',{
                templateUrl: 'pages/about.html'
          });


});


app.controller('cfgController',function($scope){

      $scope.message="Hello world";

});
