# encoding: utf-8
module Deviner
  class Match
    require 'rubygems'
    require 'lingua/stemmer'
    require 'picky'

    def initialize(weight=nil, options={})
      @weights=weight
      self.options.merge(options)
    end


    def constrains key
      if @weights.present?
        return {weight: Picky::Weights::Constant.new(@weights[key].to_i)}
      else
        return {weight: Weights::Constant.new()}
      end
    end

    def options
      {language: 'de',
       query_method: :name,
       parent_method: :category,
       stopwords: /\b(aber|alle|allem|allen|aller|alles|als|also|am|an|ander|andere|anderem|anderen|anderer|anderes|anderm|andern|anderr|anders|auch|auf|aus|bei|bin|bis|bist|da|damit|dann|der|den|des|dem|die|das|daß|dass|derselbe|derselben|denselben|desselben|demselben|dieselbe|dieselben|dasselbe|dazu|dein|deine|deinem|deinen|deiner|deines|denn|derer|dessen|dich|dir|du|dies|diese|diesem|diesen|dieser|dieses|doch|dort|durch|ein|eine|einem|einen|einer|eines|einig|einige|einigem|einigen|einiger|einiges|einmal|er|ihn|ihm|es|etwas|euer|eure|eurem|euren|eurer|eures|für|gegen|gewesen|hab|habe|haben|hat|hatte|hatten|hier|hin|hinter|ich|mich|mir|ihr|ihre|ihrem|ihren|ihrer|ihres|euch|im|in|indem|ins|ist|jede|jedem|jeden|jeder|jedes|jene|jenem|jenen|jener|jenes|jetzt|kann|kein|keine|keinem|keinen|keiner|keines|können|könnte|machen|man|manche|manchem|manchen|mancher|manches|mein|meine|meinem|meinen|meiner|meines|mit|muss|musste|nach|nicht|nichts|noch|nun|nur|ob|oder|ohne|sehr|sein|seine|seinem|seinen|seiner|seines|selbst|sich|sie|ihnen|sind|so|solche|solchem|solchen|solcher|solches|soll|sollte|sondern|sonst|über|um|und|uns|unse|unsem|unsen|unser|unses|unter|viel|vom|von|vor|während|war|waren|warst|was|weg|weil|weiter|welche|welchem|welchen|welcher|welches|wenn|werde|werden|wie|wieder|will|wir|wird|wirst|wo|wollen|wollte|würde|würden|zu|zum|zur|zwar|zwischen)\b/i,
       minimal_token_size: 2,
       split_text_on: /[\s\/\-\_\:\"\&\/]/,
       has_parent: true}
    end

    def index(model, keys)
      myoptions = options
      myconstrains = proc {|e| constrains(e) }
      index = Picky::Index.new :model do
        indexing stems_with: Lingua::Stemmer.new(language: myoptions[:language]),
                 substitutes_characters_with: Picky::CharacterSubstituters::WestEuropean.new,
                 stopwords: myoptions[:stopwords],
                 splits_text_on: myoptions[:split_text_on],
                 rejects_token_if: lambda { |token| token.size < myoptions[:minimal_token_size] }

        for key in keys
          category key, myconstrains.call(key)
        end
      end
      index.add model
      index
    end

    def model(model, keys)
      @index = index(model, keys)
      @keys = keys
      clear_cache
    end


    # Return nil if no matches found
    def match(categories)
      result = []
      for category in categories
          score = score(category)
          result << {value: score,  category: category}
      end

      highest_value = result.map{|x| x[:value]}.sort.last
      selected_category = nil
      if highest_value > 0
        result.each do |hash|
          if hash[:value] == highest_value
            selected_category = hash[:category]
          end
        end
      end

      return selected_category

    end


    def cache
      @cache||={}
    end

    def clear_cache
      @cache={}
    end

    def score(category)
      return 0 if category == nil
      query = category.send(options[:query_method])
      query = prepare_query(query)
      return  cache[query] if cache[query] != nil
      search = Picky::Search.new @index
      subqueries = query.split(" ")
      total = 0
      for subquery in subqueries
        result = search.search(query)
        total+=result.total
      end
      if options[:has_parent]
        parent = category.send(options[:parent_method])
      else
        parent = nil
      end
      cache[query] = total + score(parent)
    end

    def prepare_query query
      query.gsub(",", " ").
            gsub("&", " ").
            gsub("ü", "ue").
            gsub("ö", "oe").
            gsub("ä", "ae").
            gsub("Ü", "Ue").
            gsub("Ö", "Oe").
            gsub("Ä", "Ae").
            gsub("  ", " ")
    end

  end
end
