#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'nokogiri'
require 'net/http'

require 'set'
require 'without_accents'

module Scrape

  def self.request(url)
    res = Net::HTTP.get_response(URI.parse(url))
    return Nokogiri::HTML(res.body), res.code.to_i
  end

  def self.page(url)
    status_code = 503
    wait = 0.1
    until status_code == 200
      sleep wait + rand
      body, status_code = request(url)
      wait += 3
    end
    body
  end

  def self.total_number_of_recipes(bbc_food_base_url)
    body, res = request(bbc_food_base_url)
    body.css('.recipe-finder__header')[0]
      .text
      .split('delicious')[0]
      .strip
      .split(',')
      .join
  end

  def self.list_of_search_terms(by_letter_url)
    terms = Set.new
    arr = ('a'..'z').to_a
    arr.each do |i|
      puts "Total number of terms found: #{terms.length}"
      url = by_letter_url + i
      puts url
      page(url).css('.foods li a img').each do |img|
        img['alt'].without_accents.split(' ').each do |term|
          terms.add(term)
        end
      end
    end
    terms.to_a
  end

  def self.construct_query_url(query, page_number)
    "#{SEARCH_URL}?page=#{page_number}&keywords=#{query}"
  end

end