# City of Joondalup - Open Development Applications Scraper

* Cookie tracking - No
* Pagnation - yes, via a flag in the HTML returned in the JSON data
* JavaScript - Yes, but we don't need to execute it, instead call the api directly
* Clearly defined data within a row - No, data is in HTML in a JSON record, and reference in the details page
* System - custom

This is a scraper that runs on [Morph](https://morph.io).
To get started [see the documentation](https://morph.io/documentation)

Add any issues to https://github.com/planningalerts-scrapers/issues/issues

## To run the scraper

    bundle exec ruby scraper.rb

### Expected output

```
Getting initial page
Pausing 1.013s
Getting page 1
/home/ianh/.local/share/mise/installs/ruby/3.2.2/lib/ruby/gems/3.2.0/gems/mechanize-2.8.5/lib/mechanize/pluggable_parsers.rb:107:in `new': MIME::Type.MIME::Type.new when called with a String is deprecated.
  Pausing 0.949s
  Fetching detail page: https://www.joondalup.wa.gov.au/community-and-spaces/community-consultation/26a-woodland-loop,-edgewater-–-grouped-dwelling-(additions)
  Extracted DA25/0966 from detail page
Saving record DA25/0966 - 26A Woodland Loop, Edgewater, WA
  Pausing 0.702s
  Fetching detail page: https://www.joondalup.wa.gov.au/community-and-spaces/community-consultation/6-pompano-court,-heathridge-–-single-house-(additions)
  Extracted DA25/0858 from detail page
...
Deleting records scraped before 2025-12-25
  Deleted 1 records
Finished! Added 10 records, and skipped 0 unprocessable records from 1 pages.
```

Execution time: ~ 11 seconds

## To run style and coding checks

    bundle exec rubocop

## To check for security updates

    gem install bundler-audit
    bundle-audit
