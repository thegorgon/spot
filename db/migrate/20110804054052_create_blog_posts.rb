class CreateBlogPosts < ActiveRecord::Migration
  def self.up
    create_table :blog_posts do |t|
      t.string :tumblr_id, :null => false
      t.string :slug, :null => false
    end
    add_index :blog_posts, :slug, :unique => true
  end

  def self.down
    drop_table :blog_posts
  end
end
