defmodule Vchat.Repo.Migrations.AddLastActivityToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :last_activity_at, :datetime
    end
  end
end

