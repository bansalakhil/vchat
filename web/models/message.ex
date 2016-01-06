defmodule Vchat.Message do
  use Vchat.Web, :model

  alias Vchat.User

  schema "messages" do
    # field :from_id, :integer
    field :body, :string
    field :info, :string

    timestamps

    belongs_to :sender, User, foreign_key: :from_id
    has_many :message_assignments, Vchat.MessageAssignment
  end

  @required_fields ~w(from_id body )
  @optional_fields ~w(info)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
