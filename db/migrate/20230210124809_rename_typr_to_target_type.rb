class RenameTyprToTargetType < ActiveRecord::Migration[6.0]
  def change
    rename_column :xref_client_mappings, :type, :target_type
  end
end
