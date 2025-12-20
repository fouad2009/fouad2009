# plugins/prestation_manager/db/migrate/20251212_create_prestataires.rb
class CreatePrestataires < ActiveRecord::Migration[6.1]
  def change
    create_table :prestataires do |t|
      t.string :nom
      t.string :identifiant
      t.string :nif
      t.string :etat
      t.string :wilaya
      t.string :contact

      t.timestamps
    end
  end
end

