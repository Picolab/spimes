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

var myApp = angular.module('myApp', ['infinite-scroll']);
myApp.controller('DemoController', function($scope) {
  $scope.images = [1, 2, 3, 4, 5, 6, 7, 8];

  $scope.loadMore = function() {
    var last = $scope.images[$scope.images.length - 1];
    for(var i = 1; i <= 8; i++) {
      $scope.images.push(last + i);
    }
  };
});



