defmodule TeiserverWeb.Microblog.BlogLive.Show do
  @moduledoc false
  use TeiserverWeb, :live_view
  alias Teiserver.Microblog
  import TeiserverWeb.MicroblogComponents
  alias Phoenix.PubSub

  @impl true
  def mount(%{"post_id" => post_id_str}, _session, socket) do
    :ok = PubSub.subscribe(Teiserver.PubSub, "microblog_posts")

    post = Microblog.get_post!(post_id_str, preload: [:poster, :tags])

    {:ok,
      socket
      |> assign(:post, post)
      |> assign(:site_menu_active, "microblog")
    }
  end

  @impl true
  def handle_info(%{channel: "microblog_posts", event: :post_created}, socket) do
    {:noreply, socket}
  end

  def handle_info(
    %{channel: "microblog_posts", event: :post_updated, post: new_post},
    %{assigns: %{post: post}} = socket
  ) do

    socket = if post.id == new_post.id do
      socket |> assign(:post, new_post)
    else
      socket
    end

    {:noreply, socket}
  end

  def handle_info(
    %{channel: "microblog_posts", event: :post_deleted, post_id: post_id},
    %{assigns: %{post: post}} = socket
  ) do
    if post_id == post.id do
      {:noreply, socket
        |> redirect(to: ~p"/microblog")
      }
    else
      {:noreply, socket}
    end
  end

  def handle_info(%{channel: "microblog_posts"}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete-post", _, %{assigns: assigns} = socket) do
    if allow?(assigns.current_user, "Moderator") do
      Microblog.delete_post(assigns.post)

      {:noreply, socket
        |> redirect(to: ~p"/microblog")
      }
    else
      {:noreply, socket}
    end
  end
end
