xdescribe 'The account list controller', () ->


  $scope = undefined
  apSvc = undefined
  accountListCtrl = undefined
  mockStorage = undefined

  beforeEach module 'apAppControllers', ($provide) ->
    $provide.value 'osw', osapiMock
    spyOn(osapiMock.osapi.http, 'get')
    mockStorage = new MockStorage()
    $provide.value('storageSvc', mockStorage)

    osapiMock.osapi.http.get.and.callFake (params) -> { execute: (cb) -> cb({ content : { quote : 'Ready for the game?' } })  }
    null



  beforeEach () ->
    inject ($rootScope, $controller, _apSvc_) ->
      $scope = do $rootScope.$new
      apSvc = _apSvc_
      accountListCtrl = $controller 'AccountListCtrl', {
        $scope : $scope
      }

  it 'should get its dependencies injected and set up a fortune', () ->
    expect(osapiMock.osapi.http.get).toHaveBeenCalled()
    expect($scope.apSvc).toBeDefined()
