# -*- encoding: utf-8 -*-
require_relative '../../spec_helper'
require_relative 'fixtures/classes'
require_relative 'shared/gets_ascii'

describe "IO#gets" do
  it_behaves_like :io_gets_ascii, :gets
end

describe "IO#gets" do
  before :each do
    @io = IOSpecs.io_fixture "lines.txt"
    @count = 0
  end

  after :each do
    @io.close if @io
  end

  it "assigns the returned line to $_" do
    IOSpecs.lines.each do |line|
      @io.gets
      $_.should == line
    end
  end

  it "returns nil if called at the end of the stream" do
    IOSpecs.lines.length.times { @io.gets }
    @io.gets.should == nil
  end

  it "raises IOError on closed stream" do
    -> { IOSpecs.closed_io.gets }.should raise_error(IOError)
  end

  describe "with no separator" do
    it "returns the next line of string that is separated by $/" do
      IOSpecs.lines.each { |line| line.should == @io.gets }
    end

    it "updates lineno with each invocation" do
      while @io.gets
        @io.lineno.should == @count += 1
      end
    end

    it "updates $. with each invocation" do
      while @io.gets
        $..should == @count += 1
      end
    end
  end

  describe "with nil separator" do
    it "returns the entire contents" do
      NATFIXME 'Support separator argument', exception: ArgumentError, message: 'wrong number of arguments (given 1, expected 0)' do
        @io.gets(nil).should == IOSpecs.lines.join("")
      end
    end

    it "updates lineno with each invocation" do
      NATFIXME 'Support separator argument', exception: ArgumentError, message: 'wrong number of arguments (given 1, expected 0)' do
        while @io.gets(nil)
          @io.lineno.should == @count += 1
        end
      end
    end

    it "updates $. with each invocation" do
      NATFIXME 'Support separator argument', exception: ArgumentError, message: 'wrong number of arguments (given 1, expected 0)' do
        while @io.gets(nil)
          $..should == @count += 1
        end
      end
    end
  end

  describe "with an empty String separator" do
    # Two successive newlines in the input separate paragraphs.
    # When there are more than two successive newlines, only two are kept.
    it "returns the next paragraph" do
      NATFIXME 'Support separator argument', exception: ArgumentError, message: 'wrong number of arguments (given 1, expected 0)' do
        @io.gets("").should == IOSpecs.lines[0,3].join("")
        @io.gets("").should == IOSpecs.lines[4,3].join("")
        @io.gets("").should == IOSpecs.lines[7,2].join("")
      end
    end

    it "reads until the beginning of the next paragraph" do
      # There are three newlines between the first and second paragraph
      NATFIXME 'Support separator argument', exception: ArgumentError, message: 'wrong number of arguments (given 1, expected 0)' do
        @io.gets("")
        @io.gets.should == IOSpecs.lines[4]
      end
    end

    it "updates lineno with each invocation" do
      NATFIXME 'Support separator argument', exception: ArgumentError, message: 'wrong number of arguments (given 1, expected 0)' do
        while @io.gets("")
          @io.lineno.should == @count += 1
        end
      end
    end

    it "updates $. with each invocation" do
      NATFIXME 'Support separator argument', exception: ArgumentError, message: 'wrong number of arguments (given 1, expected 0)' do
        while @io.gets("")
          $..should == @count += 1
        end
      end
    end
  end

  describe "with an arbitrary String separator" do
    it "reads up to and including the separator" do
      NATFIXME 'Support separator argument', exception: ArgumentError, message: 'wrong number of arguments (given 1, expected 0)' do
        @io.gets("la linea").should == "Voici la ligne une.\nQui \303\250 la linea"
      end
    end

    it "updates lineno with each invocation" do
    NATFIXME 'Support separator argument', exception: ArgumentError, message: 'wrong number of arguments (given 1, expected 0)' do
        while (@io.gets("la"))
          @io.lineno.should == @count += 1
        end
      end
    end

    it "updates $. with each invocation" do
    NATFIXME 'Support separator argument', exception: ArgumentError, message: 'wrong number of arguments (given 1, expected 0)' do
        while @io.gets("la")
          $..should == @count += 1
        end
      end
    end

    describe "that consists of multiple bytes" do
      platform_is_not :windows do
        it "should match the separator even if the buffer is filled over successive reads" do
          IO.pipe do |read, write|

            # Write part of the string with the separator split between two write calls. We want
            # the read to intertwine such that when the read starts the full data isn't yet
            # available in the buffer.
            write.write("Aquí está la línea tres\r\n")

            NATFIXME 'Threads', exception: NameError, message: 'uninitialized constant Thread' do
              t = Thread.new do
                # Continue reading until the separator is encountered or the pipe is closed.
                read.gets("\r\n\r\n")
              end

              # Write the other half of the separator, which should cause the `gets` call to now
              # match. Explicitly close the pipe for good measure so a bug in `gets` doesn't block forever.
              Thread.pass until t.stop?

              write.write("\r\nelse\r\n\r\n")
              write.close

              t.value.bytes.should == "Aquí está la línea tres\r\n\r\n".bytes
              read.read(8).bytes.should == "else\r\n\r\n".bytes
            end
          end
        end
      end
    end
  end

  describe "when passed chomp" do
    it "returns the first line without a trailing newline character" do
      @io.gets(chomp: true).should == IOSpecs.lines_without_newline_characters[0]
    end

    it "raises exception when options passed as Hash" do
      NATFIXME 'Support arguments', exception: SpecFailedException do
        -> { @io.gets({ chomp: true }) }.should raise_error(TypeError)
      end

      NATFIXME 'Support arguments', exception: SpecFailedException do
        -> {
          @io.gets("\n", 1, { chomp: true })
        }.should raise_error(ArgumentError, "wrong number of arguments (given 3, expected 0..2)")
      end
    end
  end
end

describe "IO#gets" do
  before :each do
    @name = tmp("io_gets")
  end

  after :each do
    rm_r @name
  end

  it "raises an IOError if the stream is opened for append only" do
    NATFIXME 'Check read mode', exception: SpecFailedException do
      -> { File.open(@name, "a:utf-8") { |f| f.gets } }.should raise_error(IOError)
    end
  end

  it "raises an IOError if the stream is opened for writing only" do
    NATFIXME 'Check read mode', exception: SpecFailedException do
      -> { File.open(@name, "w:utf-8") { |f| f.gets } }.should raise_error(IOError)
    end
  end
end

describe "IO#gets" do
  before :each do
    @name = tmp("io_gets")
    touch(@name) { |f| f.write "one\n\ntwo\n\nthree\nfour\n" }
    @io = new_io @name, "r:utf-8"
  end

  after :each do
    @io.close if @io
    rm_r @name
  end

  it "calls #to_int to convert a single object argument to an Integer limit" do
    NATFIXME 'Support limit argument', exception: ArgumentError, message: 'wrong number of arguments (given 1, expected 0)' do
      obj = mock("io gets limit")
      obj.should_receive(:to_int).and_return(6)

      @io.gets(obj).should == "one\n"
    end
  end

  it "calls #to_int to convert the second object argument to an Integer limit" do
    NATFIXME 'Support separator and limit arguments', exception: ArgumentError, message: 'wrong number of arguments (given 2, expected 0)' do
      obj = mock("io gets limit")
      obj.should_receive(:to_int).and_return(2)

      @io.gets(nil, obj).should == "on"
    end
  end

  it "calls #to_str to convert the first argument to a String when passed a limit" do
    NATFIXME 'Support separator and limit arguments', exception: ArgumentError, message: 'wrong number of arguments (given 2, expected 0)' do
      obj = mock("io gets separator")
      obj.should_receive(:to_str).and_return($/)

      @io.gets(obj, 5).should == "one\n"
    end
  end

  it "reads to the default separator when passed a single argument greater than the number of bytes to the separator" do
    NATFIXME 'Support limit argument', exception: ArgumentError, message: 'wrong number of arguments (given 1, expected 0)' do
      @io.gets(6).should == "one\n"
    end
  end

  it "reads limit bytes when passed a single argument less than the number of bytes to the default separator" do
    NATFIXME 'Support limit argument', exception: ArgumentError, message: 'wrong number of arguments (given 1, expected 0)' do
      @io.gets(3).should == "one"
    end
  end

  it "reads limit bytes when passed nil and a limit" do
    NATFIXME 'Support separator and limit arguments', exception: ArgumentError, message: 'wrong number of arguments (given 2, expected 0)' do
      @io.gets(nil, 6).should == "one\n\nt"
    end
  end

  it "reads all bytes when the limit is higher than the available bytes" do
    NATFIXME 'Support separator and limit arguments', exception: ArgumentError, message: 'wrong number of arguments (given 2, expected 0)' do
      @io.gets(nil, 100).should == "one\n\ntwo\n\nthree\nfour\n"
    end
  end

  it "reads until the next paragraph when passed '' and a limit greater than the next paragraph" do
    NATFIXME 'Support separator and limit arguments', exception: ArgumentError, message: 'wrong number of arguments (given 2, expected 0)' do
      @io.gets("", 6).should == "one\n\n"
    end
  end

  it "reads limit bytes when passed '' and a limit less than the next paragraph" do
    NATFIXME 'Support separator and limit arguments', exception: ArgumentError, message: 'wrong number of arguments (given 2, expected 0)' do
      @io.gets("", 3).should == "one"
    end
  end

  it "reads all bytes when pass a separator and reading more than all bytes" do
    NATFIXME 'Support separator and limit arguments', exception: ArgumentError, message: 'wrong number of arguments (given 2, expected 0)' do
      @io.gets("\t", 100).should == "one\n\ntwo\n\nthree\nfour\n"
    end
  end

  it "returns empty string when 0 passed as a limit" do
    NATFIXME 'Support limit argument', exception: ArgumentError, message: 'wrong number of arguments (given 1, expected 0)' do
      @io.gets(0).should == ""
      @io.gets(nil, 0).should == ""
      @io.gets("", 0).should == ""
    end
  end

  it "does not accept limit that doesn't fit in a C off_t" do
    NATFIXME 'Support limit argument', exception: SpecFailedException do
      -> { @io.gets(2**128) }.should raise_error(RangeError)
    end
  end
end

describe "IO#gets" do
  before :each do
    @name = tmp("io_gets")
    # create data "朝日" + "\xE3\x81" * 100 to avoid utf-8 conflicts
    data = "朝日" + ([227,129].pack('C*') * 100).force_encoding('utf-8')
    touch(@name) { |f| f.write data }
    @io = new_io @name, "r:utf-8"
  end

  after :each do
    @io.close if @io
    rm_r @name
  end

  it "reads limit bytes and extra bytes when limit is reached not at character boundary" do
    NATFIXME 'Support limit argument', exception: ArgumentError, message: 'wrong number of arguments (given 1, expected 0)' do
      [@io.gets(1), @io.gets(1)].should == ["朝", "日"]
    end
  end

  it "read limit bytes and extra bytes with maximum of 16" do
    # create str "朝日\xE3" + "\x81\xE3" * 8 to avoid utf-8 conflicts
    str = "朝日" + ([227] + [129,227] * 8).pack('C*').force_encoding('utf-8')
    NATFIXME 'Support limit argument', exception: ArgumentError, message: 'wrong number of arguments (given 1, expected 0)' do
      @io.gets(7).should == str
    end
  end
end

describe "IO#gets" do
  before :each do
    @external = Encoding.default_external
    @internal = Encoding.default_internal

    Encoding.default_external = Encoding::UTF_8
    Encoding.default_internal = nil

    @name = tmp("io_gets")
    touch(@name) { |f| f.write "line" }
  end

  after :each do
    @io.close if @io
    rm_r @name
    Encoding.default_external = @external
    Encoding.default_internal = @internal
  end

  it "uses the default external encoding" do
    @io = new_io @name, 'r'
    NATFIXME 'Transcoding', exception: NoMethodError, message: "undefined method `encoding' for nil:NilClass" do
      @io.gets.encoding.should == Encoding::UTF_8
    end
  end

  it "uses the IO object's external encoding, when set" do
    @io = new_io @name, 'r'
    @io.set_encoding Encoding::US_ASCII
    NATFIXME 'Transcoding', exception: NoMethodError, message: "undefined method `encoding' for nil:NilClass" do
      @io.gets.encoding.should == Encoding::US_ASCII
    end
  end

  it "transcodes into the default internal encoding" do
    Encoding.default_internal = Encoding::US_ASCII
    @io = new_io @name, 'r'
    NATFIXME 'Transcoding', exception: NoMethodError, message: "undefined method `encoding' for nil:NilClass" do
      @io.gets.encoding.should == Encoding::US_ASCII
    end
  end

  it "transcodes into the IO object's internal encoding, when set" do
    Encoding.default_internal = Encoding::US_ASCII
    @io = new_io @name, 'r'
    NATFIXME 'Add Encoding::UTF_16', exception: NameError, message: 'uninitialized constant Encoding::UTF_16' do
      @io.set_encoding Encoding::UTF_8, Encoding::UTF_16
      @io.gets.encoding.should == Encoding::UTF_16
    end
  end

  it "overwrites the default external encoding with the IO object's own external encoding" do
    Encoding.default_external = Encoding::BINARY
    Encoding.default_internal = Encoding::UTF_8
    @io = new_io @name, 'r'
    @io.set_encoding Encoding::IBM866
    NATFIXME 'Transcoding', exception: NoMethodError, message: "undefined method `encoding' for nil:NilClass" do
      @io.gets.encoding.should == Encoding::UTF_8
    end
  end

  it "ignores the internal encoding if the default external encoding is BINARY" do
    Encoding.default_external = Encoding::BINARY
    Encoding.default_internal = Encoding::UTF_8
    @io = new_io @name, 'r'
    NATFIXME 'Transcoding', exception: NoMethodError, message: "undefined method `encoding' for nil:NilClass" do
      @io.gets.encoding.should == Encoding::BINARY
    end
  end

  ruby_version_is ''...'3.3' do
    it "transcodes to internal encoding if the IO object's external encoding is BINARY" do
      Encoding.default_external = Encoding::BINARY
      Encoding.default_internal = Encoding::UTF_8
      @io = new_io @name, 'r'
      @io.set_encoding Encoding::BINARY, Encoding::UTF_8
      NATFIXME 'Transcoding', exception: NoMethodError, message: "undefined method `encoding' for nil:NilClass" do
        @io.gets.encoding.should == Encoding::UTF_8
      end
    end
  end

  ruby_version_is '3.3' do
    it "ignores the internal encoding if the IO object's external encoding is BINARY" do
      Encoding.default_external = Encoding::BINARY
      Encoding.default_internal = Encoding::UTF_8
      @io = new_io @name, 'r'
      @io.set_encoding Encoding::BINARY, Encoding::UTF_8
      @io.gets.encoding.should == Encoding::BINARY
    end
  end
end
