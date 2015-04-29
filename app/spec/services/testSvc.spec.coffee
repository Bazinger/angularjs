describe "Unit: Testing TestSvc", () ->
  beforeEach module('vprAppServices')

  testSvc = undefined
  $httpBackend = undefined
  $q = undefined
  $scope = undefined
  beforeEach inject (_testSvc_,_$httpBackend_,_$q_,$rootScope) ->
    testSvc = _testSvc_
    $httpBackend = _$httpBackend_
    $q = _$q_
    $scope = $rootScope.$new()

  afterEach () ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  describe 'testSvc', () ->
    mockTests = undefined
    revId = undefined
    testsForRev = undefined

    beforeEach () ->
      mockTests = [{
        id: "1"
        test_params: [
          {name: "foo",value:"bar"},
          {name: "baz",value:"boo"}
        ]
      },{
        id: "3"
        test_params: [
          {name: "foo",value:"bar"},
          {name: "baz",value:'foo/#{boo}'},
          {name: "blee",value:'foo/#{blark}/#{blizz}/baz'}
        ]
      }]

      revId = "cc45fa0f-8f82-4a15-9f44-060981247d60"

      testsForRev = [{
        id: "1"
        rev_id: revId
        branch: "default"
      }, {
        id: "2"
        rev_id: revId
        branch: "default"
        test_params: [
          {name: "foo",value:"bar"},
          {name: "baz",value:"boo"}
        ]
      }, {
        id: "3"
        rev_id: revId
        branch: "branch1"
        is_current: true
        test_params: [
          {name: "foo",value:"bar"},
          {name: "baz",value:'foo/#{boo}'},
          {name: "blee",value:'foo/#{blark}/#{blizz}/baz'}
        ]
      }]

    it 'should be defined', () ->
      expect(testSvc).toBeDefined()

#    describe "getDeviceParamsForTest", () ->
#
#      it "should return a list of device parameters", () ->
#
#        expect(testSvc.getDeviceParamsForTest(mockTests[0])).toBeNull()
#        result = testSvc.getDeviceParamsForTest(mockTests[1])
#        expect(result.length).toBe 2
#        expect(result[0].name).toBe "baz"
#        expect(result[0].params.length).toBe 1
#        expect(result[0].params).toContain "boo"
#        expect(result[1].name).toBe "blee"
#        expect(result[1].params.length).toBe 2
#        expect(result[1].params).toContain "blark"
#        expect(result[1].params).toContain "blizz"
#
#    describe 'asyncDeviceParamsForRev', () ->
#      result = undefined
#      beforeEach () ->
#        d1=$q.defer()
#        d1.resolve testsForRev
#        spyOn(testSvc,'asyncTestsForRev').and.returnValue d1.promise
#        #spyOn(testSvc,'getDeviceParamsForTest').and.callThrough()
#        $scope.$digest()
#
#      it "should call 'asyncTestsForRev' ", () ->
#        result = testSvc.asyncDeviceParamsForRev(revId)
#        expect(testSvc.asyncTestsForRev).toHaveBeenCalled()
#        console.log result
