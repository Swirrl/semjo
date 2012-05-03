FactoryGirl.define do

  factory :article do |a|
    a.title "this is a title 123"
    a.permalink "this-is-a-title-123"
    a.published_at Time.now.utc
    a.published_by "ric"
  end

  factory :unpublished_article, :class => 'article' do |a|
    a.title "this is a title 123"
    a.permalink "this-is-a-title-123"
  end

  factory :article_with_unusual_chars, :class => 'article' do |a|
    a.title "this &*() is a title 456 &*()"
  end

  factory :permalink_less_article, :class => 'article' do |a|
    a.title "this is a title 123"
  end

end