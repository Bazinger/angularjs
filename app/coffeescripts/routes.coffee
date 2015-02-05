
vprApp.config ['$routeProvider', ($routeProvider) ->

  $routeProvider
    .when '/blocks', {
      controller: 'BlockCtrl'
      templateUrl: 'blockList.template'
    }
    .when '/block/listRevisions', {
      controller: 'BlockRevisionListCtrl',
      templateUrl: 'blockRevisionList.template'
    }
    .when '/editBlock/:blockId', {
      controller: 'BlockEditCtrl'
      templateUrl: 'editBlock.template'
    }
    .otherwise {
      controller: 'HomeCtrl'
      templateUrl: 'home.template'
    }
]
