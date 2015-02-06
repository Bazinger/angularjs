
vprApp.config ['$routeProvider', ($routeProvider) ->

  $routeProvider
    .when '/blocks/:activeBlock?', {
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
    .when '/editBlockRevision/:blockId/:revisionId', {
      controller: 'BlockRevisionEditCtrl'
      templateUrl: 'editBlockRevision.template'
    }
    .otherwise {
      controller: 'HomeCtrl'
      templateUrl: 'home.template'
    }
]
