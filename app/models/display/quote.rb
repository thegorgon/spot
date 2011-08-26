class Quote < Struct.new(:text, :byline)  
  def self.random
    quotes.random
  end
  
  def self.quotes
    unless @quotes
      @quotes = []
      [["Tell me what you eat and I will tell you who you are.", "Jean Anthelme Brillat-Savarin"],
       ["The belly rules the mind.", "Spanish Proverb"],
       ["Worries go down better with soup.", "Jewish Proverb"],
       ["I eat merely to put food out of my mind.", "N.F. Simpson"],
       ["After dinner sit a while, and after supper walk a mile.", "English Saying"],
       ["He was a very valiant man who first adventured on eating oysters.", "James I"],
       ["In general, mankind, since the improvement in cookery, eats twice as much as nature requires.", "Benjamin Franklin"],
       ["A recipe has no soul.  You, as the cook, must bring soul to the recipe.", "Thomas Keller"]
      ].each do |quote|
        @quotes << Quote.new(quote[0], quote[1])
      end
    end
    @quotes
  end
end