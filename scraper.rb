require "epathway_scraper"

def scrape_page(page, url, scraper)
  table = page.at("table.ContentPanel")
  scraper.extract_table_data_and_urls(table).each do |row|
    data = scraper.extract_index_data(row)
    record = {
      "info_url" => url,
      "council_reference" => data[:council_reference],
      "date_received" => data[:date_received],
      "description" => data[:description],
      "address" => data[:address],
      "date_scraped" => Date.today.to_s
    }
    ScraperWiki.save_sqlite(['council_reference'], record)
  end
end

scraper = EpathwayScraper::Scraper.new(
  "https://eservices.moreland.vic.gov.au/ePathway/Production"
)

agent = scraper.agent

url = "https://eservices.moreland.vic.gov.au/ePathway/Production/Web/GeneralEnquiry/EnquiryLists.aspx?ModuleCode=LAP"

page = scraper.pick_type_of_search(:advertising)

# Now do the paging magic
number_pages =  page.at("#ctl00_MainBodyContent_mPagingControl_pageNumberLabel").inner_text.split(" ")[3].to_i

(1..number_pages).each do |no|
  page = agent.get("https://eservices.moreland.vic.gov.au/ePathway/Production/Web/GeneralEnquiry/EnquirySummaryView.aspx?PageNumber=#{no}")
  puts "Scraping page #{no} of results..."
  scrape_page(page, url, scraper)
end
