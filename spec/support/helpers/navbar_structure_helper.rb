# frozen_string_literal: true

module NavbarStructureHelper
  def add_nav_item(structure:, before_nav_item_name:, new_nav_item:)
    index = structure.find_index { |h| h[:nav_item] == before_nav_item_name }
    structure.insert(index + 1, new_nav_item)
  end

  def add_sub_nav_item(structure:, nav_item_name:, before_sub_nav_item_name:, new_sub_nav_item_name:)
    hash = structure.find { |h| h[:nav_item] == nav_item_name }
    index = hash[:nav_sub_items].find_index(before_sub_nav_item_name)
    hash[:nav_sub_items].insert(index + 1, new_sub_nav_item_name)
  end
end
