json.array!(@events) do |event|
  json.title 'Busy'
  json.start event.start_time
  json.end event.end_time
  json.url events_url + '/~' + event.id.to_s
end
