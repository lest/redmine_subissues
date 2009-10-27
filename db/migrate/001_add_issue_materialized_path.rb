class AddIssueMaterializedPath < ActiveRecord::Migration
  def self.up
    add_column :issues, :parent_id, :integer
    add_column :issues, :materialized_path, :string
    add_index :issues, :materialized_path
  end

  def self.down
    remove_column :issues, :parent_id
    remove_column :issues, :materialized_path
    remove_index :issues, :materialized_path
  end
end
