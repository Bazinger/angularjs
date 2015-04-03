
vprApp.config ['$routeProvider', ($routeProvider) ->

  $routeProvider
    .when '/devices/:activeDevice?', {
      controller: 'DeviceCtrl'
      templateUrl: 'deviceList.template'
    }
    .when '/device/listRevisions', {
      controller: 'DeviceRevisionListCtrl',
      templateUrl: 'deviceRevisionList.template'
    }
    .when '/editDevice/:deviceId', {
      controller: 'DeviceEditCtrl'
      templateUrl: 'editDevice.template'
    }
    .when '/editDeviceRevision/:deviceId/:revisionId', {
      controller: 'DeviceRevisionEditCtrl'
      templateUrl: 'editDeviceRevision.template'
    }
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
    .when '/testHistory/:type/:testId', {
      controller: 'TestHistoryCtrl',
      templateUrl: 'testHistory.template'
    }
    .otherwise {
      controller: 'HomeCtrl'
      templateUrl: 'home.template'
    }
]
