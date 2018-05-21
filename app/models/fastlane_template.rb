class FastlaneTemplate < ApplicationRecord

  has_many :environments
  validates_uniqueness_of :command, scope: :platform

  def api_data
    {
        id: id,
        name: name,
        created_at: I18n.l(created_at),
        platform: platform,
        command: command
    }
  end

end
