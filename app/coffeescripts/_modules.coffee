# global app
vprApp = angular.module 'vprApp', [ 'ngRoute', 'ui.bootstrap', 'vprAppControllers', 'vprAppServices', 'vprAppFilters', 'vprAppDirectives' ]

# controllers
vprAppControllers = angular.module 'vprAppControllers', [ 'vprAppServices' ]

# services
vprAppServices = angular.module 'vprAppServices', []

#filters
vprAppFilters = angular.module 'vprAppFilters', []

#directives
vprAppDirectives = angular.module 'vprAppDirectives', []

# the sessionStorage is even simpler
vprAppServices.value 'storageSvc', sessionStorage

# the config value tells us where we get things
vprAppServices.value 'configSvc', {
  cbaseServer : "http://beta.web.cirrus.com:9002"
}

