
###
  Mock storage provider for injecting the storageSvc which
  is the only custom dep of the cacheSvc other then $timeout
  which should be replaced with jasmine's mock timer
###
class MockStorage
  constructor: () ->
    @db = []

  getItem: (key) ->
    @db[key]

  setItem: (key, data) ->
    @db[key] = do data.toString

  removeItem : (key) ->
    @db = @db.splice key, 1

  clear: () -> @db = []
