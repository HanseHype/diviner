# encoding: utf-8
require 'helper'

class TestDiviner < Test::Unit::TestCase
  should "find simple testcase" do
    Product = Struct.new :id, :name, :description, :categories
    keys = [:name, :description, :categories]
    weights = {categories: 3, name: 2, description: 1}
    model = Product.new(1,  "Weleda Calendula Massageöl, 100 ml",
                            "Das Calendula Massageöl für zarte und empfindliche Haut von Weleda
                                      gibt belebende, wohlig wärmende Impulse. Das hochwertige Hautfunktionsöl
                                      ist durch schonend hergestellte Ölauszüge von beruhigenden Ringelblumen- und
                                      Kamillenblüten sowie Birkenblättern auch für empfindliche Haut gut geeignet.
                                      Auf der Basis von reinem Sonnenblumenöl unterstützt es die natürliche Hautfunktion
                                      wie z.B. das gesunde Fett-Feuchtigkeitsgleichgewicht der Haut.
                                      für glatte und geschmeidige Haut  aufgrund hervorragender Gleitfähigkeit besonders
                                      gut für Massagen  dezent-frischer Citrusduft  belebt die Sinne und verbreitet gute
                                      Laune  für empfindliche und zarte Haut",
                         "Drogerie / Körperpflege / Creme, Lotion & Öl / Öl")
    matcher = Deviner::Match.new(weights)
    matcher.model(model, keys)
    assert_equal "Massageöle", matcher.match(MyTestCategory.categories).name
  end

  should "find more complex testcase" do
    Product = Struct.new :id, :name, :description, :categories
    keys = [:name, :description, :categories]
    weights = {categories: 3, name: 2, description: 1}
    model = Product.new(1,  "HiPP Gemüserisotto mit zarter Bio-Pute, 250 g",
                            "HiPP Gemüserisotto mit zarter Bio-Pute enthält schonend dampfgegarte Zutaten mit kindgerechter Würzung und Omega-3 Fettsäuren aus Bio-Rapsöl. Die Mahlzeit ist geeignet für eine sichere und ausgewogene Ernährung Ihres Babys ab dem12. Monat.      mit Stückchenfürs Kauenlernen  salzreduziert  glutenfrei  ohne Zusatz von Aromen, Konservierungsstoffen, Farbstoffen, Verdickungsmitteln",
                         "Baby & Kind Babynahrung Kindernahrung Beikost")
    matcher = Deviner::Match.new(weights)
    matcher.model(model, keys)
    assert_equal "Babynahrung", matcher.match(MyTestCategory.categories).name
  end


end
