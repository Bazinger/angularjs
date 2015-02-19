vprAppDirectives.directive 'tags', () ->
  {
    require: 'ngModel',
    link: (scope, element, attrs, ngModelController) ->
      ngModelController.$parsers.push (data) -> # space separated list: convert to array
        if data? then data.split ' '
        else []

      ngModelController.$formatters.push (data) -> # array: convert to space separated list
        if data? then data.join ' '
        else ''
  }