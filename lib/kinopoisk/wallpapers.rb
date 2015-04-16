module Kinopoisk
  class Wallpapers
    attr :id, :url

    def initialize(id)
      @id = id
      @url = "http://www.kinopoisk.ru/film/#{id}/stills/"
    end

    def thumbnail_urls
      doc.search('.fotos a[target="_blank"]')
    end

    def images
      thumbnail_urls.map do |url|
        url = image_url(url.attribute('href'))
        doc = get_content(url)
        sleep(5)
        doc.css('#image').attribute('src')
      end
    end

    private

    def get_content(url)
      Kinopoisk.parse url
    end

    def image_url(url)
      "http://www.kinopoisk.ru#{url}"
    end

    def doc
      @doc ||= Kinopoisk.parse url
    end
  end
end
