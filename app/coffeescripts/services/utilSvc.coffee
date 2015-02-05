vprAppServices.factory 'utilSvc', [ '$log', '$q', ($log, $q) ->

  class UtilSvc

    #cbase: "http://localhost:9000"

    # Support Functions
    handleAsync: (promise) ->

      deferred = do $q.defer

      promise.then (response) ->
        deferred.resolve response
      , (error) ->
        deferred.reject error

      deferred.promise

  new UtilSvc()

]