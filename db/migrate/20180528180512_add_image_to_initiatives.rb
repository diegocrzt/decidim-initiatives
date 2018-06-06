class AddImageToInitiatives < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_initiatives, :image, :string
  end
end
