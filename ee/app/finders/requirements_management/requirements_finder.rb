# frozen_string_literal: true

module RequirementsManagement
  class RequirementsFinder
    include Gitlab::Utils::StrongMemoize

    # Params:
    # project_id: integer
    # iids: integer[]
    # state: string[]
    # sort: string
    # search: string
    # author_username: string
    def initialize(current_user, params = {})
      @current_user = current_user
      @params = params
    end

    def execute
      items = init_collection
      items = by_state(items)
      items = by_iid(items)
      items = by_author(items)
      items = by_search(items)

      sort(items)
    end

    private

    attr_reader :current_user, :params

    def init_collection
      return RequirementsManagement::Requirement.none unless Ability.allowed?(current_user, :read_requirement, project)

      project.requirements
    end

    def by_iid(items)
      return items unless params[:iids].present?

      items.for_iid(params[:iids])
    end

    def by_state(items)
      return items unless params[:state].present?

      items.for_state(params[:state])
    end

    def by_author(items)
      username_param = params[:author_username]

      if username_param
        author = User.find_by_username(username_param)
        return items.none unless author # author not found

        items.with_author(author.id)
      else
        items
      end
    end

    def by_search(items)
      if params[:search].present?
        items.with_title_like(params[:search])
      else
        items
      end
    end

    def project
      strong_memoize(:project) do
        ::Project.find_by_id(params[:project_id]) if params[:project_id].present?
      end
    end

    def sort(items)
      sorts = RequirementsManagement::Requirement.simple_sorts.keys
      sort = sorts.include?(params[:sort]) ? params[:sort] : 'id_desc'

      items.order_by(sort)
    end
  end
end
