#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'set'
require './modules/scrape.rb'

BBC_FOOD_BASE_URL = 'http://www.bbc.co.uk/food/recipes/'
SEARCH_URL = BBC_FOOD_BASE_URL+"search/"
LETTER_INDEX_URL = 'http://www.bbc.co.uk/food/ingredients/by/letter/'

def scrape_urls_to_file(queries, total_number_of_recipes, file)
  recipe_urls = Set.new
  out_file = File.open(file, 'w')

  queries.each do |query|
    page_number = 1
    while recipe_urls.length < total_number_of_recipes
      page = Scrape::page(Scrape::construct_query_url(query, page_number))
      break if page.css("h3.error")[0] == true
      
      page.css('.article  .left  h3  a').each do |recipe|
        out_file.puts "#{recipe["href"]}\n" unless recipe_urls.include? recipe["href"]
        recipe_urls.add(recipe["href"])
      end

      puts "Query: '#{query}'. Page number: #{page_number}. "\
            "Recipes found #{recipe_urls.length}/#{total_number_of_recipes}"     
      page_number += 1
    end
  end

  out_file.close
end

def main
  queries = ['1']
            .concat(Scrape::list_of_search_terms(LETTER_INDEX_URL)
            .concat(('2'..'10').to_a))

  total_number_of_recipes = Scrape::total_number_of_recipes(BBC_FOOD_BASE_URL).to_i
  puts "Total number of recipes to find: #{total_number_of_recipes}"

  dir = "data"
  Dir.mkdir(dir) unless File.exist?(dir)
  file = "#{dir}/recipe_urls.txt"

  scrape_urls_to_file(queries, total_number_of_recipes, file)
end

main