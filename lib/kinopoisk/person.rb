module Kinopoisk
  class Person
    attr_accessor :id, :url, :name

    # New instance can be initialized with id(string or integer) and an optional
    # name to make it easier to differentiate Kinopoisk::Person instances.
    #
    #   Kinopoisk::Person.new 13180
    #
    # Request to kinopoisk is made once and on the first access to a remote data.
    #
    def initialize(id, name = nil)
      @id   = id
      @url  = "http://www.kinopoisk.ru/name/#{id}/"
      @name = name
    end

    # Returns a url to a poster
    def poster
      doc.search("div[@id='photoBlock']//img").first.attr 'src'
    end

    # Returns a string containing name in russian
    def name
      @name ||= doc.search('.moviename-big').text
    end

    # Returns a string containing name in english
    def name_en
      doc.search("div[@id='headerPeople']/span[@itemprop='alternativeHeadline']").text.chomp
    end

    # Returns a string containing partner's name
    def partner
      doc.search("//td[@class='type'][contains(text(),'супруг')]/following-sibling::*").text
    end

    # Returns a birthdate date object
    def birthdate
      doc.search("td.birth").first.attr 'birthdate'
    end

    # Returns a string containing birthplace
    def birthplace
      search_by_text('место рождения')
    end

    # Returns an array of strings containing genres
    def genres
      search_by_text('жанры').split(', ')
    end

    # Returns an array of strings containing career professions
    def career
      search_by_text('карьера').split(', ')
    end

    # Returns an integer total movie count
    def total_movies
      search_by_text('всего фильмов').to_i
    end

    # Returns an array of strings containing best movie titles
    def best_movies
      doc.search('#BestFilmList a').map(&:text)
    end

    # Returns a string containing year of first movie
    def first_movie
      doc.search("//td/a[@title='Первый фильм']").text
    end

    # Returns a string containing year of last movie
    def last_movie
      doc.search("//td/a[@title='Последний фильм']").text
    end

    # Returns a string containing height
    def height
      search_by_text 'рост'
    end

    private

    def doc
      @doc ||= Kinopoisk.parse url
    end

    def search_by_text(name)
      doc.search("//td[@class='type'][text()='#{name}']/following-sibling::*").text
    end
  end
end
