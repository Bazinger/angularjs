
describe 'when the apSvc is created and inject', () ->
  apSvc = undefined
  $q = undefined
  $rootScope = undefined
  mockStorage = undefined


  mockSbSvc = {
    asyncGet: () ->
    asyncPost: () ->
  }

  beforeEach module 'apAppServices', ($provide) ->
    $provide.value('sbSvc', mockSbSvc)
    $provide.value('osw', osapiMock)
    mockStorage = new MockStorage()
    $provide.value('storageSvc', mockStorage)

    spyOn(mockSbSvc, 'asyncGet')
    spyOn(mockSbSvc, 'asyncPost')

    null

  beforeEach () ->
    inject (_$q_, _$rootScope_, _apSvc_) ->
      apSvc = _apSvc_
      $q = _$q_
      $rootScope = _$rootScope_

  describe 'asyncListAccounts', () ->

    beforeEach () ->
      mockSbSvc.asyncGet.and.callFake (path) -> { }

      do apSvc.asyncListAccounts

    xit 'should call asyncGet with a path of /accountPlan/list', () ->
      expect(mockSbSvc.asyncGet.calls.argsFor(0)[0]).toEqual('/accountPlan')

