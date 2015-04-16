module Kinopoisk
  class Movie
    attr_accessor :id, :url, :title

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
    def initialize(input, title = nil)
      @id    = input.is_a?(String) ? find_by_title(input) : input
      @url   = "http://www.kinopoisk.ru/film/#{id}/"
      @title = title
    end

    # Returns an array of Person object
    def actors
      actors_lists = doc.search '#actorList ul'
      actors_lists.any? ? links_to_people(actors_lists.first.search 'li a') : []
    end

    # Returns a string containing title in russian
    def title
      @title ||= doc.search('.moviename-big').xpath('text()').text.strip
    end

    # Returns an integer imdb rating vote count
    def imdb_rating_count
      doc.search('div.block_2 div:last').text.gsub(/[ ()]/, '').to_i
    end

    # Returns a float imdb rating
    def imdb_rating
      doc.search('#block_rating .block_2 div:nth-child(2)').text[/\d\.\d\d/].to_f
    end

    # Returns an integer release year
    def year
      doc.search("table.info a[href*='/m_act%5Byear%5D/']").text.to_i
    end

    # Returns an array of strings containing countries
    def countries
      doc.search("table.info a[href*='/m_act%5Bcountry%5D/']").map(&:text)
    end

    # Returns a string containing budget for the movie
    def budget
      doc.search("//td[text()='бюджет']/following-sibling::*//a").text.gsub(/\D/, '').to_i
    end

    # Returns a string containing Russia box-office
    def box_office_ru
      doc.search("td#div_rus_box_td2 a").text
    end

    # Returns a string containing USA box-office
    def box_office_us
      doc.search("td#div_usa_box_td2 a").text
    end

    # Returns a string containing world box-office
    def box_office_world
      value = doc.search("//td[text()='сборы в мире']/following-sibling::td//div/a[1]").text[/=(.+)$/, 1]
      value && value.gsub(/\D/, '').to_i
    end

    # Returns a url to a small sized poster
    def poster
      doc.search("img[itemprop='image']").first.attr 'src'
    end

    # Returns a string containing world premiere date
    def premiere_world
      doc.search('td#div_world_prem_td2 a:first').text
    end

    # Returns a string containing Russian premiere date
    def premiere_ru
      doc.search('td#div_rus_prem_td2 a:first').text
    end

    # Returns a float kinopoisk rating
    def rating
      doc.search('span.rating_ball').text.to_f
    end

    # Returns a url to a big sized poster
    def poster_big
      big_image = doc.search("a.popupBigImage").first
      "http://www.kinopoisk.ru/images/film_big/#{@id}.jpg" if big_image && big_image.attr('href')
    end

    # Returns an integer length of the movie in minutes
    def length
      doc.search('td#runtime').text.to_i
    end

    # Returns a string containing title in english
    def title_en
      search_by_itemprop 'alternativeHeadline'
    end

    # Returns a string containing movie description
    def description
      search_by_itemprop 'description'
    end

    # Returns an integer kinopoisk rating vote count
    def rating_count
      search_by_itemprop('ratingCount').to_i
    end

    def wallpapers
      wallpaper.images
    end

    # Returns an array of strings containing director names
    def directors
      links_to_people doc.search("[itemprop='director']/a")
    end

    # Returns an array of strings containing producer names
    def producers
      links_to_people doc.search("[itemprop='producer']/a")
    end

    # Returns an array of strings containing composer names
    def composers
      links_to_people doc.search("[itemprop='musicBy']/a")
    end

    # Returns an array of strings containing genres
    def genres
      to_array search_by_itemprop 'genre'
    end

    # Returns an array of strings containing writer names
    def writers
      links_to_people doc.search("//td[text()='сценарий']/following-sibling::td//a")
    end

    # Returns an array of strings containing operator names
    def operators
      links_to_people doc.search("//td[text()='оператор']/following-sibling::td//a")
    end

    # Returns an array of strings containing art director names
    def art_directors
      links_to_people doc.search("//td[text()='художник']/following-sibling::td//a")
    end

    # Returns an array of strings containing editor names
    def editors
      links_to_people doc.search("//td[text()='монтаж']/following-sibling::td//a")
    end

    # Returns a string containing movie slogan
    def slogan
      search_by_text 'слоган'
    end

    def default_trailer_id
      trailer_link_tag = doc.search("#trailerinfo a[href^='/film/#{id}/video/']").first
      trailer_link_tag.attr(:href).gsub(/\/film\/\d+\/video\/(\d+)\//, '\1').to_i if trailer_link_tag
    end

    private

    def doc
      @doc ||= Kinopoisk.parse url
    end

    def wallpaper
      Kinopoisk::Wallpapers.new(id)
    end

    # Kinopoisk has defined first=yes param to redirect to first result
    # Return its id from location header
    def find_by_title(title)
      url = "http://www.kinopoisk.ru/index.php?level=7&from=forma&result=adv&m_act[from]=forma&m_act[what]=content&m_act[find]=#{URI.encode_www_form_component title}&first=yes"
      Kinopoisk.fetch(url).headers['Location'].to_s.match(/\/(\d*)\/$/)[1]
    end

    def search_by_itemprop(name)
      doc.search("[itemprop=#{name}]").text
    end

    def search_by_text(name)
      doc.search("//td[text()='#{name}']/following-sibling::*").text
    end

    def to_array(string)
      string.gsub('...', '').split(', ')
    end

    def links_to_people(links)
      links.map do |link|
        Kinopoisk::Person.new a_tag_to_id(link) unless link.text == '...'
      end.compact
    end

    def a_tag_to_id(tag)
      tag.attr('href')[/\/name\/(\d+)/, 1].to_i
    end
  end
end
