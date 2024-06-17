require 'json'
require 'nokogiri'
require 'selenium-webdriver'
require 'webdrivers'
require_relative '../scrape_carousel_data'

RSpec.describe 'Carousel General Parsing' do
  before(:all) do
    @driver = setup_driver
  end

  after(:all) do
    @driver.quit
  end

  def scrape_and_load_data(file_path)
    scrape_carousel(@driver, file_path)
    filename = file_path.split('/').last.split('.').first + '.json'
    JSON.parse(File.read(filename))['data']
  end

  it 'fetches cast of a popular TV series and checks data integrity' do
    file_path = './files/cast-of-friends.html'
    data = scrape_and_load_data(file_path)

    expect(data).not_to be_empty
    data.each do |item|
      expect(item).to have_key('name')
      expect(item).to have_key('image')
      expect(item).to have_key('link')
    end
  end

  it 'fetches cast of a popular TV series and checks data integrity' do
    file_path = './files/friends-cast-jennifer-aniston.html'
    data = scrape_and_load_data(file_path)

    expect(data).not_to be_empty
    data.each do |item|
      expect(item).to have_key('name')
      expect(item).to have_key('image')
      expect(item).to have_key('link')
    end
  end

  it 'fetches list of american presidents and checks data integrity' do
    file_path = './files/american-presidents.html'
    data = scrape_and_load_data(file_path)

    expect(data).not_to be_empty
    data.each do |item|
      expect(item).to have_key('name')
      expect(item).to have_key('image')
      expect(item).to have_key('link')
    end
  end

  it 'fetches the list of kendrick lamar albums and checks data integrity' do
    file_path = './files/kendrick-lamar-albums.html'
    data = scrape_and_load_data(file_path)

    expect(data).not_to be_empty
    data.each do |item|
      expect(item).to have_key('name')
      expect(item).to have_key('image')
      expect(item).to have_key('link')
    end
  end

end
