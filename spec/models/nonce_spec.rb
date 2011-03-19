describe Nonce do
  describe "#friendly_token" do
    it "generates a string of 20 random numbers and characters" do
      Nonce.friendly_token.length.should == 20
      Nonce.friendly_token.should_not == Nonce.friendly_token # META! Sorta tests randomness?
      Nonce.friendly_token.should match /[a-z0-9]/i
    end
  end

  describe "#hex_token" do
    it "generates a random hex string" do
      Nonce.hex_token.should_not == Nonce.hex_token
      Nonce.hex_token.should match /[a-f0-9]+/i
    end
  end
  
  describe "#digest" do
    it "digests a string and returns a string" do
      Nonce.digest("a string").should be_kind_of(String)
    end
  end
  
  describe "#token" do
    it "generates and stores into session, if given a session without a token" do
      mock_session = {}
      @nonce = Nonce.new(:session => mock_session)
      mock_session[Nonce::SESSION_KEY].should == @nonce.token
    end

    it "generates if not given a session" do
      mock_session = {}
      @nonce = Nonce.new(:session => nil)
      @nonce.token.should_not be_nil
    end

    it "loads from session if it exists" do
      mock_session = { Nonce::SESSION_KEY => "abcdefghijklmnop" }
      @nonce = Nonce.new(:session => mock_session)
      @nonce.token.should == mock_session[Nonce::SESSION_KEY]
    end
    
    it "does not regenerate a token once it has generated one" do
      @nonce = Nonce.new
      first = @nonce.token
      @nonce.generate!
      second = @nonce.token
      second.should == first
    end
    
    it "can be initialized to a value" do
      token = "abcdefghijklmnop"
      @nonce = Nonce.new(:token => token, :session => {})
      @nonce.token.should == token
    end

    it "stores the initialized value into session if given a session" do
      mock_session = {}
      token = "abcdefghijklmnop"
      @nonce = Nonce.new(:token => token, :session => mock_session)
      mock_session[Nonce::SESSION_KEY].should == token
    end
  end
  
  describe "#clear" do
    it "removes the token from the session if given a session" do
      mock_session = {}
      token = "abcdefghijklmnop"
      @nonce = Nonce.new(:token => token, :session => mock_session)
      mock_session[Nonce::SESSION_KEY].should == token
      @nonce.clear
      mock_session[Nonce::SESSION_KEY].should be_nil
    end

    it "resets the token value" do
      @nonce = Nonce.new
      expect { @nonce.clear }.to change(@nonce, :token)
    end
  end
  
  describe "#digested" do
    it "returns the digested token" do
      @nonce = Nonce.new
      @nonce.digested.should == Nonce.digest(@nonce.token)
    end
  end
end