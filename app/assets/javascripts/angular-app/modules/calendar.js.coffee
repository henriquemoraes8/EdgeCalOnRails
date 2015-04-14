@calendarApp = angular
  .module('app.calendarApp', [
    # additional dependencies here
  ])
  .run(->
    console.log 'calendarApp running'
  )