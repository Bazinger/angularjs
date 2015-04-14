vprAppServices.factory 'blockSvc', [ '$log', '$q', 'dataSvc', 'utilSvc',  ($log, $q, dataSvc, utilSvc) ->

  class BlockSvc

    asyncBlockRevisionWithParent: (revId) ->

      deferred = do $q.defer

      _this = this

      @asyncBlockRevision revId
      .then (rev) ->
        _this.asyncBlock rev.block_id
        .then (block) ->
          deferred.resolve [block, rev]

      deferred.promise

    asyncBlockCount: () ->
      deferred = do $q.defer

      @asyncBlockList().then (arr) ->
        deferred.resolve(arr.length)
      , (error) ->
        $log.error("problem getting block list count #{error}")
        deferred.reject -1

      deferred.promise

    asyncBlockList: () ->
      utilSvc.handleAsync dataSvc.asyncFind "blocks", {}

    asyncBlock: (id) ->
      utilSvc.handleAsync dataSvc.asyncFindOne "blocks", { id: id }

    asyncSaveBlock: (block) ->
      utilSvc.handleAsync dataSvc.asyncSave "blocks", block

    asyncRmBlock: (id) ->
      utilSvc.handleAsync dataSvc.asyncRemove "blocks", id

    asyncRevisionsForBlock: (block_id) ->
      utilSvc.handleAsync dataSvc.asyncFind "block_revisions", { block_id: block_id }

    asyncBlockRevision: (id) ->
      utilSvc.handleAsync dataSvc.asyncFindOne "block_revisions", { id: id }

    asyncSaveBlockRevision: (blockRevision) ->
      utilSvc.handleAsync dataSvc.asyncSave "block_revisions", blockRevision

    asyncRmBlockRevision: (blockRevision) ->
      utilSvc.handleAsync dataSvc.asyncRemove "block_revisions", blockRevision

#    asyncBlockRevisionsForDeviceRevision: (revision)
#    asyncBlockRevisionNames: () ->
#      #console.log 'asyncBlockRevisionNames'
#      deferred = do $q.defer
#      _that = this
#      @asyncBlockList()
#      .then (blocks) ->
#        console.log 'blocks',blocks
#        names = []
#        for block in blocks
#          deferred = do $q.defer
#          _that.asyncRevisionsForBlock(block.id)
#          .then (revisions) ->
#            for r in revisions
#              name = {id: r.id,name: block.name + ' ' + r.major_revision + '.' + r.minor_revision}
#              console.log 'name',name
#              names.push name
#            deferred.resolve names
#          deferred.promise
#          .then (results) ->
#            console.log 'results',results
#            names = names.concat n
#            console.log names
#            deferred.resolve names
#      deferred.promise
#      .then () ->
#        console.log 'names',names

  new BlockSvc()
]