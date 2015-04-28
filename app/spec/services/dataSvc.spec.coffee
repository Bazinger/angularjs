describe "Unit: Testing DataSvc", () ->
  beforeEach module('vprAppServices')

  dataSvc = undefined
  $httpBackend = undefined

  beforeEach inject (_dataSvc_,_$httpBackend_) ->
    dataSvc = _dataSvc_
    $httpBackend = _$httpBackend_

  afterEach () ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  describe 'dataSvc', () ->
    it 'should be defined', () ->
      expect(dataSvc).toBeDefined()

  #describe '#_handlePost', () ->
#  it 'should return a response', () ->
#    returnData = {foo: true}
#    path = 'api/v1/foo'
#    $httpBackend.expectPost(path).respond(returnData)
#      returnedPromise = dataSvc.then (response) ->
#        result = response
#      httpBackend.flush()
#      expect(result).toEqual(returnData)
