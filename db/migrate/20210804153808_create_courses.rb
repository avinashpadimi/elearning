class CreateCourses < ActiveRecord::Migration[6.0]
  def change
    create_table :courses do |t|
      t.string :name, unique: true
      t.boolean :self_assignable
      t.references :coach, null: false, foreign_key: true

      t.timestamps
    end
  end
end
