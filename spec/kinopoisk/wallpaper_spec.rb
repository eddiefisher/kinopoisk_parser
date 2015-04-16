require 'spec_helper'

describe Kinopoisk::Wallpapers, vcr: { cassette_name: 'wallpapers' } do
  context "wallpaper" do
    let(:dexter_by_title) { Kinopoisk::Movie.new 'Dexter' }

    it { expect(dexter_by_title.wallpapers.count).to eq(42) }
  end
end
