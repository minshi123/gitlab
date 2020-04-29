# frozen_string_literal: true

class SprintPresenter < Gitlab::View::Presenter::Delegated
  presents :sprint

  def sprint_path
    # url_builder.build(sprint, only_path: true)
  end
end
