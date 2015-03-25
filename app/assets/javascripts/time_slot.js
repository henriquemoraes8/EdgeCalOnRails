// Place all the behaviors and hooks related to the matching controller here.All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready(function(){
    alert("hi");
    $('#add_button').click(function () {
        alert("button clicked");
        $("#time_slot_events").append("<div class='partial'>
        <%= escape_javascript(render :partial => 'form_event', :locals => {:f => f, :event => e}) %>
        </div>");
        location.reload();
    });
});