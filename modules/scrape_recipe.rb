#!/usr/bin/env ruby

# require './scrape.rb'

module ScrapeRecipe

  def self.recipe_title(page)
    title = page.css('.content-title__text').text
  end

  def self.meta_data(page)
    meta_data = {}
    page.css('.recipe-metadata-wrap p')
      .each_slice(2) do |i|
        key = i[0].text.strip
        value = i[1].text.strip
        meta_data[key] = value.include?('Serves') ? value.split('Serves ')[1] : value
      end
    meta_data
  end

  def self.description(page)
    page.css('.recipe-description__text').text.strip
  end

  def self.chef_name(page)
    page.css('.chef__name').text.strip
  end

  def self.programme_name(page)
    page.css('.chef__programme-name').text.strip
  end

  def self.combine_ingredients_and_sub_headings(ingredients, sub_headings)
    ingredients_and_sub_headings = {}
    step = case
      when sub_headings.length < ingredients.length
        ingredients_and_sub_headings['main'] = ingredients[0]
        1
      else 
        0
    end

    sub_headings.each_with_index do |sub, i|
      ingredients_and_sub_headings[sub.text] = ingredients[i+step]
    end

    ingredients_and_sub_headings
  end


  def self.ingredients(page)
    ingredients = page.css('.recipe-ingredients__list')
    ingredient_list = Array.new
    page.css('.recipe-ingredients__list').each do |i|
      arr = i.text.strip.split(/\n+/)
      arr.each do |i|
        i.strip!
      end
      ingredient_list.push arr.reject { |i| i.length == 0}
    end

    ingredients_sub_headings = page.css('.recipe-ingredients__sub-heading')
    combine_ingredients_and_sub_headings(ingredient_list, ingredients_sub_headings)
  end

  def self.method(page)
    method_steps = page.css('.recipe-method__list p')
    method = []
    method_steps.each do |step|
      method.push(step.text.strip)
    end
    method
  end

  def self.tips(page)
    tips = page.css('.recipe-tips__text').text.strip.gsub(/\s+/, ' ')
  end

  def self.add_to_object(obj, key, value)
    obj[key] = value unless value.length == 0
  end

  def self.recipe(page)
    recipe = {}
    add_to_object(recipe, 'meta_data', meta_data(page))
    add_to_object(recipe, 'chef_name', chef_name(page))
    add_to_object(recipe, 'programme_name', programme_name(page))
    add_to_object(recipe, 'description', description(page))
    add_to_object(recipe, 'ingredients', ingredients(page))
    add_to_object(recipe, 'method', method(page))
    add_to_object(recipe, 'tips', tips(page))

    recipe
  end

end