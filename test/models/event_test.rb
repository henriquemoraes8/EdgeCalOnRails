require 'test_helper'

class EventTest < ActiveSupport::TestCase

	test "should create event with title" do
		event  = Event.create( title: 'ECE 458 Lecture', description: 
			'description text')
		assert event.save, "saved event with a title and description"
	end

	test "should not create event without title" do
		event = Event.new
		assert_not event.save, "saved the event without a title"
	end

	test "should not create event without creator" do
		event  = Event.create( title: 'ECE 458 Lecture', description: 
			'description text')
		assert_not event.save, "saved the event without a creator"
	end

end
