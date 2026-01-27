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
  Pausing 1.023s
Getting page 1
/home/ianh/.local/share/mise/installs/ruby/3.2.2/lib/ruby/gems/3.2.0/gems/mechanize-2.8.5/lib/mechanize/pluggable_parsers.rb:107:in `new': MIME::Type.MIME::Type.new when called with a String is deprecated.
  Fetching detail page: https://www.joondalup.wa.gov.au/community-and-spaces/community-consultation/31b-strathyre-drive,-duncraig-–-single-house-(additions)
  Extracted DA25/0869 from detail page
Saving record DA25/0869 - 31B Strathyre Drive, Duncraig, WA
...
  Fetching detail page: https://www.joondalup.wa.gov.au/community-and-spaces/community-consultation/51a-conidae-drive,-heathridge-–-grouped-dwelling-(new-dwelling)
  Extracted DA25/0774 from detail page
Saving record DA25/0774 - 51A Conidae Drive, Heathridge, WA
Deleting 0 applications scraped between  and 2025-12-28
  Running VACUUM to reclaim space...
Finished! Added 12 applications, and skipped 0 unprocessable applications from 1 pages.
```

Execution time: ~ 11 seconds

## To run style and coding checks

    bundle exec rubocop

## To check for security updates

    gem install bundler-audit
    bundle-audit
