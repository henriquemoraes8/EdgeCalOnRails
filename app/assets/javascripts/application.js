// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require turbolinks
//= require fullcalendar
//= require jquery-ui/datepicker
//= require jquery.datetimepicker
//= require jquery.datetimepicker/init
//= require jquery.timepicker.js
//= require_tree .

$(function(){ $(document).foundation(); });

$(function() {
	$(".datetimepicker").datetimepicker();
});

$(function() {
	$(".timepicker").timepicker({ 'step': 15 });
});

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
}).call(this);