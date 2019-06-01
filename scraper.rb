require "epathway_scraper"

EpathwayScraper.scrape_and_save(
  "https://eservices.moreland.vic.gov.au/ePathway/Production",
  list_type: :advertising
)
