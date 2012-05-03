FactoryGirl.define do

  factory :page do |p|
    p.title "this is a title 123"
    p.permalink "this-is-a-title-123"
    p.published_at Time.now.utc
    p.published_by "ric"
  end

  factory :unpublished_page, :class => 'page' do |p|
    p.title "this is a title 123"
    p.permalink "this-is-a-title-123"
  end

  factory :page_with_unusual_chars, :class => 'page' do |p|
    p.title "this &*() is a title 456 &*()"
  end

  factory :permalink_less_page, :class => 'page' do |p|
    p.title "this is a title 123"
  end
end