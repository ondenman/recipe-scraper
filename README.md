#BBC Recipe Scraper

I set myself the task of writing a scraper.

I chose to scrape recipes from [BBC Food](http://www.bbc.co.uk/food/). The site has been in the [news](http://www.bbc.co.uk/news/uk-36308976) recently and I thought it would be a good place to practice as the BBC has well structured pages.

The idea was to scrape a list of URLs before scraping the recipes from each URL in turn and storing them in a JSON file.

I began the project in Javascript. I intended to write it using synchronous functions. However, that was easier said then done. After getting lost in a tangle of promises and generator functions I decided that I was using the wrong tool for the job. 

I chose to continue using Ruby. Although I hadn't used the language for some time, I took a look at some source code and felt that I was familiar enough with it to be comfortable.