require 'nokogiri'
require 'httpclient'
require 'kinopoisk/movie'
require 'kinopoisk/search'
require 'kinopoisk/person'
require 'kinopoisk/trailer'
require 'kinopoisk/wallpapers'

module Kinopoisk
  SEARCH_URL = "http://www.kinopoisk.ru/index.php?kp_query="
  NotFound   = Class.new StandardError
  Empty      = Class.new StandardError

  # Headers are needed to mimic proper request so kinopoisk won't block it
  def self.fetch(url)
    HTTPClient.new.get url, nil, { 'User-Agent'=>'a', 'Accept-Encoding'=>'a' }
  end

  # Returns a nokogiri document or an error if fetch response status is not 200
  def self.parse(url)
    p = fetch url
    raise(Empty) if p.http_body.content.size.zero?
    p.status==200 ? Nokogiri::HTML(p.body.encode('utf-8')) : raise(NotFound)
  end
end
