vprAppServices.factory 'utilSvc', [ '$log', '$q', ($log, $q) ->

  class UtilSvc

    # Support Functions
    handleAsync: (promise) ->
      deferred = $q.defer()

      promise.then (response) ->
        deferred.resolve response
      , (error) ->
        console.log error?.msg
        deferred.reject error

      deferred.promise

    mergeDeviceParameters: (set) ->
      results = []
      for params in set
        for p in params 
          item = _.find results, (v) -> v.placeholder is p.placeholder
          if item? then item.references = item.references.concat p.references
          else results.push p 
      return results

    parseDeviceParams: (tests) ->
      results = []
      for test in tests        
        if test.is_current
          for param in test.test_params
            param.value.replace /#{(.*?)}/g, (str,match,start, usage) ->
              item = _.find results, (v) ->  v.placeholder is match
              if item?
                item.references.push {name: param.name, usage: usage}
              else
                item = {placeholder:match,value: '',default: true, references:[{name: param.name,usage:usage}]}
                results.push item    
      return results    

  new UtilSvc()

]