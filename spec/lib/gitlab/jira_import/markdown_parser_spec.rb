# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::JiraImport::MarkdownParser do
  describe '#execute' do

    def parse_markdown(text)
      described_class.new(text).execute
    end

    it 'parses basic text' do
      expect(parse_markdown('some text')).to eq('some text')
    end

    it 'parses text with multiple lines' do
      text = 'This is text\n\n\n\n with new lines'

      expect(parse_markdown(text)).to eq(text)
    end

    it 'ignores colors but parses the text' do
      text = 'Color - {color:#97a0af}Light Gray{color}'
      result = 'Color - Light Gray'

      expect(parse_markdown(text)).to eq(result)
    end

    it 'parsers the links' do
      text = 'internal link: [https://gitlab-jira.atlassian.net/browse/DEMO-1|https://gitlab-jira.atlassian.net/browse/DEMO-1|smart-link]
              some text
              external link: [External Link|https://gitlab.com/gitlab-org/gitlab/-/merge_requests/25718]
              [https://gitlab.com|https://gitlab.com]'
      result = 'internal link: [https://gitlab-jira.atlassian.net/browse/DEMO-1](https://gitlab-jira.atlassian.net/browse/DEMO-1)
              some text
              external link: [External Link](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/25718)
              [https://gitlab.com](https://gitlab.com)'

      expect(parse_markdown(text)).to eq(result)
    end

    it 'parses the quotes' do
      text = <<~MD
        text with quotes

        {quote}this is aquote{quote}

        and

        {quote}this is a
         multiline quote{quote}
      MD
      result = <<~MD
        text with quotes

        >>>
        this is aquote
        >>>

        and

        >>>
        this is a
         multiline quote
        >>>
      MD

      expect(parse_markdown(text)).to eq(result)
    end

    # TODO: handle the blank lines
    it 'ignores the panels' do
      text = <<~MD
        text with panels

        {panel:bgColor=#e3fcef}
        Success info panel
        {panel}

        {panel:bgColor=#deebff}
        Info info panel
        {panel}
      MD
      result = <<~MD
        text with panels

        Success info panel


        Info info panel

      MD

      expect(parse_markdown(text)).to eq(result)
    end

    # TODO: future iteration, how to handle it now?
    it 'ingorest the mentiones' do
      text = '[~accountid:5e32f803e127810e82875bc1] could you check it?'
      result = ''

      expect(parse_markdown(text)).to eq(result)
    end

    it 'parses the headers' do
      text = <<~MD
        h1. Header 1

        h2. Header 2

        h3. Header 3

        h4. Header 4

        h5. Header 5

        h6. Header 6
      MD
      result = <<~MD
        # Header 1

        ## Header 2

        ### Header 3

        #### Header 4

        ##### Header 5

        ###### Header 6
      MD

      expect(parse_markdown(text)).to eq(result)
    end

    it 'parses the lists' do
      text = <<~MD
        * Bullet point list item 1
        * Bullet point list Item 2

        # Number list Item 1
        # Number list item 2
      MD
      result = <<~MD
        * Bullet point list item 1
        * Bullet point list Item 2

        1. Number list Item 1
        1. Number list item 2
      MD

      expect(parse_markdown(text)).to eq(result)
    end

    it 'parses the code blocks' do
      text = <<~MD
        ruby code

        {code:ruby}function foo
          puts "hello"
        end{code}
      MD
      result = <<~MD
        ruby code

        ```ruby
        function foo
          puts "hello"
        end
        ```
      MD

      expect(parse_markdown(text)).to eq(result)
    end

    # TODO: this is not done yet
    it 'does not process tags inside code block' do
      text = <<~MD
        ruby code

        {code:ruby}function foo
          h1. this is header
          {quote}this is quote{quote}
        end{code}
      MD
      result = <<~MD
        ruby code

        ```ruby
        function foo
          h1. this is header
          {quote}this is quote{quote}
        end
        ````
      MD

      expect(parse_markdown(text)).to eq(result)
    end
  end
end