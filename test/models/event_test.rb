require 'test_helper'

class EventTest < ActiveSupport::TestCase

	test "should create event with title" do
		event  = Event.create( title: 'ECE 458 Lecture', description: 
			'A really stupid class full of boners')
		assert event.save, "saved event with a title and description"
	end

	test "should not create event without title" do
		event = Event.new
		assert_not event.save, "saved the event without a title"
	end
  # test "the truth" do
  #   assert true
  # end
end
