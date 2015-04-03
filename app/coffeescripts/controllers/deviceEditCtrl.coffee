vprAppControllers.controller 'DeviceEditCtrl', [ '$scope', '$routeParams', '$log', 'deviceSvc', ($scope, $routeParams, $log, deviceSvc) ->

  if $routeParams.deviceId == 'new'
    $scope.editDevice = {
      name: "",
      number: "",
      description: "",
      tags: []
    }
  else
    deviceSvc.asyncDevice $routeParams.deviceId
      .then (device) -> $scope.editDevice = device
      #, (err) -> $scope.error = err

  $scope.users = [ { username: "dnye", fullName: "Donovan Nye"}, { username: "tg", fullName: "That Guy"},{ username: "mrusso", fullName: "Michael Russo"} ]

  $scope.trySubmit = false
  $scope.validate = () ->
    $scope.trySubmit = true

  $scope.submitDevice = (editForm) ->
    deviceSvc.asyncSaveDevice angular.copy editForm
      .then () -> $scope.goto '/devices'


]

