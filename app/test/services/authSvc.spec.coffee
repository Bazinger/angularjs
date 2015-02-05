describe 'when the authSvc is injected and called on', () ->

  authSvc = undefined
  mockStorage = undefined

  connects = osapiMock.osapi.jive.connects

  beforeEach module 'apAppServices', ($provide) ->
    $provide.value 'osw', osapiMock
    mockStorage = new MockStorage()
    $provide.value 'storageSvc', mockStorage
    null

  beforeEach () ->
    inject (_authSvc_) ->
      authSvc = _authSvc_

  describe 'to get a request key', () ->

    data = undefined

    mockResult = { content: {
      requestKey: 'abcd'
      serviceLocation: 'server'
    } }

    mockKeyReq = (params) -> { execute: (cb) -> cb mockResult }

    beforeEach (done) ->
      spyOn(connects, 'get').and.callFake mockKeyReq



      authSvc.getRequestKey (result) ->
        data = result
        do done

    it 'should pass the results to the callback function', () ->
        expect(data.requestKey).toBeDefined()
        expect(data.requestKey).toEqual 'abcd'
        expect(data.error).toBeUndefined()

    it 'should call jive connects', () ->
        expect(connects.get.calls.count()).toEqual 1
        expect(connects.get.calls.argsFor(0)[0])
          .toEqual jasmine.objectContaining({ href: '/requestKey' })


  describe 'to get an auth token', () ->

    data = undefined

    mockKeyResult = { content: {
      requestKey: 'abcd'
      serviceLocation: 'server'
    } }

    mockResult = { content: { token: 'xyz123', "user": {"userId":12345,"groups":[1,2,3],"isAdmin":true} } }



    mockKeyReq = (cb) -> cb(mockKeyResult)
    mockAuthReq = (params) -> { execute: (cb) -> cb mockResult }

    beforeEach (done) ->
      spyOn(authSvc, 'getRequestKey').and.callFake mockKeyReq
      spyOn(osapiMock.osapi.http, 'get').and.callFake mockAuthReq

      #mockStorage = new MockStorage()

      spyOn(mockStorage, 'setItem').and.callThrough()
      spyOn(mockStorage, 'getItem').and.callThrough()
      authSvc.getAuthToken (result) ->
        data = result
        do done

    it 'should pass the results to the callback funtion', () ->
      expect(data.token).toBeDefined()
      expect(data.user).toEqual({"userId":12345,"groups":[1,2,3],"isAdmin":true})

    it 'should cache the auth token for 4 minutes', () ->
      expect(mockStorage.setItem.calls.count()).toEqual(1)
      expect(mockStorage.setItem.calls.argsFor(0)[1]).toEqual(JSON.stringify({v: mockResult.content}))
