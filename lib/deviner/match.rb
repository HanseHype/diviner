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
       has_parent: true}
    end

    def index(model, keys)
      myoptions = options
      myconstrains = proc {|e| constrains(e) }
      index = Picky::Index.new :model do
        indexing stems_with: Lingua::Stemmer.new(language: myoptions[:language]),
                 substitutes_characters_with: Picky::CharacterSubstituters::WestEuropean.new

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

    def match(categories)
      result = []
      for category in categories
          score = score(category)
          result << {value: score,  category: category}
      end

      highest_value = result.map{|x| x[:value]}.sort.last
      selected_category = nil
      result.each do |hash|
        if hash[:value] == highest_value
          selected_category = hash[:category]
        end
      end

      result = result.reject{ |x| x[:value] != highest_value}
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
