describe "Unit: Testing UtilSvc", () ->
  utilSvc = undefined
  http = undefined
  deferred = undefined

  beforeEach ->
    module 'vprAppServices'
    inject (_utilSvc_,_$q_) ->
      utilSvc = _utilSvc_
      $q = _$q_
      deferred = $q.defer()


  it 'should be defined', () ->
    expect(utilSvc).toBeDefined

  it 'should be defined', () ->
    expect(angular.isFunction(utilSvc.handleAsync)).toBe(true)

  describe 'handleAsync', () ->
    it 'should return a promise', () ->
      expect(utilSvc.handleAsync(deferred.promise).then).toBeDefined

