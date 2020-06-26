defmodule Godello.Kanban.Positioning do
  @moduledoc """
  The Kanban context.
  """

  import Ecto.Query, warn: false
  alias Godello.Repo
  alias Godello.Kanban.{List, Card}

  #
  # List
  #

  def list_positions(board_id) do
    positions =
      from(item in List,
        select: %{"id" => item.id, "position" => item.position},
        where: item.board_id == ^board_id,
        order_by: [asc: item.position]
      )
      |> Repo.all()

    %{
      "board" => %{
        "id" => board_id,
        "lists" => positions
      }
    }
  end

  def recalculate_list_positions(board_id, list_id, starting_position) do
    from(s in Card,
      where:
        s.position >= ^starting_position and
          s.id != ^list_id and s.board_id == ^board_id
    )
    |> Repo.update_all(inc: [position: 1])
  end

  def recalculate_list_positions_after_update(board_id, list_id, previous_position, new_position)
      when new_position > previous_position do
    from(s in Card,
      where:
        s.position <= ^new_position and s.position > ^previous_position and
          s.id != ^list_id and s.board_id == ^board_id
    )
    |> Repo.update_all(inc: [position: -1])
  end

  def recalculate_list_positions_after_update(board_id, list_id, previous_position, new_position)
      when new_position < previous_position do
    from(s in Card,
      where:
        s.position >= ^new_position and s.position < ^previous_position and
          s.id != ^list_id and s.board_id == ^board_id
    )
    |> Repo.update_all(inc: [position: 1])
  end

  def recalculate_list_positions_after_delete(board_id, previous_position) do
    from(s in Card,
      where: s.position > ^previous_position and s.board_id == ^board_id
    )
    |> Repo.update_all(inc: [position: -1])
  end

  #
  # Card
  #

  def card_positions(list_id) do
    positions =
      from(item in Card,
        select: %{"id" => item.id, "position" => item.position},
        where: item.list_id == ^list_id,
        order_by: [asc: item.position]
      )
      |> Repo.all()

    %{
      "list" => %{
        "id" => list_id,
        "cards" => positions
      }
    }
  end

  def recalculate_card_positions(list_id, card_id, starting_position) do
    from(s in Card,
      where:
        s.position >= ^starting_position and
          s.id != ^card_id and s.list_id == ^list_id
    )
    |> Repo.update_all(inc: [position: 1])
  end

  def recalculate_card_positions_after_update(list_id, card_id, previous_position, new_position)
      when new_position > previous_position do
    from(s in Card,
      where:
        s.position <= ^new_position and s.position > ^previous_position and
          s.id != ^card_id and s.list_id == ^list_id
    )
    |> Repo.update_all(inc: [position: -1])
  end

  def recalculate_card_positions_after_update(list_id, card_id, previous_position, new_position)
      when new_position < previous_position do
    from(s in Card,
      where:
        s.position >= ^new_position and s.position < ^previous_position and
          s.id != ^card_id and s.list_id == ^list_id
    )
    |> Repo.update_all(inc: [position: 1])
  end

  def recalculate_card_positions_after_delete(list_id, previous_position) do
    from(s in Card,
      where: s.position > ^previous_position and s.list_id == ^list_id
    )
    |> Repo.update_all(inc: [position: -1])
  end
end