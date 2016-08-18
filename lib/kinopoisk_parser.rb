require 'nokogiri'
require 'httpclient'
require 'kinopoisk/movie'
require 'kinopoisk/search'
require 'kinopoisk/person'
require 'kinopoisk/trailer'
require 'kinopoisk/wallpapers'

module Kinopoisk
  SEARCH_URL = "https://www.kinopoisk.ru/index.php?kp_query="

  NotFound   = Class.new StandardError
  Empty      = Class.new StandardError

  # Headers are needed to mimic proper request so kinopoisk won't block it
  def self.fetch(url)
    HTTPClient.new.get url, nil, { follow_redirect: true,  'User-Agent'=>'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/601.7.7 (KHTML, like Gecko) Version/9.1.2 Safari/601.7.7 ', 'Accept-Encoding'=>'identity' }
    # HTTPClient.new.get url, nil, { follow_redirect: true, 'User-Agent'=>'a', 'Accept-Encoding'=>'a' }
  end

  # Returns a nokogiri document or an error if fetch response status is not 200
  def self.parse(url)
    page = fetch url
    if page.status == 200
      Nokogiri::HTML(page.body.encode('utf-8'))
    else
      raise NotFound, 'Page not found'
    end
  end
end
