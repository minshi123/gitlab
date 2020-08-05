# frozen_string_literal: true

# TODO description
class ContentRewriterService
  REWRITERS = [Gitlab::Gfm::ReferenceRewriter, Gitlab::Gfm::UploadsRewriter].freeze

  def initialize(current_user, content, source_parent, target_parent)
    @current_user = current_user
    @content = content.presence
    @source_parent = source_parent
    @target_parent = target_parent
  end

  def execute
    return unless content

    REWRITERS.inject(content) do |text, klass|
      rewriter = klass.new(text, source_parent, current_user)
      rewriter.rewrite(target_parent)
    end
  end

  private

  attr_reader :current_user, :content, :source_parent, :target_parent
end
