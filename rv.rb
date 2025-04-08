require 'selenium-webdriver'

# Initialize Selenium
options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--headless') # Run without GUI
options.add_argument('--disable-gpu')
options.add_argument('--no-sandbox')
options.debugger_address = 'localhost:9222'

driver = Selenium::WebDriver.for(:chrome, options: options)

# Replace this with your product URL
url = 'https://shopee.com.my/-60mL-Pure-Body-Fragrance-Pati-Perfume-MEN-UNISEX-i.268499984.2938876101'

driver.navigate.to(url)
sleep 5 # Wait for JS to load reviews

# Scroll down to load reviews
driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
sleep 3

def scrape_reviews(driver)
  reviews = driver.find_elements(css: '.shopee-product-rating__main')
  reviews.map(&:text)
end

def click_next_page(driver)
  pagination = driver.find_elements(css: '.product-ratings__page-controller button')
  current_page_index = pagination.find_index do |btn|
    btn.attribute('class').include?('shopee-button-solid')
  end

  next_page_btn = pagination[current_page_index + 1] rescue nil
  if next_page_btn
    next_page_btn.click
    sleep 3
    return true
  else
    return false
  end
end

all_reviews = []

loop do
  sleep 2
  all_reviews += scrape_reviews(driver)
  break unless click_next_page(driver)
end

# Print or export
puts "✅ Scraped #{all_reviews.size} reviews:"
all_reviews.each_with_index { |rev, i| puts "#{i + 1}. #{rev}" }

