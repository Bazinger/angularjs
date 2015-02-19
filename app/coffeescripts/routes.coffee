
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
    .when '/tests/:type/:revisionId', {
      controller: 'TestCtrl'
      templateUrl: 'testList.template'
    }
    .when '/editTest/:type/:testId/:revId?', {
      controller: 'TestEditCtrl'
      templateUrl: 'editTest.template'
    }
    .otherwise {
      controller: 'HomeCtrl'
      templateUrl: 'home.template'
    }
]
