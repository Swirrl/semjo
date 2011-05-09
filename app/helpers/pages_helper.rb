module PagesHelper
  def full_article_url(page, protocol = "http")
    "#{protocol}://#{@blog.canonical_url}/pages/#{page.permalink}"
  end
end