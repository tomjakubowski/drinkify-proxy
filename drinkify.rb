require 'sinatra/base'
require 'json'
require 'nokogiri'
require 'uri'
require 'open-uri'

class DrinkifyProxy < Sinatra::Base
  helpers do
    def drinkify_url(artist="")
      "http://drinkify.org/#{URI.escape(artist)}"
    end

    def drinkify(raw_artist)
      doc = Nokogiri::HTML(open(drinkify_url(raw_artist)))
      artist = doc.css('.drinkListing p').first.content.match(/listen to (.*) alone/)[1]

      {
        artist: artist,
        drink: (artist[0,3].downcase == "the" ? artist : "The #{artist}"),
        recipe: doc.css('.recipe > li').map { |i| i.content },
        instructions: doc.css('.instructions').first.content.gsub(/\s+/, ' ').strip
      }
    end
  end

  get "/" do
    redirect to(drinkify_url)
  end

  get "/:artist.json" do

    headers \
      "Content-Type" => "application/json",
      "Access-Control-Allow-Origin" => "*"
    drinkify(params[:artist]).to_json
  end

  get "/:artist" do
    redirect to(drinkify_url(params[:artist])), 301
  end
end
