describe :string_concat, shared: true do
  it "concatenates the given argument to self and returns self" do
    str = 'hello '
    str.send(@method, 'world').should equal(str)
    str.should == "hello world"
  end

  it "raises a FrozenError when self is frozen" do
    a = "hello"
    a.freeze

    -> { a.send(@method, "")     }.should raise_error(FrozenError)
    -> { a.send(@method, "test") }.should raise_error(FrozenError)
  end

  it "returns a String when given a subclass instance" do
    a = "hello"
    a.send(@method, StringSpecs::MyString.new(" world"))
    a.should == "hello world"
    a.should be_an_instance_of(String)
  end

  it "returns an instance of same class when called on a subclass" do
    str = StringSpecs::MyString.new("hello")
    str.send(@method, " world")
    str.should == "hello world"
    str.should be_an_instance_of(StringSpecs::MyString)
  end

  describe "with Integer" do
    it "concatenates the argument interpreted as a codepoint" do
      b = "".send(@method, 33)
      b.should == "!"

      NATFIXME 'Implement String#encode!', exception: NoMethodError, message: "undefined method `encode!'" do
        b.encode!(Encoding::UTF_8)
        b.send(@method, 0x203D)
        b.should == "!\u203D"
      end
    end

    # #5855
    it "returns a BINARY string if self is US-ASCII and the argument is between 128-255 (inclusive)" do
      NATFIXME 'out of range', exception: RangeError, message: '128 out of char range' do
        a = ("".encode(Encoding::US_ASCII).send(@method, 128))
        a.encoding.should == Encoding::BINARY
        a.should == 128.chr

        a = ("".encode(Encoding::US_ASCII).send(@method, 255))
        a.encoding.should == Encoding::BINARY
        a.should == 255.chr
      end
    end

    it "raises RangeError if the argument is an invalid codepoint for self's encoding" do
      -> { "".encode(Encoding::US_ASCII).send(@method, 256) }.should raise_error(RangeError)
      -> { "".encode(Encoding::EUC_JP).send(@method, 0x81)  }.should raise_error(RangeError)
    end

    it "raises RangeError if the argument is negative" do
      -> { "".send(@method, -200)          }.should raise_error(RangeError)
      -> { "".send(@method, -bignum_value) }.should raise_error(RangeError)
    end

    it "doesn't call to_int on its argument" do
      x = mock('x')
      x.should_not_receive(:to_int)

      -> { "".send(@method, x) }.should raise_error(TypeError)
    end

    it "raises a FrozenError when self is frozen" do
      a = "hello"
      a.freeze

      -> { a.send(@method, 0)  }.should raise_error(FrozenError)
      -> { a.send(@method, 33) }.should raise_error(FrozenError)
    end
  end
end

describe :string_concat_encoding, shared: true do
  describe "when self is in an ASCII-incompatible encoding incompatible with the argument's encoding" do
    it "uses self's encoding if both are empty" do
      "".encode("UTF-16LE").send(@method, "").encoding.should == Encoding::UTF_16LE
    end

    it "uses self's encoding if the argument is empty" do
      "x".encode("UTF-16LE").send(@method, "").encoding.should == Encoding::UTF_16LE
    end

    it "uses the argument's encoding if self is empty" do
      NATFIXME "uses the argument's encoding if self is empty", exception: SpecFailedException do
        "".encode("UTF-16LE").send(@method, "x".encode("UTF-8")).encoding.should == Encoding::UTF_8
      end
    end

    it "raises Encoding::CompatibilityError if neither are empty" do
      NATFIXME 'Implement Encoding::CompatibilityError', exception: NameError, message: 'uninitialized constant Encoding::CompatibilityError' do
        -> { "x".encode("UTF-16LE").send(@method, "y".encode("UTF-8")) }.should raise_error(Encoding::CompatibilityError)
      end
    end
  end

  describe "when the argument is in an ASCII-incompatible encoding incompatible with self's encoding" do
    it "uses self's encoding if both are empty" do
      "".encode("UTF-8").send(@method, "".encode("UTF-16LE")).encoding.should == Encoding::UTF_8
    end

    it "uses self's encoding if the argument is empty" do
      "x".encode("UTF-8").send(@method, "".encode("UTF-16LE")).encoding.should == Encoding::UTF_8
    end

    it "uses the argument's encoding if self is empty" do
      NATFIXME "uses the argument's encoding if self is empty", exception: SpecFailedException do
        "".encode("UTF-8").send(@method, "x".encode("UTF-16LE")).encoding.should == Encoding::UTF_16LE
      end
    end

    it "raises Encoding::CompatibilityError if neither are empty" do
      NATFIXME 'Implement Encoding::CompatibilityError', exception: NameError, message: 'uninitialized constant Encoding::CompatibilityError' do
        -> { "x".encode("UTF-8").send(@method, "y".encode("UTF-16LE")) }.should raise_error(Encoding::CompatibilityError)
      end
    end
  end

  describe "when self and the argument are in different ASCII-compatible encodings" do
    # NATFIXME: Implement SHIFT_JIS
    xit "uses self's encoding if both are ASCII-only" do
      "abc".encode("UTF-8").send(@method, "123".encode("SHIFT_JIS")).encoding.should == Encoding::UTF_8
    end

    it "uses self's encoding if the argument is ASCII-only" do
      "\u00E9".encode("UTF-8").send(@method, "123".encode("ISO-8859-1")).encoding.should == Encoding::UTF_8
    end

    # NATFIXME: Implement high chars in ISO-8859-1
    xit "uses the argument's encoding if self is ASCII-only" do
      "abc".encode("UTF-8").send(@method, "\u00E9".encode("ISO-8859-1")).encoding.should == Encoding::ISO_8859_1
    end

    it "raises Encoding::CompatibilityError if neither are ASCII-only" do
      NATFIXME 'Implement Encoding::CompatibilityError', exception: NameError, message: 'uninitialized constant Encoding::CompatibilityError' do
        -> { "\u00E9".encode("UTF-8").send(@method, "\u00E9".encode("ISO-8859-1")) }.should raise_error(Encoding::CompatibilityError)
      end
    end
  end

  describe "when self is BINARY and argument is US-ASCII" do
    it "uses BINARY encoding" do
      "abc".encode("BINARY").send(@method, "123".encode("US-ASCII")).encoding.should == Encoding::BINARY
    end
  end
end

describe :string_concat_type_coercion, shared: true do
  it "converts the given argument to a String using to_str" do
    obj = mock('world!')
    obj.should_receive(:to_str).and_return("world!")
    a = 'hello '.send(@method, obj)
    a.should == 'hello world!'
  end

  it "raises a TypeError if the given argument can't be converted to a String" do
    -> { 'hello '.send(@method, [])        }.should raise_error(TypeError)
    -> { 'hello '.send(@method, mock('x')) }.should raise_error(TypeError)
  end

  it "raises a NoMethodError if the given argument raises a NoMethodError during type coercion to a String" do
    obj = mock('world!')
    obj.should_receive(:to_str).and_raise(NoMethodError)
    -> { 'hello '.send(@method, obj) }.should raise_error(NoMethodError)
  end
end
