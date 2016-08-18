module Kinopoisk
  class Trailer
    attr_accessor :id, :movie_id, :url, :title

    # New instance can be initialized with id(integer) or title(string). Second
    # argument may also receive a string title to make it easier to
    # differentiate Kinopoisk::Movie instances.
    #
    #   Kinopoisk::Movie.new 277537
    #   Kinopoisk::Movie.new 'Dexter'
    #
    # Initializing by title would send a search request and return first match.
    # Movie page request is made once and on the first access to a remote data.
    #
    def initialize(id, movie_id)
      @id       = id
      @movie_id = movie_id
      @url   = "https://www.kinopoisk.ru/film/#{movie_id}/video/#{id}/"
      @title = title
    end

    def title
      @title ||= doc.search('.news > table').first.search('td').first.text
    end

    def file(dimensions, quality)
      files[dimensions][quality] if files[dimensions][quality]
    end

    def best
      @best ||= [:hd, :sd].map do |dimensions|
        [:high, :medium, :low].map do |quality|
          files[dimensions][quality]
        end
      end.flatten.compact.first
    end

    private

    def doc
      @doc ||= Kinopoisk.parse url
    end

    def files
      return  @files if @files
      @files = { hd: {}, sd: {} }
      doc.search('td.news > a.continue').each do |link|
        found_quality = case link.text
        when 'Высокое качество'
          :high
        when 'Среднее качество'
          :medium
        when 'Низкое качество'
          :low
        end
        found_dimensions = link.parent.parent.search("td > img[src*='hd']").any? ? :hd : :sd
        @files[found_dimensions][found_quality] = link.attr('href').gsub! /.*link=(.*)$/, '\1'
      end
      @files
    end
  end
end
