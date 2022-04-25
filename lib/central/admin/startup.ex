defmodule Central.Admin.Startup do
  @moduledoc false
  use CentralWeb, :startup

  def startup do
    add_site_config_type(%{
      key: "user.Enable one time links",
      section: "User permissions",
      type: "boolean",
      permissions: ["teiserver.admin"],
      description: "Allows users to login with one-time-links.",
      opts: [],
      default: false,

      value_label: "Allow users to login via a one time link generated by the application."
    })

    add_site_config_type(%{
      key: "user.Enable renames",
      section: "User permissions",
      type: "boolean",
      permissions: ["teiserver.admin"],
      description: "Users are able to change their name via the account page.",
      opts: [],
      default: true,

      value_label: "Allow users to change their name"
    })

    add_site_config_type(%{
      key: "user.Enable account group pages",
      section: "User permissions",
      type: "boolean",
      permissions: ["teiserver.admin"],
      description: "Users are able to view (and edit) their group memberships.",
      opts: [],
      default: true,

      value_label: "Enable account group pages"
    })

    add_site_config_type(%{
      key: "user.Enable user registrations",
      section: "User permissions",
      type: "select",
      permissions: ["teiserver.admin"],
      description: "Users are able to view (and edit) their group memberships.",
      opts: [choices: ["Allowed", "Link only", "Disabled"]],
      default: "Allowed",

      value_label: "Enable account group pages"
    })

    add_site_config_type(%{
      key: "site.Main site link",
      section: "Site management",
      type: "string",
      permissions: ["teiserver.admin"],
      description: "A link to an external site if this is not your main site.",
      opts: [],
      default: "",

      value_label: "Link"
    })

    Central.cache_put(:application_metadata_cache, :node_startup_datetime, Timex.now())
  end
end
