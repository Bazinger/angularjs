describe "Unit: Testing BlockSvc", () ->
  beforeEach module('vprAppServices')

  blockSvc = undefined
  testSvc = undefined
  $scope = undefined
  deferred = undefined

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
      {name: 'device_param7', value: '5/#{4PLACEHOLDER4}'}
    ]
  }]

  beforeEach inject (_blockSvc_,_testSvc_,$rootScope,_$q_) ->
    $scope = $rootScope.$new()
    blockSvc = _blockSvc_
    testSvc = _testSvc_
    $q = _$q_

  # describe "#parseDeviceParams", () ->
  #   it "should return a data structure of the form array[<PLACEHOLDER>] = [{usage:<USAGE>,name:<PARAM_NAME>},...]", () ->
  #     results = blockSvc.parseDeviceParams testsForRev
  #     expect(results[0]).toEqual {placeholder:'1PLACEHOLDER1',default:true, value: '',references: [{name:'device_param1',usage:'1/#{1PLACEHOLDER1}'}]}
  #     expect(results[1]).toEqual {placeholder:'2PLACEHOLDER2',default:true, value: '',references: [{name:'device_param2',usage:'TEST/#{2PLACEHOLDER2}/#{3PLACEHOLDER3}'}]}
  #     expect(results[2]).toEqual {placeholder:'3PLACEHOLDER3',default:true, value: '',references: [{name:'device_param2',usage:'TEST/#{2PLACEHOLDER2}/#{3PLACEHOLDER3}'}]}
  #     expect(results[3]).toEqual {
  #       placeholder:'4PLACEHOLDER4',
  #       default:true, 
  #       value: '',
  #       references: [{
  #         name:'device_param3',
  #         usage:'1/#{4PLACEHOLDER4}'
  #       },{
  #         name:'device_param7',
  #         usage:'5/#{4PLACEHOLDER4}'
  #       }]}
  #     expect(results[4]).toEqual {placeholder:'5PLACEHOLDER5',default:true, value: '',references: [{name:'device_param4',usage:'TEST/#{5PLACEHOLDER5}/#{6PLACEHOLDER6}'}]}
  #     expect(results[5]).toEqual {placeholder:'6PLACEHOLDER6',default:true, value: '',references: [{name:'device_param4',usage:'TEST/#{5PLACEHOLDER5}/#{6PLACEHOLDER6}'}]}


  #     #expect(results).toEqual 
  # describe "#getDeviceParamsFromTest", () ->
  #   it "should scrape test parameters that have a placeholder in them", () ->
  #     results = blockSvc.getDeviceParamsFromTest testsForRev[0]
  #     expect(results[0]).toEqual {name: 'device_param1', value: '1PLACEHOLDER1', default: true}
  #     expect(results[1]).toEqual {name: 'device_param2', value: '2PLACEHOLDER2', default: true}
  #     expect(results[2]).toEqual {name: 'device_param2', value: '3PLACEHOLDER3', default: true}
  #     expect(results[3]).not.toBeDefined()

  describe "#getAllDefaultParameters", () ->
    it "should be defined", () ->
      #blockRevisions = [10,20]
      expect(blockSvc.getAllDefaultParameters).toBeDefined()


      it "should have my scope variable defined", () ->
        deferred = $q.defer()
        deferred.resolve testsForRev
        #spyOn(testSvc,'asyncTestsForRev').and.returnValue(deferred.promise)
        blockSvc.getAllDefaultParameters()
        #$scope.$apply()
        #expect(testSvc.asyncTestsForRev).toHaveBeenCalled()
#
#        $scope.block_revision_list = [10,20]
#        console.log 'foo'
#        blockSvc.getAllDefaultParameters($scope.block_revision_list)
#        $scope.$apply()

#
#  describe "#parseDeviceParams", () ->
#
#    it "should be defined", () ->
#      expect(blockSvc.parseDeviceParams).toBeDefined()
#
#    it "should correctly parse parameters with a placeholder and ignore others", () ->
#
#      #result = blockSvc.parseDeviceParams(testsForRev[0])
#      #console.log 'result',result
##      expect(result['1PLACEHOLDER1']).toEqual([{
##        name: 'device_param1',
##        usage: '1/#{1PLACEHOLDER1}'
##      }])
##      expect(result['2PLACEHOLDER2']).toEqual([{
##        name: 'device_param2',
##        usage: 'TEST/#{2PLACEHOLDER2}/#{3PLACEHOLDER3}'
##      }])
##      expect(result['4PLACEHOLDER4']).toEqual([{
##        name: 'device_param3',
##        usage: '1/#{4PLACEHOLDER4}'
##      },
##      {
##        name: 'device_param7',
##        usage: '5/#{4PLACEHOLDER4}'
##      }])
#
#  describe "#asyncDefaultParamsForBlockRevision", () ->
#    it "should be defined", () ->
#      expect(blockSvc.asyncDefaultParamsForBlockRevision).toBeDefined()
#    #it "should"