# frozen_string_literal: true

require "timecop"
require "fileutils"
require_relative "../scraper"
# require_relative "support/fibonacci"

RSpec.describe Scraper do
  let(:db_file) { "data.sqlite" }

  describe ".run" do
    def fetch_url_with_redirects(url)
      agent = Mechanize.new
      agent.get(url)
    end

    # def expect_no_results
    #   return unless File.exist?(db_file)
    #
    #   results = ScraperWiki.select("name FROM sqlite_master WHERE type='table' AND name='data'")
    #   expect(results).to be_empty
    # end

    def expect_results
      expected = if File.exist?("spec/expected/scraper.yml")
                   YAML.safe_load(File.read("spec/expected/scraper.yml"))
                 else
                   []
                 end
      results = ScraperWiki.select("* from data order by council_reference")

      ScraperWiki.close_sqlite

      if results != expected
        # Overwrite expected so that we can compare with version control
        # (and maybe commit if it is correct)
        FileUtils.mkdir_p("spec/expected")
        File.open("spec/expected/scraper.yml", "w") do |f|
          f.write(results.to_yaml)
        end
      end

      expect(results).to eq expected

      # FIXME: Think of a way for checking this when It has lower case suburbs and no postcode
      # geocodable = results
      #                .map { |record| record["address"] }
      #                .uniq
      #                .count { |text| ScraperUtils::SpecSupport.geocodable? text }
      # puts "Found #{geocodable} out of #{results.count} unique geocodable addresses " \
      #        "(#{(100.0 * geocodable / results.count).round(1)}%)"
      # expected = [(0.5 * results.count - 3), 1].max
      # expect(geocodable).to be >= expected

      descriptions = results
                       .map { |record| record["description"] }
                       .uniq
                       .count do |text|
        selected = ScraperUtils::SpecSupport.reasonable_description? text
        puts "  description: #{text} is not reasonable" if ENV["DEBUG"] && !selected
        selected
      end
      puts "Found #{descriptions} out of #{results.count} unique reasonable descriptions " \
             "(#{(100.0 * descriptions / results.count).round(1)}%)"
      expected = [0.3 * results.count - 3, 1].max
      expect(descriptions).to be >= expected

      info_urls = results
                    .map { |record| record["info_url"] }
                    .uniq
                    .count { |text| text.to_s.match(%r{\Ahttps?://}) }
      puts "Found #{info_urls} out of #{results.count} unique info_urls " \
             "(#{(100.0 * info_urls / results.count).round(1)}%)"
      expected = info_urls == 1 ? 1 : [(0.7 * results.count - 3), 1].max
      expect(info_urls).to be >= expected

      VCR.use_cassette("scraper.info_urls") do
        count = 0
        failed = 0

        # Use fibonacci number sequence to filter which records to check as it quickly becomes too lengthy!
        fib_indices = ScraperUtils::MathsUtils.fibonacci_series(results.size - 1).uniq
        fib_indices.each do |index|
          record = results[index]
          info_url = record["info_url"]
          puts "Checking info_url[#{index}]: #{info_url} #{info_urls > 1 ? ' has expected details' : ''} ..."
          page = fetch_url_with_redirects(info_url)

          expect(page.code).to eq("200")

          # Force consistent encoding before comparison
          page_body = page.body.force_encoding("UTF-8").gsub(/\s\s+/, " ")
          # Expect max 1/4 failure expectations
          %w[council_reference address description].each do |attribute|
            count += 1
            expected = CGI.escapeHTML(record[attribute]).gsub(/\s\s+/, " ")
            # Handle missing STATE
            expected2 = expected.gsub(" #{Scraper::STATE} ", " ").gsub(/,? #{Scraper::STATE}\z/, "").strip
            expected3 = expected2.gsub(", ", " ").strip
            next if page_body.include?(expected) || page_body.include?(expected2) || page_body.include?(expected3)

            failed += 1
            puts "  Missing: #{expected} or #{expected2}"
            expect(page_body).to include(expected) if failed * 3 > (count + 3)
          end
        end
        if count > 0
          puts "#{(100.0 * (count - failed) / count).round(1)}% detail checks passed " \
                 "(#{failed}/#{count} failed)!"
        end
      end
    end

    it "Runs" do
      ScraperWiki.close_sqlite
      FileUtils.rm_f(db_file)

      VCR.use_cassette('scraper') do
        date = Date.new(2026, 2, 20)
        Timecop.freeze(date) do
          Scraper.new.run
        end
      end
      expect_results
    end
  end
end
