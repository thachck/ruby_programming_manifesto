require 'google_following_count_matcher'
require 'google_follower_count_matcher'
require 'google_profile_html_downloader'

module GoogleStatsRetriever
  extend self

  def retrieve(uid)
    google_url = url(uid)
    {
      follower_count:  follower_count(google_url),
      following_count: following_count(google_url),
    }
  end
  alias_method :call, :retrieve

private

  def follower_count(url)
    html = download_profile_html(url)
    match_follower_count(html)
  end

  def following_count(url)
    html = download_profile_html(url)
    match_following_count(html)
  end

  def url(uid)
    "https://plus.google.com/u/0/#{uid}/posts"
  end

  def download_profile_html(url)
    @html ||= GoogleProfileHtmlDownloader.(url)
  end

  def match_following_count(html)
    GoogleFollowingCountMatcher.(html)
  end

  def match_follower_count(html)
    GoogleFollowerCountMatcher.(html)
  end

end
