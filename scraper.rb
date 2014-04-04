require 'scraperwiki'
require 'mechanize'

agent = Mechanize.new

url = "https://eservices.moreland.vic.gov.au/ePathway/Production/Web/GeneralEnquiry/EnquiryLists.aspx?ModuleCode=LAP"

def scrape_page(page, url)
  table = page.at("table.ContentPanel")
  table.search("tr")[1..-1].each do |tr|
    day, month, year = tr.search("td")[1].inner_text.split("/").map{|s| s.to_i}
    record = {
      "info_url" => url,
      "comment_url" => url,
      "council_reference" => tr.at("td a").inner_text,
      "date_received" => Date.new(year, month, day).to_s,
      "description" => tr.search("td")[2].inner_text,
      "address" => tr.search("td")[3].inner_text,
      "date_scraped" => Date.today.to_s
    }
    #p record
    if (ScraperWiki.select("* from data where `council_reference`='#{record['council_reference']}'").empty? rescue true)
      ScraperWiki.save_sqlite(['council_reference'], record)
    else
      puts "Skipping already saved record " + record['council_reference']
    end
  end
end

page = agent.get(url)

form = page.forms.first
form.radiobuttons.first.check
page = form.submit(form.button_with(type: "submit"))

# Now do the paging magic
number_pages =  page.at("#ctl00_MainBodyContent_mPagingControl_pageNumberLabel").inner_text.split(" ")[3].to_i

(1..number_pages).each do |no|
  page = agent.get("https://eservices.moreland.vic.gov.au/ePathway/Production/Web/GeneralEnquiry/EnquirySummaryView.aspx?PageNumber=#{no}")
  puts "Scraping page #{no} of results..."
  scrape_page(page, url)
end
