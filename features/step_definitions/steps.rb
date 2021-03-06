Given(/^the Realm is$/) do |source|
  @realm ||= Qrb.parse_realm(source)
end

Given(/^I validate the following JSON data against (.*?)$/) do |type, json|
  type = @realm.fetch(type)
  json = ::MultiJson.load(json)
  @result = type.dress(json) rescue $!
end

Then(/^it should be a success$/) do
  @result.should_not be_a(Exception)
end

Then(/^the result should be a (.*?) native representation$/) do |type|
  type = @realm.fetch(type)
  case type
  when Qrb::TupleType
    @result.should be_a(Hash)
    @result.keys.all?{|k| k.should be_a(Symbol) }
  when Qrb::RelationType
    @result.should be_a(Set)
    @result.all?{|t| 
      t.should be_a(Hash)
      t.keys.all?{|k| k.should be_a(Symbol) }
    }
  else
    raise "Unexpected type `#{type}`"
  end
end

Then(/^it should be a TypeError as:$/) do |table|
  @result.should be_a(Qrb::TypeError)
  expected = table.hashes.first
  expected.each_pair do |k,v|
    @result.send(k.to_sym).should eq(v)
  end
end

Then(/^the result should be the null representation in the host language$/) do
  @result.should be_nil
end

Then(/^the result should equal (\d+)$/) do |expected|
  @result.should eq(Integer(expected))
end
