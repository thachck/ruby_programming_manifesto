require 'nokogiri'
require 'google_matchers'

module GoogleFollowerCountMatcher
  extend self
  extend GoogleMatchers

private

  def match_followers(html)
    doc = Nokogiri::HTML(html)
    doc.css(".vkb").children.first.text.gsub(/\D/,'').to_i
  rescue NoMethodError
  end
end
