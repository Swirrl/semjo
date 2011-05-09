require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < ActiveSupport::TestCase

  
  def test_creating_permalink
    a = @blog.articles.new(Factory.build(:permalink_less_article)).save
    assert_equal "this-is-a-title-123", a.permalink
    
    # check we have timestamps
    assert_not_nil a.updated_at
    assert_not_nil a.created_at
  end
  
  def test_creating_permalink_unusual_characters
    a = @blog.articles.new(Factory.build(:article_with_unusual_chars)).save    
    assert_equal "this-is-a-title-456", a.permalink
  end
  
  def test_duplicate_permalink
    a = @blog.articles.new(Factory.build(:permalink_less_article)).save               
    a2 = @blog.articles.new(Factory.build(:permalink_less_article)).save
    assert_equal "this-is-a-title-123-1", a2.permalink
  end
  
  def test_no_title
    a = @blog.articles.new(Factory.build(:permalink_less_article))
    a.title = nil       
    assert !a.save    
    assert_equal "can't be blank", a.errors[:title].first
  end
  
  def test_set_permalink
    a = @blog.articles.new(Factory.build(:permalink_less_article)).save 
    assert_equal "this-is-a-title-123", a.permalink 
    
    a.set_permalink("blah")
    assert a.save
    assert_equal "blah", a.permalink 
    
    a.set_permalink("blah&^%")
    assert a.save
    assert_equal "blah", a.permalink
  end
  
  def test_title_too_short
    a = @blog.articles.new
    a.title = "ab"     
    assert !a.save    
    assert_equal "is too short (minimum is 3 characters)", a.errors[:title].first
  end
     
  def test_publishing
    a = @blog.articles.new(Factory.build(:unpublished_article))
    a.set_published(true, "ric")
    
    # check that it worked.
    assert_equal "ric", a.published_by
    assert_not_nil a.published_at
  end
  
  def test_republishing
    a = @blog.articles.new(Factory.build(:article))
    a.set_published(true, "ric")
    published_time = a.published_at
    
    # check that it didn't change anything
    assert_equal "ric", a.published_by
    assert_equal published_time, a.published_at
  end
  
  
end
