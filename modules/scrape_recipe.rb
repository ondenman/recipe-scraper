require './scrape.rb'

module ScrapeRecipe

  def title
    title = @@page.css('.content-title__text').text
  end

  def meta_data
    meta_data = {}
    @@page.css('.recipe-metadata-wrap p')
      .each_slice(2) do |i|
        key = i[0].text.strip
        value = i[1].text.strip
        meta_data[key] = value.include?('Serves') ? value.split('Serves ')[1] : value
      end
    meta_data
  end

  def description
    @@page.css('.recipe-description__text').text.strip
  end

  def chef_name
    @@page.css('.chef__name').text.strip
  end

  def programme_name
    @@page.css('.chef__programme-name').text.strip
  end

  def combine_ingredients_and_sub_headings(ingredients, sub_headings)
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


  def ingredients
    ingredients = @@page.css('.recipe-ingredients__list')
    ingredient_list = Array.new
    @@page.css('.recipe-ingredients__list').each do |i|
      arr = i.text.strip.split(/\n+/)
      arr.each do |i|
        i.strip!
      end
      ingredient_list.push arr.reject { |i| i.length == 0}
    end

    ingredients_sub_headings = @@page.css('.recipe-ingredients__sub-heading')
    combine_ingredients_and_sub_headings(ingredient_list, ingredients_sub_headings)
  end

  def method
    method_steps = @@page.css('.recipe-method__list p')
    method = []
    method_steps.each do |step|
      method.push(step.text.strip)
    end
    method
  end

  def tips
    tips = @@page.css('.recipe-tips__text').text.strip.gsub(/\s+/, ' ')
  end

  def add_to_object(obj, key, value)
    obj[key] = value 
  end

  def recipe(url)
    @@page = Scrape::get_page(url)
    recipe = {}
    add_to_object(recipe, 'title', title)
    add_to_object(recipe, 'meta_data', meta_data)
    add_to_object(recipe, 'chef_name', chef_name)
    add_to_object(recipe, 'programme_name', programme_name)
    add_to_object(recipe, 'description', description)
    add_to_object(recipe, 'ingredients', ingredients)
    add_to_object(recipe, 'method', method)
    add_to_object(recipe, 'tips', tips)

    recipe
  end

end