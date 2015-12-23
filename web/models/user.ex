defmodule Vchat.User do
  use Vchat.Web, :model

  # use Comeonin for password encryption 
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  before_insert :generate_activation_token

  schema "users" do
    field :name, :string
    field :username, :string
    field :email, :string
    field :password_digest, :string
    field :activation_token, :string
    field :activated_at, Ecto.DateTime

    #virtual fields
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps
  end

  @required_fields ~w(name username email password password_confirmation)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset_for_signup(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> common_validations
    |> validate_confirmation(:password)
    |> validate_length(:password, min: 6)
    |> validate_length(:password_confirmation, min: 6)
    |> hash_password
  end  

  def changeset_for_activation(model, params \\ :empty) do
    model
    |> cast(params, [])
    |> put_change(:activation_token, nil)
    |> put_change(:activated_at,  Ecto.DateTime.utc)
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> common_validations
  end  

  defp common_validations(changeset) do
    changeset
    |> validate_length(:username, min: 2)
    |> validate_length(:name, min: 2)
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
  end



  defp hash_password(changeset) do
    if password = get_change(changeset, :password) do
      # if password is changed. Then set password_digest using comeonin
      changeset
        |> put_change(:password_digest, hashpwsalt(password))
      
    # dont do anything if password is not changed
    else
      changeset
    end
  end

  defp generate_activation_token(changeset) do
    length = 32
    random_string = :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
    changeset = put_change(changeset, :activation_token, random_string)
  end
end
