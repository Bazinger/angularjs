describe "Unit: Testing Controllers", () ->
  beforeEach module('ngRoute')
  beforeEach module('vprAppControllers')

  $controller = undefined
  $scope = undefined
  $q = undefined
  DeviceRevisionEditCtrl = undefined
  deviceSvc = undefined
  blockSvc = undefined
  testSvc = undefined
  dataSvc = undefined
  utilSvc = undefined
  mockTest = {
    id : "1"
    rev_id : "111"
    branch : "default"
    tags : []
    test_params: []
  }

  beforeEach inject (_$controller_,$rootScope,_$q_,_$routeParams_,_testSvc_,_blockSvc_,_dataSvc_,_deviceSvc_,_utilSvc_) ->
    $scope = $rootScope.$new()
    $routeParams = _$routeParams_
    $q = _$q_

    testSvc = _testSvc_
    blockSvc = _blockSvc_
    dataSvc = _dataSvc_
    deviceSvc = _deviceSvc_
    utilSvc = _utilSvc_

    d = $q.defer()
    d.resolve '123'
    spyOn(dataSvc,'asyncNewId').and.returnValue d.promise


    $controller = _$controller_
    
    $scope.$digest()


  describe "DeviceRevisionEditCtrl", () ->
    beforeEach () ->
      #$scope.editDeviceRevision.block_revisions = [1,2]
      DeviceRevisionEditCtrl = $controller('DeviceRevisionEditCtrl',{$scope:$scope,$routeParams: {testId:"1",revId:"1",type:"tests"},deviceSvc: deviceSvc,blockSvc: blockSvc,testSvc: testSvc,utilSvc: utilSvc})
      $scope.editDeviceRevision = {block_revisions: [1,2]}
      d1 = $q.defer()
      d1.resolve $scope.editDeviceRevision.block_revisions[0]
      spyOn(testSvc,'asyncTestsForRev').and.returnValue d1.promise
      
      
      
    it "should be defined", () ->
      expect(DeviceRevisionEditCtrl).toBeDefined()

    describe "#loadDeviceParams", () ->
      it "should be defined", () ->
        expect($scope.loadDeviceParams).toBeDefined()
        expect($scope.editDeviceRevision).toBeDefined()
        expect($scope.editDeviceRevision.block_revisions).toBeDefined()
        $scope.loadDeviceParams()



#  describe 'deviceRevisionEditCtrl create new deviceRevision', () ->
#    beforeEach () ->
#      DeviceRevisionEditCtrl = $controller('DeviceRevisionEditCtrl',{$scope:$scope,$routeParams: {testId:"new",revId:"rev1",type:"tests"},testSvc:testSvc,dataSvc:dataSvc})
#
#    it 'should be defined', () ->
#      expect(TestEditCtrl).toBeDefined()
#
#    it 'should have scope defined', () ->
#      expect($scope).toBeDefined()
#
#    describe 'create a new test', () ->
#      it 'should set newTest to true', () ->
#        expect($scope.newTest).toBeTruthy()