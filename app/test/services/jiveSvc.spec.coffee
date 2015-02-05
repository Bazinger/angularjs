
describe 'An abstraction over the jive javascript api to convert to $q', () ->

  $q = undefined
  $rootScope = undefined
  jiveSvc = undefined

  goodCoreV3fn = (params) -> {
    execute: (cb) -> cb {
      id : 0
      params : params
    }
  }

  badCoreV3fn = (params) -> {
    execute: (cb) -> cb {
      error : {
        code : 400,
        message : "Invalid request"
      }
    }
  }

  beforeEach module 'apAppServices', ($provide) ->
    $provide.value 'osw', osapiMock
    null

  beforeEach () ->
    inject (_$q_, _$rootScope_, _jiveSvc_) ->
      $q = _$q_
      $rootScope = _$rootScope_
      jiveSvc = _jiveSvc_

  describe 'when asked to make asyncExecs', () ->

    beforeEach () ->

    it 'should resolve a good request with the response provided by the api', (done) ->

      promise = jiveSvc.asyncExec goodCoreV3fn, { name : "donovan" }

      complete = () ->
        expect(do errF.calls.count).toEqual(0)
        do done

      goodF = (data) ->
        expect(data).toEqual(jasmine.objectContaining({ params : { name : "donovan" }, id : 0 }))
        do complete

      errF = jasmine.createSpy().and.callFake complete

      promise.then goodF, errF

      do $rootScope.$apply

    it 'should reject a bad request with the response provided by the api', (done) ->

      promise = jiveSvc.asyncExec badCoreV3fn, { name : "donovan" }

      complete = () ->
        expect(do goodF.calls.count).toEqual(0)
        do done

      errF = (data) ->
        expect(data).toEqual { error : { code : 400, message : 'Invalid request' } }
        do complete

      goodF = jasmine.createSpy().and.callFake complete

      promise.then goodF, errF

      do $rootScope.$apply

  describe 'when asked to make asyncBatches', () ->

    beforeEach () ->

    xit 'should take a data object and a mapping function and translate that into a batch request', (done) ->

      class MockBatch
        constructor: () ->
          @res = []
        add: (idx, req) -> @res[idx] = { content: req }
        execute: (cb) -> cb(@res)

      mockBatch = new MockBatch()

      spyOn(osapiMock.osapi, "newBatch").and.callFake () -> mockBatch

      data = [
        { id: "0", name: 'zero' },
        { id: "1", name: 'one'},
        { id: "2", name: 'two' }
      ]

      mappingFn = (elem) -> elem.name

      indexBy = "id"

      promise = jiveSvc.asyncBatch(data, mappingFn, indexBy)

      complete = () ->
        expect(errF.calls.count).toEqual(0)
        do done

      goodF = (metaResponse) ->
        expect(metaResponse.length).toEqual(3)
        expect(metaResponse["0"]).toEqual({ content: 'zero'})
        do complete

      errF = jasmine.createSpy().and.callFake complete

      promise.then goodF, errF

      do $rootScope.$apply
