# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::JUnitFormatter do
  subject(:formatter) { described_class.new(output) }

  let(:output) { StringIO.new }

  describe '#file_finished' do
    before do
      cop = RuboCop::Cop::Layout::SpaceInsideBlockBraces.new
      source_buffer = Parser::Source::Buffer.new('test', 1)
      source_buffer.source = %w[foo bar baz].join("\n")

      cop.add_offense(
        nil,
        location: Parser::Source::Range.new(source_buffer, 0, 1),
        message: 'message 1'
      )
      cop.add_offense(
        nil,
        location: Parser::Source::Range.new(source_buffer, 9, 10),
        message: 'message 2'
      )

      formatter.file_finished('test_1', cop.offenses)
      formatter.file_finished('test_2', cop.offenses)

      formatter.finished(nil)
    end

    it 'displays start of parsable text' do
      expect(output.string).to start_with(<<~XML)
        <?xml version='1.0'?>
        <testsuites>
          <testsuite name='rubocop'>
      XML
    end

    it 'displays end of parsable text' do
      expect(output.string).to end_with(<<~XML.chop)
          </testsuite>
        </testsuites>
      XML
    end

    it "displays an offfense for `classname='test_1` in parsable text" do
      expect(output.string).to include(<<-XML)
    <testcase classname='test_1' name='Layout/SpaceInsideBlockBraces'>
      <failure type='Layout/SpaceInsideBlockBraces' message='message 1'>
        test:1:1
      </failure>
      <failure type='Layout/SpaceInsideBlockBraces' message='message 2'>
        test:3:2
      </failure>
    </testcase>
      XML
    end

    it "displays an offfense for `classname='test_2` in parsable text" do
      expect(output.string).to include(<<-XML)
    <testcase classname='test_2' name='Layout/SpaceInsideBlockBraces'>
      <failure type='Layout/SpaceInsideBlockBraces' message='message 1'>
        test:1:1
      </failure>
      <failure type='Layout/SpaceInsideBlockBraces' message='message 2'>
        test:3:2
      </failure>
    </testcase>
      XML
    end

    it 'displays a non-offfense element in parsable text' do
      expect(output.string).to include(<<~XML)
        <testcase classname='test_1' name='Style/Alias'/>
      XML
    end
  end
end
