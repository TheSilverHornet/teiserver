defmodule TeiserverWeb.Account.RelationshipsView do
  use TeiserverWeb, :view

  def colours(), do: StylingHelper.colours(:info)
  def icon(), do: StylingHelper.icon(:info)
end
