require 'typhoeus'

module GoogleProfileHtmlDownloader
  extend self

  def download(url)
    scrape(url)
  end
  alias_method :call, :download

private

  def crawler
    Typhoeus
  end

  def scrape(url)
    html = crawler.get(url, followlocation: true).body
    return rescrape(url) if has_moved?(url)
    html
  end

  def rescrape(url)
    redirection_url = redirect_location(html)
    scrape(redirection_url)
  end

  def has_moved?(html)
    html =~ /<title>moved temporarily<\/title>/i
  end

  def url_matcher
    /The document has moved \<A HREF=\"(.*)\">here<\/A>/i
  end

  def redirect_location(html)
    html.scan(url_matcher).flatten[0]
  end

end
