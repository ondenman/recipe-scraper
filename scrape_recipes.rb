#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'json'
require './modules/scrape.rb'
require './modules/scrape_recipe.rb'

URLS_FILE_NAME = 'data/recipe_urls.txt'
OUT_FILE_NAME = 'data/recipes.json'
BASE_URL = 'http://www.bbc.co.uk'

def save_as_json(object)
    json = JSON.pretty_generate(object)
    File.write(OUT_FILE_NAME, json)
end

def url_array
    f = File.open(URLS_FILE_NAME)
    arr = Array.new
    arr = f.read.split("\n").each do |line|
        arr.push(line)
    end
    f.close

    arr
end

def main
    urls = url_array
    total_recipes = urls.length

    recipe_book = {}

    urls.each do |url|
        puts "Scraping recipe from: #{url} #{recipe_book.length + 1}/#{total_recipes}"
        page = Scrape::page(BASE_URL+url)
        recipe_contents = ScrapeRecipe::recipe(page)
        recipe_name = ScrapeRecipe::recipe_title(page)
        
        suffix = 2
        while recipe_book.key?(recipe_name)
            recipe_name = recipe_name+"_"+suffix.to_s
            suffix +=1
        end

        recipe_book[recipe_name] = recipe_contents
        save_as_json(recipe_book)
    end

end

main