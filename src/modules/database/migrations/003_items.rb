Sequel.migration do
  up do
    create_table(:items) do
      primary_key :id
      foreign_key :player_id, :players
      foreign_key :item_definition_id, :item_definitions
      Integer :quantity, default: 1
    end
  end

  down do
    drop_table(:items)
  end
end
