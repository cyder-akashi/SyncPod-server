class CreateVideos < ActiveRecord::Migration[5.1]
  def change
    create_table :video_lists do |t|
      t.references :room, null: false
      t.string :video_id, null: false
      t.time :movie_start_time, null: false

      t.timestamps
    end
    add_foreign_key :video_lists, :rooms
  end
end
