require 'rubygems'
require 'bundler/setup'

require 'nokogiri'
require 'net/http'

require 'set'
require 'without_accents'

def send_request(url)
  response = Net::HTTP.get_response(URI.parse(url))
  return Nokogiri::HTML(response.body), response.code.to_i
end

def get_page(url)
  status_code = 503
  wait = 0.1
  until status_code == 200
    sleep wait + rand
    page, status_code = send_request(url)
    wait += 3
  end
  return page
end

def get_total_number_of_recipes
  page, status_code = send_request(BBC_FOOD_BASE_URL)
  page.css(".recipe-finder__header")[0]
  .text
  .split('delicious')[0]
  .strip
  .split(',')
  .join
end

def get_list_of_indgredients
  ingredients = Set.new
  arr = ('a'..'z').to_a
  arr.each do |letter|
    puts "Total number of ingredients: #{ingredients.length}"
    url = "http://www.bbc.co.uk/food/ingredients/by/letter/"+letter
    puts url
    get_page(url).css(".foods li a img").each do |img|
      img["alt"].without_accents.split(' ').each do |term|
        ingredients.add(term)
      end
    end
  end
  return ingredients.to_a
end

def query_url(query, page_number)
  "#{SEARCH_URL}?page=#{page_number}&keywords=#{query}"
end

def main
  recipe_urls = Set.new
  total_number_of_recipes = get_total_number_of_recipes.to_i
  puts "Total number of recipes #{total_number_of_recipes}"

  outFile = File.open(FILE, 'w')

  QUERIES.each do |query|
    puts "Query: #{query}"
    page_number = 1
    ok = true

    while ok == true
      break unless recipe_urls.length < total_number_of_recipes

      page = get_page(query_url(query, page_number))
      page.css(".article  .left  h3  a").each do |recipe|
        outFile.puts "#{recipe["href"]}\n" unless recipe_urls.include? recipe["href"]
        recipe_urls.add(recipe["href"])
    end

    puts "Query: '#{query}'. Page number: #{page_number}. Recipes found #{recipe_urls.length}/#{total_number_of_recipes}"
    page_number += 1
    ok = !page.css("h3.error")[0] ? true : false
  end
end

outFile.close
end

DIR = "data"
Dir.mkdir(DIR) unless File.exists?(DIR)
FILE = "#{DIR}/recipe_urls.txt"

BBC_FOOD_BASE_URL = 'http://www.bbc.co.uk/food/recipes/'
SEARCH_URL = BBC_FOOD_BASE_URL+"search/"
QUERIES = ['1'].concat(get_list_of_indgredients.concat(('2'..'10').to_a))

# puts get_list_of_indgredients
main
