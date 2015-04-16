require 'spec_helper'

describe Kinopoisk::Trailer, vcr: { cassette_name: 'trailers' } do
  let(:godzilla) { Kinopoisk::Trailer.new 100881, 260991 }
  let(:godzilla_2nd) { Kinopoisk::Trailer.new 96480, 260991 }
  let(:godzilla_ukr) { Kinopoisk::Trailer.new 91752, 260991 }
  let(:terminator) { Kinopoisk::Trailer.new 70975, 507 }

  it { expect(godzilla.id).to eq 100881 }
  it { expect(godzilla.movie_id).to eq 260991 }
  it { expect(godzilla.url).to eq 'http://www.kinopoisk.ru/film/260991/video/100881/' }
  it { expect(godzilla.title).to eq 'Интервью с создателями фильма (русские субтитры)' }

  it { expect(godzilla.file(:hd, :high)).to be_nil }
  it { expect(godzilla.file(:hd, :medium)).to eq 'http://kp.cdn.yandex.net/260991/kinopoisk.ru-Godzilla-212114.mp4' }
  it { expect(godzilla.file(:hd, :low)).to eq 'http://kp.cdn.yandex.net/260991/kinopoisk.ru-Godzilla-212113.mp4' }

  it { expect(godzilla.file(:sd, :high)).to eq 'http://kp.cdn.yandex.net/260991/kinopoisk.ru-Godzilla-212017.mp4' }
  it { expect(godzilla.file(:sd, :medium)).to eq 'http://kp.cdn.yandex.net/260991/kinopoisk.ru-Godzilla-212112.mp4' }
  it { expect(godzilla.file(:sd, :low)).to be_nil }

  it { expect(godzilla.best).to eq 'http://kp.cdn.yandex.net/260991/kinopoisk.ru-Godzilla-212114.mp4' }

  it { expect(godzilla_2nd.file(:sd, :low)).to eq 'http://kp.cdn.yandex.net/260991/kinopoisk.ru-Godzilla-201321.mp4' }

  it { expect(godzilla_ukr.file(:hd, :high)).to eq 'http://kp.cdn.yandex.net/260991/kinopoisk.ru-Godzilla-191553.mp4' }

  it { expect(terminator.file(:hd, :medium)).to eq 'http://kp.cdn.yandex.net/507/kinopoisk.ru-Terminator-The-157229.mp4' }
  it { expect(terminator.file(:hd, :low)).to eq 'http://kp.cdn.yandex.net/507/kinopoisk.ru-Terminator-The-157236.flv' }
  it { expect(terminator.file(:sd, :medium)).to eq 'http://kp.cdn.yandex.net/507/kinopoisk.ru-Terminator-The-157237.mp4' }

  it 'should make only one request' do
    godzilla.title
    godzilla.file :hd, :high
    a_request(:get, godzilla.url).should have_been_made.once
  end
end
