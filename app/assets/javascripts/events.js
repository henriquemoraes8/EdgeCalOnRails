$(document).on("ready page:load", function(){
  $('#calendar').fullCalendar({
	  
	editable: true,
	header: {
      left: 'prev today next',
      center: 'title',
      right: 'month,agendaWeek,agendaDay'
	},
	height: 500,
	defaultView: 'month',
	buttonIcons: {
		prev: 'left-single-arrow',
     	next: 'right-single-arrow'
	},
	  
	eventSources: [
		{events: [
		    {
		        title  : 'event1',
		        start  : '2015-02-20'
		    },
		    {
		        title  : 'event2',
		        start  : '2015-02-05',
		        end    : '2015-02-07'
		    },
		    {
		        title  : 'event3',
		        start  : '2015-02-09T12:30:00',
		        allDay : false // will make the time show
		    }
		]},
		
		{
			url: '/events',
			color: 'red'
		},
		
	],
	
  })
}).call(this)