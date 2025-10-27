class CreateUrls < ActiveRecord::Migration[7.1]
  def change
    create_table :urls do |t|
      t.string :origin_url

      t.timestamps
    end

    add_index :urls, :origin_url, unique: true
  end
end
