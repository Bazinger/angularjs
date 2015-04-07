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
      utilSvc.handleAsync dataSvc.asyncRemove "devices", id

    asyncRevisionsForDevice: (device_id) ->
      utilSvc.handleAsync dataSvc.asyncFind "device_revisions", { device_id: device_id }

    asyncBlocksForDeviceRevision: (device_revision_id) ->
      utilSvc.handleAsync dataSvc.asyncFind "blocks", { device_revision_id: device_revision_id }

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