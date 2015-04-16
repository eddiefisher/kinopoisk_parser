require 'spec_helper'

describe Kinopoisk::Movie, vcr: { cassette_name: 'movies' } do
  let(:dexter)        { Kinopoisk::Movie.new 277537 }
  let(:avatar)        { Kinopoisk::Movie.new 251733 }
  let(:hercules)      { Kinopoisk::Movie.new 461958 }
  let(:groundhog_day) { Kinopoisk::Movie.new 527    }
  let(:knights)       { Kinopoisk::Movie.new 649576 }
  let(:druginniki)    { Kinopoisk::Movie.new 462455 }
  let(:encounter)     { Kinopoisk::Movie.new 687886 }
  let(:one_plus_one)  { Kinopoisk::Movie.new 885533 }

  it { expect(dexter.default_trailer_id).to eq 82610 }
  it { expect(dexter.url).to eq('http://www.kinopoisk.ru/film/277537/') }
  it { expect(dexter.title).to eq('Декстер') }
  it { dexter.title_en.should eq('Dexter') }
  it { dexter.countries.should eq(['США']) }
  it { dexter.year.should eq(2006) }
  it { dexter.poster.should eq('http://st.kp.yandex.net/images/film_iphone/iphone360_277537.jpg') }
  it { dexter.poster_big.should eq('http://www.kinopoisk.ru/images/film_big/277537.jpg') }
  it { dexter.producers.map(&:name).should eq(['Сара Коллетон','Джон Голдвин','Роберт Ллойд Льюис']) }
  it { dexter.art_directors.map(&:name).should eq(['Джессика Кендер','Энтони Коули','Эрик Уейлер']) }
  it { dexter.operators.map(&:name).should eq(['Ромео Тироне','Джеф Джёр','Мартин Дж. Лэйтон']) }
  it { dexter.editors.map(&:name).should eq(["Луис Циоффи", "Стюарт Шилл", "Кит Хендерсон"]) }
  it { dexter.writers.map(&:name).should eq(['Скотт Бак', 'Карен Кэмпбелл', 'Дэниэл Церон']) }
  it { dexter.actors.map(&:name).should include('Майкл С. Холл', 'Дженнифер Карпентер') }
  it { dexter.genres.should eq(['триллер','драма','криминал', 'детектив']) }
  it { dexter.directors.map(&:name).should eq(['Джон Дал','Стив Шилл','Кит Гордон']) }
  it { dexter.slogan.should eq('«Takes life. Seriously»') }
  it { dexter.description.should match('Декстер Морган.') }
  it { dexter.premiere_world.should eq('1 октября 2006') }
  it { dexter.premiere_ru.should eq('3 ноября 2008') }
  it { dexter.composers.map(&:name).should eq(['Дэниэл Лихт']) }
  it { dexter.imdb_rating_count.should be_a(Integer) }
  it { expect(dexter.imdb_rating).to be 8.9 }
  it { dexter.rating_count.should be_a(Integer) }
  it { dexter.rating.should be_a(Float) }
  it { dexter.box_office_ru.should eq('') }

  it { expect(avatar.default_trailer_id).to eq 18381 }
  it { avatar.box_office_world.should eq(2782275172) }
  it { avatar.box_office_ru.should match('[$\d]') }
  it { avatar.box_office_us.should match('[$\d]') }
  it { avatar.budget.should eq("237000000".to_i) }
  it { avatar.length.should eq(162) }

  it { expect(hercules.box_office_world).to be_nil }

  it { expect(groundhog_day.actors.map(&:name)).to include('Билл Мюррей', 'Энди МакДауэлл', 'Крис Эллиот', 'Стивен Тоболовски', 'Брайан Дойл-Мюррей', 'Марита Герати', 'Анджела Пэтон', 'Рик Дукомман', 'Рик Овертон', 'Робин Дьюк') }
  it { expect(groundhog_day.actors.count).to eq 10 }

  it { expect(knights.default_trailer_id).to be_nil }
  it { expect(knights.actors).to be_empty }

  it { expect(druginniki.imdb_rating).to eq 5.7 }

  it { expect(encounter.title).to eq('Неожиданная встреча 2: Потеряный рай') }

  it 'should make only one request' do
    dexter.title
    dexter.countries
    a_request(:get, dexter.url).should have_been_made.once
  end

  it 'should raise error if nothing found' do
    expect { Kinopoisk::Movie.new(111111111).title }.to raise_error
  end

  # it 'should raise error if response is emtpy' do
  #   pending
  # end

  context 'by title \'Dexter\'' do
    let(:dexter_by_title) { Kinopoisk::Movie.new 'Dexter' }

    it { expect(dexter_by_title.url).to eq dexter.url }

    it 'should make only one request to initialize' do
      dexter_by_title
      a_request(:get, /.*/).should have_been_made.once
    end

    it 'should make max two requests' do
      dexter_by_title.title
      dexter_by_title.countries
      a_request(:get, /.*/).should have_been_made.twice
    end
  end

  context 'by title \'1+1\'' do
    let(:one_plus_one_by_title) { Kinopoisk::Movie.new '1+1' }

    it { expect(one_plus_one_by_title.url).to eq one_plus_one.url }
    it { expect(one_plus_one_by_title.year).to eq one_plus_one.year }
  end
end
