
describe 'The cache service, used to cache data for clients', () ->

  cacheSvc = undefined
  mockStorage = new MockStorage()
  $timeout  = undefined

  beforeEach module ('apAppServices'), ($provide) ->
    $provide.value('storageSvc', mockStorage)

    spyOn(mockStorage, 'setItem').and.callThrough()
    spyOn(mockStorage, 'getItem').and.callThrough()

    null

  beforeEach () ->
    inject (_cacheSvc_, _$timeout_) ->
      cacheSvc = _cacheSvc_
      $timeout = _$timeout_

  beforeEach () ->
    do mockStorage.clear

  it 'should save to the sessionStorage', () ->
    cacheSvc.set "a", "b"
    expect(mockStorage.db["a"]).toEqual(JSON.stringify({ v:"b"}))

    expect(do mockStorage.setItem.calls.count).toEqual(1)

  it 'should serialize an object a string', () ->
    testObj = { key: "value" }
    cacheSvc.set "a", testObj

    expect(mockStorage.db["a"]).toEqual(JSON.stringify({v:testObj}))


  it 'should retrieve something by key', () ->
    mockStorage.db["c"] = JSON.stringify({ v:"d" })
    expect(cacheSvc.get("c")).toEqual("d")

  describe 'working with timeouts', () ->

    beforeEach () ->

      spyOn(mockStorage, 'removeItem').and.callThrough()

    afterEach () ->

    it 'should set a value with a timeout', () ->
      cacheSvc.set "a", "b", 30

      expect(mockStorage.db["a"]).toEqual(JSON.stringify({v:"b"}))

      $timeout.flush()

      expect(mockStorage.removeItem.calls.count()).toEqual(1)
      expect(mockStorage.db["a"]).toBeUndefined()



