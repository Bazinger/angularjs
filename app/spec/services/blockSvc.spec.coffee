describe "Unit: Testing BlockSvc", () ->
  beforeEach module('vprAppServices')

  blockSvc = undefined
  testSvc = undefined
  $scope = undefined

  testsForRev = [{
    id: 1
    rev_id: 10
    is_current: true
    test_params: [
      {name: 'device_param1', value: '1/#{1PLACEHOLDER1}'}
      {name: 'device_param2', value: 'TEST/#{2PLACEHOLDER2}/#{3PLACEHOLDER3}'}
      {name: 'test_param1', value: 'NOT_A_PLACEHOLDER'}
    ]
  },{
    id: 2
    rev_id: 10
    test_params: [
      {name: 'device_param3', value: '1/#{4PLACEHOLDER4}'}
      {name: 'device_param4', value: 'TEST/#{5PLACEHOLDER5}/#{6PLACEHOLDER6}'}
      {name: 'test_param2', value: 'NOT_A_PLACEHOLDER'}
    ]
  }]
  beforeEach inject (_blockSvc_,_testSvc_,$rootScope,$q) ->
    $scope = $rootScope.$new()
    blockSvc = _blockSvc_
    testSvc = _testSvc_

    d = $q.defer()
    d.resolve testsForRev
    spyOn(testSvc,'asyncTestsForRev').and.returnValue d.promise

    $scope.$digest()

  describe "#parseDeviceParams", () ->

    it "should be defined", () ->
      expect(blockSvc.parseDeviceParams).toBeDefined()

    it "should correctly parse parameters with a placeholder and ignore others", () ->
      result = blockSvc.parseDeviceParams(testsForRev[0])
      console.log result[0]
      #expect(result[0]).toEqual({ name: 'device_param1', value: '1PLACEHOLDER1', default: true})
      expect(result[1]).toEqual({name:'device_param2',placeholders: ['2PLACEHOLDER2','3PLACEHOLDER3']})
  describe "#asyncDefaultParamsForBlockRevision", () ->
    it "should be defined", () ->
      expect(blockSvc.asyncDefaultParamsForBlockRevision).toBeDefined()
    #it "should"