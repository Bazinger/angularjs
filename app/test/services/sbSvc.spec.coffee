
describe 'when the sbSvc is injected and called on', () ->

  sbSvc = undefined
  $q = undefined
  $rootScope = undefined


  mockAuthSvc = {
    invalidateToken: () ->
    getRequestKey: () ->
    getAuthToken: () ->
  }

  beforeEach module 'apAppServices', ($provide) ->
    $provide.value('authSvc', mockAuthSvc)
    $provide.value('osw', osapiMock)

    spyOn(mockAuthSvc, 'invalidateToken')
    spyOn(mockAuthSvc, 'getAuthToken').and.callFake (cb) -> cb({ token: 'abc'})

    null

  beforeEach () ->
    inject (_$q_, _$rootScope_, _sbSvc_) ->
      sbSvc = _sbSvc_
      $q = _$q_
      $rootScope = _$rootScope_

  it 'should be injected', () ->
    expect( sbSvc ).toBeDefined()

  describe 'and errors happen', () ->

    authError = { error: { code: 401 } }
    authErrorResponse = { execute: (cb) -> cb(authError) }
    authErrorRequest = () -> authErrorResponse
    reqError = { error: { code: 400 } }
    reqErrorResponse = { execute: (cb) -> cb(reqError) }
    reqErrorRequest = () -> reqErrorResponse

    deferred = undefined

    beforeEach () ->


      spyOn(sbSvc, '_secureRequest').and.callThrough()
      spyOn(sbSvc, '_handleResponse').and.callThrough()

      deferred = do $q.defer

    it 'should retry on getting a pre authorization error 1 time', () ->
      mockAuthSvc.getAuthToken.and.callFake (cb) -> cb(authError)
      sbSvc._secureRequest deferred, () ->

      expect(sbSvc._secureRequest.calls.count()).toEqual(2)

    it 'should retry on getting a response authorization error 1 time', () ->
      sbSvc._secureRequest deferred, authErrorRequest

      expect(sbSvc._secureRequest.calls.count()).toEqual(2)

    it 'should not retry on a non authorization error', () ->
      sbSvc._secureRequest deferred, reqErrorRequest

      expect(sbSvc._secureRequest.calls.count()).toEqual(1)

    it 'should reject the promise on an unresolvable authorization error', (done) ->
      sbSvc._secureRequest deferred, reqErrorRequest
      promise = deferred.promise

      complete = () ->
        expect(errorF.calls.count()).toEqual(1)
        do done

      anonF = () -> complete
      errorF = jasmine.createSpy().and.callFake complete

      promise.then anonF, errorF, anonF

      do $rootScope.$apply

  describe 'and should handle its scope well', () ->

    it 'should pass the baseRequestData from the class', () ->

      deferred = do $q.defer

      cb = (data) ->
        expect(data).toEqual(jasmine.objectContaining({ alias: 'sbusplus'}))
        { execute: (cb) -> cb({ content: 'ok' })}

      sbSvc._secureRequest deferred, cb


  describe 'and successful requests ensue', () ->

    goodResult = { content: { good: 'stuff' } }
    goodResponse = { execute: (cb) -> cb(goodResult) }
    goodRequest = () -> goodResponse

    deferred = undefined

    beforeEach () ->
      deferred = do $q.defer

    describe 'request results', () ->
      promise = undefined

      beforeEach () ->
        sbSvc._secureRequest deferred, goodRequest
        promise = deferred.promise

      it 'should resolve the promise on a good request', (done) ->
        complete = () ->
          expect(goodF.calls.count()).toEqual(1)
          do done

        anonF = () -> complete
        goodF = jasmine.createSpy().and.callFake complete

        promise.then goodF, anonF, anonF

        do $rootScope.$apply

      it 'should resolve the promise with a content from the result', (done) ->
        complete = (content) ->
          expect(content).toBeDefined()
          expect(content).toEqual({ good: 'stuff'})
          do done

        anonF = () -> complete
        goodF = jasmine.createSpy().and.callFake complete

        promise.then goodF, anonF, anonF

        do $rootScope.$apply

    describe 'the request object', () ->
      container = { cb: goodRequest }
      requestObject = undefined

      beforeEach () ->

        spyOn(container, 'cb').and.callThrough()
        sbSvc._secureRequest deferred, container.cb
        requestObject = container.cb.calls.argsFor(0)[0]

      it 'should contain a X-SB-AUTHKEY header', () ->
        expect(requestObject.headers).toEqual(
          jasmine.objectContaining({'X-SB-AUTHKEY': [ 'abc' ]})
        )
      it 'should contain an alias property', () ->
        expect(requestObject).toEqual(
          jasmine.objectContaining({ 'alias': sbSvc.alias })
        )

    describe 'top level calls', () ->

      promise = undefined
      connects = osapiMock.osapi.jive.connects
      requestObject = undefined

      beforeEach () ->
        deferred = do $q.defer

      describe 'asyncGet', () ->
        beforeEach () ->
          spyOn(connects, 'get').and.callFake goodRequest

          promise = sbSvc.asyncGet '/peace'
          requestObject = connects.get.calls.argsFor(0)[0]

        it 'should call connects.get with a href property equal to the path', () ->
          expect(requestObject).toEqual(
            jasmine.objectContaining { 'href': '/peace'}
          )

        it 'should resolve the promise with content', (done) ->
          complete = (content) ->
            expect(content).toBeDefined()
            expect(content).toEqual({ good: 'stuff'})
            do done

          anonF = () -> complete
          goodF = jasmine.createSpy().and.callFake complete

          promise.then goodF, anonF, anonF

          do $rootScope.$apply

      describe 'asyncPost', () ->
        beforeEach () ->
          spyOn(connects, 'post').and.callFake goodRequest

          promise = sbSvc.asyncPost '/peace', { reason: 'testing' }
          requestObject = connects.post.calls.argsFor(0)[0]

        it 'should call connects.post with a href and data header', () ->
          expect(requestObject).toEqual(
            jasmine.objectContaining { href: '/peace', body: { reason: 'testing'}}
          )


        it 'should resolve the promise with content', (done) ->
          complete = (content) ->
            expect(content).toBeDefined()
            expect(content).toEqual({ good: 'stuff'})
            do done

          anonF = () -> complete
          goodF = jasmine.createSpy().and.callFake complete

          promise.then goodF, anonF, anonF

          do $rootScope.$apply

