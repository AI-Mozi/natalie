require_relative '../spec_helper'
require_relative '../../spec/core/io/fixtures/classes'

# Upstream pull request: https://github.com/ruby/spec/pull/1077
describe "IO#autoclose" do
  before :each do
    @io = IOSpecs.io_fixture "lines.txt"
  end

  after :each do
    @io.autoclose = true unless @io.closed?
    @io.close unless @io.closed?
  end

  it "can be set to true" do
    @io.autoclose = true
    @io.should.autoclose?
  end

  it "can be set to false" do
    @io.autoclose = false
    @io.should_not.autoclose?
  end

  it "can be set to any truthy value" do
    @io.autoclose = 42
    @io.should.autoclose?
  end

  it "can be set multple times" do
    @io.autoclose = true
    @io.should.autoclose?

    @io.autoclose = false
    @io.should_not.autoclose?

    @io.autoclose = true
    @io.should.autoclose?
  end

  it "cannot be queried on a closed IO object" do
    @io.close
    -> { @io.autoclose? }.should raise_error(IOError, /closed stream/)
  end

  it "cannot be set on a closed IO object" do
    @io.close
    -> { @io.autoclose = false }.should raise_error(IOError, /closed stream/)
  end
end

describe "IO#gets" do
  it "sets $_ to nil afthe the last line has been read" do
    File.open(__dir__ + '/../../spec/core/io/fixtures/lines.txt') do |f|
      while line = f.gets
        $_.should == line
      end
      $_.should be_nil
    end
  end
end
