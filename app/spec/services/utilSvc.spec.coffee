describe "Unit: Testing UtilSvc", () ->
  beforeEach module "vprAppServices"

  utilSvc = undefined
  http = undefined
  deferred = undefined
  params1 = undefined
  params2 = undefined

  beforeEach inject (_utilSvc_,$q) ->
    utilSvc = _utilSvc_
    deferred = $q.defer()
    params1 = [{placeholder: 'FOO', references: [{name: 'param1',usage:'T/${FOO}'}]}]
    params2 = [{placeholder: 'FOO', references: [{name: 'param2',usage:'X/${FOO}'}]}]
  it 'should be defined', () ->
    expect(utilSvc).toBeDefined()

  it 'should be defined', () ->
    expect(angular.isFunction(utilSvc.handleAsync)).toBe(true)

  describe 'handleAsync', () ->
    it 'should return a promise', () ->
      expect(utilSvc.handleAsync(deferred.promise).then).toBeDefined()


  describe '#mergeDeviceParameters', () ->
    it "should be defined", () ->
      expect(angular.isFunction(utilSvc.mergeDeviceParameters)).toBe true
    it "should merge N sets of device parameters into one set", () ->
      set = []
      params1 = [
        {placeholder: "FOO",references: [{name: "param1",usage: "usage"}]}
        {placeholder: "BAR",references: [{name: "param2",usage: "usage"}]}
      ]    
      params2 = [
        {placeholder: "FOO",references: [{name: "param10",usage: "usage"}]}
        {placeholder: "XYZ",references: [{name: "param20",usage: "usage"}]}
      ]    
      params3 = [
        {placeholder: "XXY",references: [{name: "param100",usage: "usage"}]}
        {placeholder: "BAR",references: [{name: "param200",usage: "usage"}]}
        {placeholder: "XXX",references: [{name: "param300",usage: "usage"}]}
      ]
      outcome = [
        {placeholder: "FOO",references: [{name: "param1",usage: "usage"},{name: "param10",usage: "usage"}]}
        {placeholder: "BAR",references: [{name: "param2",usage: "usage"},{name: "param200",usage: "usage"}]}
        {placeholder: "XYZ",references: [{name: "param20",usage: "usage"}]}
        {placeholder: "XXY",references: [{name: "param100",usage: "usage"}]}
        {placeholder: "XXX",references: [{name: "param300",usage: "usage"}]}
      ]    
      set.push params1, params2, params3
      result = utilSvc.mergeDeviceParameters set 
      expect(result).toEqual outcome 


    
