#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'set'
require './library/functions.rb'

BBC_FOOD_BASE_URL = 'http://www.bbc.co.uk/food/recipes/'
SEARCH_URL = BBC_FOOD_BASE_URL+"search/"

DIR = "data"
Dir.mkdir(DIR) unless File.exist?(DIR)
FILE = "#{DIR}/recipe_urls.txt"

QUERIES = ['1'].concat(get_list_of_search_terms.concat(('2'..'10').to_a))

def main
  recipe_urls = Set.new
  total_number_of_recipes = get_total_number_of_recipes.to_i

  puts "Total number of recipes on site: #{total_number_of_recipes}"

  out_file = File.open(FILE, 'w')

  QUERIES.each do |query|
    puts "Query: #{query}"
    page_number = 1

    loop do
      break unless recipe_urls.length < total_number_of_recipes
      page = get_page(construct_query_url(query, page_number))

      page.css('.article  .left  h3  a').each do |recipe|
        out_file.puts "#{recipe["href"]}\n" unless recipe_urls.include? recipe["href"]
        recipe_urls.add(recipe["href"])
      end

      puts "Query: '#{query}'. Page number: #{page_number}. "\
            "Recipes found #{recipe_urls.length}/#{total_number_of_recipes}"
      page_number += 1

      break if page.css("h3.error")[0] == true
    end
  end
  out_file.close
end

main
