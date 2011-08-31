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
       ["A recipe has no soul.  You, as the cook, must bring soul to the recipe.", "Thomas Keller"],
       ["The only time to eat diet food is while you're waiting for the steak to cook.", "Julia Child"],
       ["If you're afraid of butter, use cream.", "Julia Child"],
       ["Everything in moderation... including moderation", "Julia Child"],
       ["Once, during Prohibition, I was forced to live for days on nothing but food and water.", "W.C. Fields"],
       ["Food is our common ground, a universal experience.", "James Beard"],
       ["I cook with wine, sometimes I even add it to the food.", "W.C. Fields"],
       ["The food here is terrible, and the portions are too small." "Woody Allen"],
       ["I never worry about diets. The only carrots that interest me are the number you get in a diamond.", "Mae West"],
       ["One cannot think well, love well, sleep well, if one has not dined well.", "Virginia Woolf"],
       ["Can't Talk ... Eating", "Homer Simpson"],
       ["YOU DON'T WIN FRIENDS WITH SALAD!", "Bart Simpson"],
       ["A nickel will get you on the subway, but garlic will get you a seat.", "Author Unknown"],
       ["I hate people who are not serious about their meals.", "Oscar Wilde"],
       ["I come from a family where gravy is considered a beverage.", "Erma Bombeck"],
       ["My weaknesses have always been food and men - in that order.", "Dolly Parton"],
       ["You better cut the pizza in four pieces because I'm not hungry enough to eat six.", "Yogi Berra"],
       ["There is no love sincerer than the love of food.", "George Bernard Shaw"],
       ["Leave the gun. Take the cannoli.", "The Godfather"],
       ["Desserts are like mistresses. They are bad for you. So if you are having one, you might as well have two.", "Alain Ducasse"]
      ].each do |quote|
        @quotes << Quote.new(quote[0], quote[1])
      end
    end
    @quotes
  end
end