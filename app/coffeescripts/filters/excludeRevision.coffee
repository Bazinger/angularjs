#vprAppFilters.filter 'excludeRevision', () ->
#  (input = '', length = 24, countFromEnd = false) ->
#
#    if length < 4 then return '...'
#
#    if input.length <= (length) then input
#    else
#      if countFromEnd
#        '...' + input.substr -1 * (length - 3)
#      else input.substr(0, length - 3) + '...'
#
#
#
