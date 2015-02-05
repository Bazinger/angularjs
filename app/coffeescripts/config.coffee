vprApp.run [ '$rootScope', '$location', ($rootScope, $location) ->
  $rootScope.goto = (route) ->
    $location.path route
]


