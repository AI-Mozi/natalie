require_relative '../../spec_helper'
require_relative 'fixtures/classes'

describe "Kernel#open" do
  before :each do
    @name = tmp("kernel_open.txt")
    @content = "This is a test"
    touch(@name) { |f| f.write @content }
    @file = nil
  end

  after :each do
    @file.close if @file
    rm_r @name
  end

  it "is a private method" do
    NATFIXME 'is a private method', exception: SpecFailedException do
      Kernel.should have_private_instance_method(:open)
    end
  end

  it "opens a file when given a valid filename" do
    @file = open(@name)
    @file.should be_kind_of(File)
  end

  it "opens a file when called with a block" do
    NATFIXME 'opens a file when called with a block', exception: SpecFailedException do
      open(@name, "r") { |f| f.gets }.should == @content
    end
  end

  platform_is_not :windows, :wasi do
    it "opens an io when path starts with a pipe" do
      NATFIXME 'Pipes in open', exception: Errno::ENOENT, message: 'No such file or directory' do
        suppress_warning do # https://bugs.ruby-lang.org/issues/19630
          @io = open("|date")
        end
        begin
          @io.should be_kind_of(IO)
          @io.read
        ensure
          @io.close
        end
      end
    end

    it "opens an io when called with a block" do
      NATFIXME 'Pipes in open', exception: Errno::ENOENT, message: 'No such file or directory' do
        suppress_warning do # https://bugs.ruby-lang.org/issues/19630
          @output = open("|date") { |f| f.read }
        end
        @output.should_not == ''
      end
    end

    it "opens an io for writing" do
      NATFIXME 'Pipes in open', exception: SpecFailedException do
        suppress_warning do # https://bugs.ruby-lang.org/issues/19630
          -> {
            bytes = open("|cat", "w") { |io| io.write(".") }
            bytes.should == 1
          }.should output_to_fd(".")
        end
      end
    end
  end

  platform_is :windows do
    it "opens an io when path starts with a pipe" do
      suppress_warning do # https://bugs.ruby-lang.org/issues/19630
        @io = open("|date /t")
      end
      begin
        @io.should be_kind_of(IO)
        @io.read
      ensure
        @io.close
      end
    end

    it "opens an io when called with a block" do
      suppress_warning do # https://bugs.ruby-lang.org/issues/19630
        @output = open("|date /t") { |f| f.read }
      end
      @output.should_not == ''
    end
  end

  ruby_version_is "3.3" do
    # https://bugs.ruby-lang.org/issues/19630
    it "warns about deprecation given a path with a pipe" do
      cmd = "|echo ok"
      -> {
        open(cmd) { |f| f.read }
      }.should complain(/Kernel#open with a leading '\|'/)
    end
  end

  it "raises an ArgumentError if not passed one argument" do
    -> { open }.should raise_error(ArgumentError)
  end

  it "accepts options as keyword arguments" do
    @file = open(@name, "r", 0666, flags: File::CREAT)
    @file.should be_kind_of(File)

    -> {
      open(@name, "r", 0666, {flags: File::CREAT})
    }.should raise_error(ArgumentError, "wrong number of arguments (given 4, expected 1..3)")
  end

  describe "when given an object that responds to to_open" do
    before :each do
      ScratchPad.clear
    end

    it "calls #to_path to covert the argument to a String before calling #to_str" do
      obj = mock("open to_path")
      obj.should_receive(:to_path).at_least(1).times.and_return(@name)
      obj.should_not_receive(:to_str)

      NATFIXME 'calls #to_path to covert the argument to a String before calling #to_str', exception: SpecFailedException do
        open(obj, "r") { |f| f.gets }.should == @content
      end
    end

    it "calls #to_str to convert the argument to a String" do
      obj = mock("open to_str")
      obj.should_receive(:to_str).at_least(1).times.and_return(@name)

      NATFIXME 'calls #to_str to convert the argument to a String', exception: SpecFailedException do
        open(obj, "r") { |f| f.gets }.should == @content
      end
    end

    it "calls #to_open on argument" do
      NATFIXME 'Support #to_open', exception: TypeError, message: 'no implicit conversion of MockObject into String' do
        obj = mock('fileish')
        @file = File.open(@name)
        obj.should_receive(:to_open).and_return(@file)
        @file = open(obj)
        @file.should be_kind_of(File)
      end
    end

    it "returns the value from #to_open" do
      NATFIXME 'Support #to_open', exception: TypeError, message: 'no implicit conversion of MockObject into String' do
        obj = mock('to_open')
        obj.should_receive(:to_open).and_return(:value)

        open(obj).should == :value
      end
    end

    it "passes its arguments onto #to_open" do
      NATFIXME 'Support #to_open', exception: ArgumentError, message: 'wrong number of arguments (given 4, expected 1..3)' do
        obj = mock('to_open')
        obj.should_receive(:to_open).with(1, 2, 3)
        open(obj, 1, 2, 3)
      end
    end

    it "passes keyword arguments onto #to_open as keyword arguments if to_open accepts them" do
      NATFIXME 'Support #to_open', exception: ArgumentError, message: 'wrong number of arguments (given 4, expected 1..3)' do
        obj = Object.new
        def obj.to_open(*args, **kw)
          ScratchPad << {args: args, kw: kw}
        end

        ScratchPad.record []
        open(obj, 1, 2, 3, a: "b")
        ScratchPad.recorded.should == [args: [1, 2, 3], kw: {a: "b"}]
      end
    end

    it "passes the return value from #to_open to a block" do
      NATFIXME 'Support #to_open', exception: TypeError, message: 'no implicit conversion of MockObject into String' do
        obj = mock('to_open')
        obj.should_receive(:to_open).and_return(:value)

        open(obj) do |mock|
          ScratchPad.record(mock)
        end

        ScratchPad.recorded.should == :value
      end
    end
  end

  it "raises a TypeError if passed a non-String that does not respond to #to_open" do
    obj = mock('non-fileish')
    -> { open(obj) }.should raise_error(TypeError)
    -> { open(nil) }.should raise_error(TypeError)
    NATFIXME 'Should not support file descriptors', exception: SpecFailedException do
      -> { open(7)   }.should raise_error(TypeError)
      # NATFIXME: Just in case there is a file descriptor 7 open and the test becomes flakey, test a higher
      # fd as well.
      -> { open(9999)   }.should raise_error(TypeError)
    end
  end

  it "accepts nil for mode and permission" do
    NATFIXME 'accepts nil for mode and permission', exception: SpecFailedException do
      open(@name, nil, nil) { |f| f.gets }.should == @content
    end
  end

  it "is not redefined by open-uri" do
    code = <<~RUBY
      before = Kernel.instance_method(:open)
      require 'open-uri'
      after = Kernel.instance_method(:open)
      p before == after
    RUBY
    NATFIXME 'Add open-uri', exception: SpecFailedException do
      ruby_exe(code, args: "2>&1").should == "true\n"
    end
  end
end

describe "Kernel.open" do
  it "needs to be reviewed for spec completeness"
end