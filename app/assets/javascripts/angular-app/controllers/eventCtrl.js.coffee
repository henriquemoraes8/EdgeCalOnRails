angular.module('app.calendarApp').controller("CalendarCtrl", [
  '$scope',
  ($scope)->
    console.log 'CalendarCtrl running'

    $scope.exampleValue = "Hello angular and EVERYBODY ELLLSE!!"
	$scope.title = "Penis"
	

])

#	$scope.my_events = [
#		{title: 'Event A', description: 'A Cool Event'},
#		{title: 'Event B', description: 'A Cooler Event'}
#	]