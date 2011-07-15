Factory.define :place_note, do |n|
  n.association :user
  n.association :place
  n.content "This place is great"
end