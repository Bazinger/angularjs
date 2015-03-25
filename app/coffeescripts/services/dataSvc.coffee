vprAppServices.factory 'dataSvc', [ '$log', '$q', '$http', 'configSvc', ($log, $q, $http, configSvc) ->

  class DataSvc

    asyncFindOne: (collection, query) ->  # return {}

      deferred = do $q.defer

      success = (arr) ->
        deferred.resolve arr[0]

      error = (msg) ->
        deferred.reject msg

      @asyncFind(collection, query).then success, error

      deferred.promise

    asyncFind: (collection, query) -> # return [ {}, {}, ... ]

      deferred = do $q.defer

      @_handlePost "/api/v1/findJson/#{collection}", query, deferred

      deferred.promise

    asyncSave: (collection, data) ->

      deferred = do $q.defer

      theRealPost = @_handlePost

      save = (_data, id) ->
        theRealPost "/api/v1/saveJson/#{collection}/#{id}", _data, deferred, true # do return passed in data

      if ! data.id?
        @asyncNewId().then (id) ->
          data.id = id
          save data, id
      else
        save data, data.id

      deferred.promise

    asyncComplexSave: (collection, names, values, types, data) ->

      deferred = do $q.defer

      names_s      = names.join "::"
      values_s    = values.join "::"
      types_s     = types.join "::"

      unless (names.length == values.length == types.length)
        deferred.reject( { msg: "names (#{names.length}), values (#{values.length}) and type (#{types.length}) arrays must all be the same length" })
      else
        @_handlePost "/api/v1/saveJsonComplexId/#{collection}/#{names_s}/#{values_s}/#{types_s}", data, deferred

      deferred.promise

    asyncUpdate: (collection, query, update) ->

      deferred = do $q.defer

      @_handlePost "/api/v1/updateJson/#{collection}", { query: query, update: update }, deferred

      deferred.promise

    asyncRemove: (collection, id) ->

      deferred = do $q.defer

      @_handleGet "/api/v1/rmJson/#{collection}/#{id}", deferred

      deferred.promise

    asyncNewId: () ->

      deferred = do $q.defer

      @_handleGet "/api/v1/newid", deferred

      deferred.promise

    _handlePost: (path, data, deferred, resolveToPassedData = false) ->

      $http.post "#{configSvc.cbaseServer}#{path}", data
      .success (result, status, headers, config) ->
        if resolveToPassedData then deferred.resolve data
        else deferred.resolve result
      .error (result, status, headers, config) ->
        deferred.reject result

    _handleGet: (path, deferred) ->

      $http.get "#{configSvc.cbaseServer}#{path}"
      .success (result, status, headers, config) ->
        deferred.resolve result
      .error (result, status, headers, config) ->
        deferred.reject result


  new DataSvc()
]