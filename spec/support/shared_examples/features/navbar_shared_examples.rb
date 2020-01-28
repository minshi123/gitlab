# frozen_string_literal: true

RSpec.shared_context 'verify navbar structure' do
  let(:structure) { [] }

  it 'renders correctly' do
    current_structure = page.find_all('.sidebar-top-level-items > li', class: ['!hidden']).each_with_object([]) do |item, array|
      nav_item = item.find_all('a').first.text.gsub(/\s+\d+$/, '') # remove counts at the end

      nav_sub_items = item.find_all('.sidebar-sub-level-items a').map do |link|
        link.text
      end
      nav_sub_items.shift # remove the first hidden item

      array << { nav_item: nav_item, nav_sub_items: nav_sub_items }
    end

    expect(current_structure).to eq(structure)
  end
end
