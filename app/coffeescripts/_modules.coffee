# global app
vprApp = angular.module 'vprApp', [ 'ngRoute', 'vprAppControllers', 'vprAppServices' ]

# controllers
vprAppControllers = angular.module 'vprAppControllers', [ 'vprAppServices' ]

# services
vprAppServices = angular.module 'vprAppServices', []

# the sessionStorage is even simpler
vprAppServices.value 'storageSvc', sessionStorage

# the config value tells us where we get things
vprAppServices.value 'configSvc', {
  cbaseServer : "http://localhost:9000"
}

