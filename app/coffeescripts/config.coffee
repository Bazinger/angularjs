vprApp.run [ '$rootScope', '$location', ($rootScope, $location) ->
  $rootScope.goto = (route) ->
    $location.path route

  $rootScope.formatTags = (tags) ->
    tags.join ', '
]


