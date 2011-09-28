class ChangeReferredByIdToInt < ActiveRecord::Migration
  def self.up
    rename_column :sweepstake_entries, :referred_by_id, :referred_by_id_string
    add_column :sweepstake_entries, :referred_by_id, :integer
    execute("UPDATE sweepstake_entries SET referred_by_id = referred_by_id_string")
    execute("UPDATE sweepstake_entries SET referred_by_id = NULL WHERE referred_by_id <= 0")
    remove_column :sweepstake_entries, :referred_by_id_string
  end

  def self.down
    rename_column :sweepstake_entries, :referred_by_id, :referred_by_id_int
    add_column :sweepstake_entries, :referred_by_id, :string
    execute("UPDATE sweepstake_entries SET referred_by_id = referred_by_id_int")
    remove_column :sweepstake_entries, :referred_by_id_int
  end
end
