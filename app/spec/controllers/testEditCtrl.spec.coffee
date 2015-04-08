describe "Unit: Testing Controllers", () ->
  beforeEach module('ngRoute')
  beforeEach module('vprAppControllers')

  $controller = undefined

  beforeEach inject (_$controller_) ->
    $controller = _$controller_


  describe 'TestEditCtrl', () ->
    it 'should not throw an error', () ->
      $scope = {}
      controller = $controller 'TestEditCtrl',{$scope: $scope}
      expect ($scope.foo).toEqual 'foo'