# frozen_string_literal: true

require 'fast_spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'
require_relative '../../../../rubocop/cop/gitlab/docs_linter'

RSpec.describe RuboCop::Cop::Gitlab::DocsLinter, type: :rubocop do
  include CopHelper

  subject(:cop) { described_class.new }

  context 'help_page_path' do
    it 'does not add an offense for existing help page path' do
      expect_no_offenses(<<~PATTERN)
      link_to _('More information'), help_page_path('topics/autodevops/index.md'), target: '_blank'
      PATTERN
    end

    it 'adds an offense for missing help page path' do
      expect_offense(<<~PATTERN)
      link_to _('More information'), help_page_path('topics/autodevops/missing.page'), target: '_blank'
      ^^^^^^^ help_page_path points to incorrect path
      PATTERN
    end
  end
end
