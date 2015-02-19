vprAppDirectives.directive 'tags', () ->
  {
    require: 'ngModel',
    link: (scope, element, attrs, ngModelController) ->
      ngModelController.$parsers.push (data) -> # space separated list: convert to array
        data.split ' '

      ngModelController.$formatters.push (data) -> # array: convert to space separated list
        data.join ' '
  }