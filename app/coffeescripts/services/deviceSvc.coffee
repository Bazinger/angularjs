vprAppServices.factory 'deviceSvc', [ '$log', '$q', 'dataSvc', 'utilSvc',  ($log, $q, dataSvc, utilSvc) ->

  class DeviceSvc

    asyncDeviceRevisionWithParent: (revId) ->
      deferred = do $q.defer

      _this = this

      _this.asyncDeviceRevision revId
      .then (rev) ->
        _this.asyncDevice rev.device_id
        .then (device) ->
          deferred.resolve [device, rev]

      deferred.promise

    asyncDeviceCount: () ->
      deferred = do $q.defer

      @asyncDeviceList().then (arr) ->
        deferred.resolve(arr.length)
      , (error) ->
        $log.error("problem getting device list count #{error}")
        deferred.reject -1

      deferred.promise

    asyncDeviceList: () ->
      utilSvc.handleAsync dataSvc.asyncFind "devices", {}

    asyncDevice: (id) ->
      utilSvc.handleAsync dataSvc.asyncFindOne "devices", { id: id }

    asyncSaveDevice: (device) ->
      utilSvc.handleAsync dataSvc.asyncSave "devices", device

    asyncRmDevice: (id) ->
      deferred = $q.defer()
      @asyncRemoveRevisionsForDevice id
      .then () ->
        utilSvc.handleAsync dataSvc.asyncRemove "devices", id
        .then () ->
          deferred.resolve()

      deferred.promise

    asyncRevisionsForDevice: (device_id) ->
      utilSvc.handleAsync dataSvc.asyncFind "device_revisions", { device_id: device_id }

    asyncRemoveRevisionsForDevice: (device_id) ->
      deferred = $q.defer()
      that = this
      @asyncRevisionsForDevice device_id
      .then (revisions) ->
        if revisions.length
          promises = []
          for revision in revisions
            promises.push that.asyncRmDeviceRevision revision.id
          $q.all promises
          .then () ->
            console.log "finished removing all revisions"
            deferred.resolve()
        else
          deferred.resolve()

      deferred.promise

    asyncDeviceRevision: (id) ->
      utilSvc.handleAsync dataSvc.asyncFindOne "device_revisions", { id: id }

    asyncSaveDeviceRevision: (deviceRevision) ->
      utilSvc.handleAsync dataSvc.asyncSave "device_revisions", deviceRevision

    asyncSaveBlockRevisionForDeviceRevison: (deviceRevision, blockRevision) ->
      @asyncDeviceRevision deviceRevision
      .then (deviceRevision) ->
        if not deviceRevision.block_revisions
          deviceRevision.block_revisions = [blockRevision]
        else
          deviceRevision.block_revisions.push blockRevision
        @asyncSaveDeviceRevision deviceRevision

    asyncRmDeviceRevision: (deviceRevision) ->
      utilSvc.handleAsync dataSvc.asyncRemove "device_revisions", deviceRevision

  new DeviceSvc()
]