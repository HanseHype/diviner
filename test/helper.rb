# encoding: utf-8
Encoding.default_external = Encoding::UTF_8

require 'simplecov'
require 'open-uri'
require 'net/http'

module SimpleCov::Configuration
  def clean_filters
    @filters = []
  end
end

SimpleCov.configure do
  clean_filters
  load_profile 'test_frameworks'
end

ENV["COVERAGE"] && SimpleCov.start do
  add_filter "/.rvm/"
end
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'


TestCategory = Struct.new :name, :category

def TestCategory.name
  self[:name]
end

def TestCategory.category
  self[:category]
end


firstline = true
stack = ["dummy"]
@categories = []

uri = URI("https://www.google.com/basepages/producttype/taxonomy.de-DE.txt")
taxonomies = Net::HTTP.get(uri).force_encoding("UTF-8")

taxonomies.each_line do |line|

  if firstline
    firstline = false
    next
  end

  names = line.split(" > ").map{|x| x.strip}

  if stack.length > names.length
    stack.pop
  end

  if stack.length == names.length
    stack.pop
  end

  parent = stack.last
  category = TestCategory.new(names.last,parent)
  stack.push(category)
  @categories << category
end


puts @categories

class MyTestCategory

  def self.categories=(categories)
    @categories = categories
  end

  def self.categories
    @categories
  end
end

MyTestCategory.categories= @categories

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'diviner'

class Test::Unit::TestCase
end
