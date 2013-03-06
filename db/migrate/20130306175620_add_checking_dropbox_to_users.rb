class AddCheckingDropboxToUsers < ActiveRecord::Migration
  def change
    add_column :users, :checking_dropbox, :integer
  end
end
