# frozen_string_literal: true

require 'fast_spec_helper'
require_relative '../../../support/helpers/expect_offense'
require_relative '../../../../rubocop/cop/performance/readlines_each'

describe RuboCop::Cop::Performance::ReadlinesEach do
  include CopHelper
  include ExpectOffense

  subject(:cop) { described_class.new }

  shared_examples_for(:class_read) do |klass|
    context "and it is called as a class method on #{klass}" do
      it 'flags it as an offense' do
        inspect_source "#{klass}.readlines(file_path).each { |line| puts line }"

        expect(cop.offenses).not_to be_empty
      end
    end

    context 'when just using readlines without each' do
      it 'does not flag it as an offence' do
        inspect_source "contents = #{klass}.readlines(file_path)"

        expect(cop.offenses).to be_empty
      end
    end
  end

  context 'when reading all lines using IO.readlines.each' do
    %w(IO File).each do |klass|
      it_behaves_like(:class_read, klass)
    end

    context 'and it is called as an instance method on a return value' do
      it 'flags it as an offense' do
        inspect_source <<~SOURCE
          get_file.readlines.each { |line| puts line }
        SOURCE

        expect(cop.offenses).not_to be_empty
      end
    end

    context 'and it is called as an instance method on an lvar' do
      it 'flags it as an offense' do
        inspect_source <<~SOURCE
          file = File.new(path)
          file.readlines.each { |line| puts line }
        SOURCE

        expect(cop.offenses).not_to be_empty
      end
    end

    context 'and it is called as an instance method on a new object' do
      it 'flags it as an offense' do
        inspect_source <<~SOURCE
          File.new(path).readlines.each { |line| puts line }
        SOURCE

        expect(cop.offenses).not_to be_empty
      end
    end
  end

  context 'when just using readlines without each' do
    it 'does not flag it as an offence' do
      inspect_source "contents = my_file.readlines"

      expect(cop.offenses).to be_empty
    end
  end
end
