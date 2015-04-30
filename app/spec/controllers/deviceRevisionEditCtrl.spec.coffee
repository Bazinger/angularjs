describe "Unit: Testing Controllers", () ->
  beforeEach module('ngRoute')
  beforeEach module('vprAppControllers')

  $controller = undefined
  $scope = undefined
  DeviceRevisionEditCtrl = undefined
  deviceSvc = undefined
  blockSvc = undefined
  mockTest = {
    id : "1"
    rev_id : "111"
    branch : "default"
    tags : []
    test_params: []
  }

  beforeEach inject (_$controller_,$rootScope,$q,_$routeParams_,_testSvc_,_dataSvc_) ->
    $scope = $rootScope.$new()
    $routeParams = _$routeParams_

    dataSvc = _dataSvc_

    d = $q.defer()
    d.resolve '123'
    spyOn(dataSvc,'asyncNewId').and.returnValue d.promise


    $controller = _$controller_

    $scope.$digest()

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