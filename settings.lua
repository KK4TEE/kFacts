data:extend({
    {
      type = "bool-setting",
      name = "kFacts_player_enabled",
      setting_type = "runtime-per-user",
      default_value = false,
      order = "a"
    },
    {
      type = "bool-setting",
      name = "kFacts_server_enabled",
      setting_type = "runtime-global",
      default_value = false,
      order = "c"
    },
    {
      type = "int-setting",
      name = "kFacts_player_scan_interval_ticks",
      setting_type = "runtime-global",
      default_value = 30,
      minimum_value = 1,
      maximum_value = 3600,
      order = "d"
    },
    {
        type = "int-setting",
        name = "kFacts_train_update_interval_ticks",
        setting_type = "runtime-global",
        default_value = 120,
        minimum_value = 1,
        maximum_value = 216000,
        order = "e"
      },
      {
        type = "int-setting",
        name = "kFacts_turret_update_interval_ticks",
        setting_type = "runtime-global",
        default_value = 120,
        minimum_value = 1,
        maximum_value = 216000,
        order = "f"
      },
      {
        type = "int-setting",
        name = "kFacts_max_characters_per_tick",
        setting_type = "runtime-global",
        default_value = 10000,
        minimum_value = 1000,
        maximum_value = 1000000,
        order = "g"
      },
      {
        type = "int-setting",
        name = "kFacts_write_file_interval",
        setting_type = "runtime-global",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 600,
        order = "h"
      },
      {
        type = "bool-setting",
        name = "kFacts_screenshots_enabled",
        setting_type = "runtime-global",
        default_value = false,
        order = "i"
      },
      {
        type = "int-setting",
        name = "kFacts_screenshot_interval_seconds",
        setting_type = "runtime-global",
        default_value = 600,
        minimum_value = 1,
        maximum_value = 1440,
        order = "j",
    },
    {
      type = "int-setting",
      name = "kFacts_screenshot_tiles",
      setting_type = "runtime-global",
      default_value = 4096,
      minimum_value = 1,
      maximum_value = 100000,
      order = "k"
    },
    {
      type = "int-setting",
      name = "kFacts_screenshot_resolution_x",
      setting_type = "runtime-global",
      default_value = 4096,
      minimum_value = 1,
      maximum_value = 8192,
      order = "l"
    },
    {
      type = "int-setting",
      name = "kFacts_screenshot_resolution_y",
      setting_type = "runtime-global",
      default_value = 4096,
      minimum_value = 1,
      maximum_value = 8192,
      order = "m"
    },
    {
      type = "bool-setting",
      name = "kFacts_in_game_debug_text",
      setting_type = "runtime-global",
      default_value = false,
      order = "n"
    }
})
  