require 'nokogiri'
require 'google_matchers'

module GoogleFollowingCountMatcher
  extend self
  extend GoogleMatchers

private

  def match_followings(html)
    doc = Nokogiri::HTML(html)
    doc.css('.bkb').children.first.children.first.text.gsub(/\D/,'').to_i
  end
end
