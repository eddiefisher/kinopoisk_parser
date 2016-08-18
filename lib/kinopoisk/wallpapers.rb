module Kinopoisk
  class Wallpapers
    attr :id, :url

    def initialize(id)
      @id = id
      @url = "https://www.kinopoisk.ru/film/#{id}/stills/"
    end

    def thumbnail_urls
      doc.search('.fotos a[target="_blank"]')
    end

    def images
      thumbnail_urls.map do |url|
        url = image_url(url.attribute('href'))
        doc = get_content(url)
        doc.css('#image').attribute('src').value
      end
    end

    private

    def get_content(url)
      Kinopoisk.parse url
    end

    def image_url(url)
      "https://www.kinopoisk.ru#{url}"
    end

    def doc
      @doc ||= Kinopoisk.parse url
    end
  end
end
