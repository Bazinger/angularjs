describe "Unit: Testing Controllers", () ->
  beforeEach module('ngRoute')
  beforeEach module('vprAppControllers')

  $controller = undefined
  $scope = undefined
  TestEditCtrl = undefined

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
    testSvc = _testSvc_

    d = $q.defer()
    d.resolve '123'
    spyOn(dataSvc,'asyncNewId').and.returnValue d.promise

    d1 = $q.defer()
    d1.resolve mockTest
    spyOn(testSvc,'asyncTest').and.returnValue d1.promise

    d2 = $q.defer()
    d2.resolve ['default','foo','bar','baz']
    spyOn(testSvc,'asyncBranchesForTest').and.returnValue d2.promise

    d3 = $q.defer()
    d3.resolve()
    spyOn(testSvc,'asyncSaveAndRevisionTest').and.returnValue d3.promise

    d4 = $q.defer()
    d4.resolve()
    spyOn(testSvc,'asyncChangeBranch').and.returnValue d4.promise


#    $controller = (routeParams) ->
#      _$controller_('TestEditCtrl',{$scope:$scope,$routeParams: routeParams,testSvc:testSvc,dataSvc:dataSvc})
    $scope.$digest()


  describe 'TestEditCtrl create new test', () ->
    beforeEach () ->
      TestEditCtrl = $controller('TestEditCtrl',{$scope:$scope,$routeParams: {testId:"new",revId:"rev1",type:"tests"},testSvc:testSvc,dataSvc:dataSvc})

    it 'should be defined', () ->
      expect(TestEditCtrl).toBeDefined()

    it 'should have scope defined', () ->
      expect($scope).toBeDefined()

    describe 'create a new test', () ->
      it 'should set newTest to true', () ->
        expect($scope.newTest).toBeTruthy()



