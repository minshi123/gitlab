# frozen_string_literal: true

module SnippetRepositoryHelpers
  def generate_unnamed_snippet_file_actions(count = 2)
    count.times do |i|
      {
        file_path: '',
        content: i.to_s,
        action: :create
      }
    end
  end

  def generate_unnamed_snippet_filenames(count = 10, offset = 0)
    count.times do |i|
      file_index = offset + i
      "#{SnippetRepository::DEFAULT_EMPTY_FILE_NAME}#{file_index}.txt"
    end
  end
end
