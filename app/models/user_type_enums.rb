# frozen_string_literal: true

module UserTypeEnums
  def self.types
    bots.merge(ghost: 5)
  end

  def self.bots
    {
      AlertBot: 2
    }
  end
end

UserTypeEnums.prepend_if_ee('EE::UserTypeEnums')
