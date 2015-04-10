describe "Unit: Testing DataSvc", () ->
  beforeEach module('vprAppServices')

  dataSvc = undefined
  httpBackend = undefined

  beforeEach inject (_dataSvc_,_$httpBackend_) ->
    dataSvc = _dataSvc_
    httpBackend = _$httpBackend_

  afterEach () ->
    httpBackend.verifyNoOutstandingExpectation()
    httpBackend.verifyNoOutstandingRequest()

  describe 'dataSvc', () ->
    it 'should be defined', () ->
      expect(dataSvc).toBeDefined

  describe '#_handlePost', () ->
    path = 'foo/bar'
    it 'should append path to URL', () ->
      #dataSvc._handlePost(path,)