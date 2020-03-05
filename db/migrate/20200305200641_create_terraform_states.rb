class CreateTerraformStates < ActiveRecord::Migration[6.0]
  def change
    create_table :terraform_states do |t|
      t.string :file
      t.references :project, index: true, foreign_key: { on_delete: :cascade }, null: false
      t.timestamps
    end
  end
end
