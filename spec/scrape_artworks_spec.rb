require 'json'
require_relative '../scrape_artworks'

RSpec.describe 'Artwork Parsing' do
  it 'correctly compares parsed artwork details with reference list' do
    # Load the reference JSON data
    reference_path = File.join(File.dirname(__FILE__), '..', 'files', 'van-gogh-paintings.json')
    reference_json = JSON.parse(File.read(reference_path))
    reference_artworks = reference_json['knowledge_graph']['artworks']

    # Parse the artworks using the parse_artworks.rb script
    driver = setup_driver
    scrape_artworks(driver, './files/van-gogh-paintings.html')
    driver.quit


    # Load the newly parsed JSON data
    parsed_path = File.join(File.dirname(__FILE__), '..', 'artworks.json')
    parsed_json = JSON.parse(File.read(parsed_path))
    parsed_artworks = parsed_json['artworks']

    # Method to strip 'image' key from artworks
    def strip_image_key(artworks)
      artworks.map.with_index do |artwork, index|
        artwork.except('image')
      end
    end

    # Strip 'image' key from artworks because the image URLs might be null without additional http requests
    stripped_reference_artworks = strip_image_key(reference_artworks)
    stripped_parsed_artworks = strip_image_key(parsed_artworks)

    # Compare both artwork lists
    expect(stripped_parsed_artworks).to match_array(stripped_reference_artworks)
  end
end
