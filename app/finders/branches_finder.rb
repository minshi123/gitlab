# frozen_string_literal: true

class BranchesFinder < GitRefsFinder
  def initialize(repository, params = {})
    super(repository, params)
  end

  def execute
    branches = repository.branches_sorted_by(sort)
    branches = by_search(branches)
    branches = by_names(branches)
    branches
  end

  def with_gitaly_pagination
    if names || search
      execute
    else
      repository.branches_sorted_by(sort, pagination_params)
    end
  end

  private

  def names
    @params[:names].presence
  end

  def per_page
    @params[:per_page].presence
  end

  def page_token
    @params[:page_token].presence
  end

  def branch_ref
    Gitlab::Git::BRANCH_REF_PREFIX + page_token if page_token
  end

  def pagination_params
    { limit: per_page, page_token: branch_ref }
  end

  def by_names(branches)
    return branches unless names

    branch_names = names.to_set
    branches.select do |branch|
      branch_names.include?(branch.name)
    end
  end
end
