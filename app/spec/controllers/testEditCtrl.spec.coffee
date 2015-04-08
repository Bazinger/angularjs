describe "Unit: Testing Controllers", () ->
  beforeEach module('ngRoute')
  beforeEach module('vprAppControllers')

  $controller = undefined
  $scope = undefined

  beforeEach inject (_$controller_,$rootScope) ->
    $controller = _$controller_
    $scope = $rootScope.$new()



  describe 'TestEditCtrl', () ->
    it 'should have scope defined', () ->
      expect($scope).toBeDefined

    it 'should not throw an error', () ->
      controller = $controller 'TestEditCtrl',{$scope: $scope}
      expect($scope.foo).toEqual 'foo'