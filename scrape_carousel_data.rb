require 'nokogiri'
require 'selenium-webdriver'
require 'webdrivers'
require 'json'
require 'addressable/uri'

def setup_driver
  # Download and install the latest version of ChromeDriver
  Selenium::WebDriver::Chrome::Service.driver_path = Webdrivers::Chromedriver.update

  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--disable-gpu')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')

  Selenium::WebDriver.for(:chrome, options: options)
end

def scrape_carousel(driver, file_path)
  # Load the HTML file from the local filesystem
  absolute_path = File.expand_path(file_path, __dir__)
  file_url = "file:///#{absolute_path}"
  driver.navigate.to(file_url)

  # Wait for potential JavaScript execution to complete
  sleep 5

  doc = Nokogiri::HTML(driver.page_source)

  carousel_data = []

  # Select the scrolling carousel element
  carousel = doc.at_css('g-scrolling-carousel')

  return unless carousel

  # Select child elements with 'klitem-tr' class and get 'href' from it or one of its descendant elements
  carousel.css('.klitem-tr').each do |klitem_tr|
    # Get the 'href' attribute from the descendant element or klitem_tr itself if it is an a element
    href = klitem_tr.at_css('a') ? klitem_tr.at_css('a')['href'] : klitem_tr['href']

    # Get the title from the klitem-tr or its descendant element similar to 'href'
    title = klitem_tr.at_css('a') ? klitem_tr.at_css('a')['title'] : klitem_tr['title']

    # Split the title into name and extension
    split_name, extension = title.split(' (', 2)
    extension = extension.sub(/\)\z/, '') if extension

    # Get the image source
    href = href ? "https://www.google.com" + href : nil

    # Parse the query string into a hash
    params = Addressable::URI.parse(href).query_values

    name = params ? params['q'] : '' # Extract the 'q' parameter from the query string

    # if title == name then no extension and the extension we found previously was not correct
    if title == name
      extension = nil
    elsif name != split_name
      name = split_name
    end

    # From the descendants of element with class 'klitem-tr', get element with 'klitem' class
    klitem = klitem_tr.at_css('.klitem')

    if klitem
      # Get image src
      image_element = klitem.at_css('img')
      image_src = image_element ? image_element['src'] : nil

      # Create a hash for the carousel data
      data = {
        "name" => name,
        "link" => href,
        "image" => image_src,
      }

      data["extensions"] = [extension] if extension

      carousel_data << data
    end
  end

  # get filename without extension from file_path
  filename = File.basename(file_path, ".*")

  # Output the JSON to a file
  File.open("#{filename}.json", "w") do |file|
    file.write(JSON.pretty_generate({ "data" => carousel_data }))
  end
end

# driver = setup_driver # Setup the WebDriver

# begin
#   scrape_carousel(driver, './files/Cast of Friends.html')
# ensure
#   driver.quit
# end
