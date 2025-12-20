# plugins/prestation_manager/app/models/prestataire.rb
class Prestataire < ActiveRecord::Base
  # validations simples
  validates :nom, presence: true
end

