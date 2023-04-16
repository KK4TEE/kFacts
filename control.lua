local json = require("json")

local function get_player_information()
    local timestamp = game.tick
    local data = {}

  for _, player in pairs(game.connected_players) do
    local position = player.position
    local color = player.color
    local health = player.character and player.character.health or "N/A"
    local in_combat = player.character and player.character.in_combat or false

    data[player.name] = {
      position = {x = position.x, y = position.y},
      color = {r = color.r, g = color.g, b = color.b, a = color.a},
      health = health,
      in_combat = in_combat
    }
  end
  return {timestamp = timestamp, data = data}
end

local function get_train_information()
  local timestamp = game.tick
  local data = {
    locomotives = {},
    cargo_wagons = {},
    signals = {}
  }

  for _, surface in pairs(game.surfaces) do
    local locomotives = surface.find_entities_filtered({type = "locomotive"})
    for _, locomotive in pairs(locomotives) do
      local defaultColor = locomotive.prototype.color
      local position = locomotive.position
      local color = locomotive.color or defaultColor
      data.locomotives[#data.locomotives + 1] = {
        color = color,
        name = locomotive.name,
        position = {x = position.x, y = position.y}
      }
    end
    
    local cargo_wagons = surface.find_entities_filtered({type = "cargo-wagon"})
    for _, wagon in pairs(cargo_wagons) do
      local position = wagon.position
      local inventory = wagon.get_inventory(defines.inventory.cargo_wagon)
      local contents = inventory.get_contents()
      data.cargo_wagons[#data.cargo_wagons + 1] = {
        position = {x = position.x, y = position.y},
        contents = contents
      }
    end

    -- local rail_signals = surface.find_entities_filtered({type = {"rail-signal", "rail-chain-signal"}})
    local data = {signals = {}}
    
  end
  return {timestamp = timestamp, data = data}
end

local function get_turret_information()
  local timestamp = game.tick
  local data = {}

  for _, surface in pairs(game.surfaces) do
    local turrets = surface.find_entities_filtered({type = "ammo-turret"})
    for _, turret in pairs(turrets) do
      local position = turret.position
      local health = turret.health
      local firing = false
      
      if turret.shooting_target ~= nil then
        -- game.print("factARy: Turret has a target!") -- makes a notice sound!
        firing = true
      end
      
      data[#data + 1] = {
        position = {x = position.x, y = position.y},
        health = health,
        firing = firing
      }
    end
  end
  return {timestamp = timestamp, data = data}
end


local function file_write_handler()
  if not global.json_data_buffer or not global.current_character then
      return
  end

  local subdir = "kFacts" -- Add a subdirectory
  local filename = subdir .. "/kFacts.json" -- Modify the filename to include the subdirectory
  local max_characters_per_tick = settings.global["kFacts_max_characters_per_tick"].value
  local total_characters = #global.json_data_buffer

  local characters_to_write = math.min(max_characters_per_tick, total_characters - global.current_character + 1)
  local data_chunk = string.sub(global.json_data_buffer, global.current_character, global.current_character + characters_to_write - 1)

  local function write_file_with_newline(player_index)
      game.write_file(filename, data_chunk, true, player_index)
      if global.current_character + characters_to_write > total_characters then
          game.write_file(filename, "\n", true, player_index)
      end
  end

  -- Write file for the server
  local success, err = pcall(function()
      write_file_with_newline(0)
  end)

  if not success then
      for _, player in pairs(game.connected_players) do
          player.print("Error writing file for the server: " .. err)
      end
  else
      -- Debug output for the server
      if settings.global["kFacts_in_game_debug_text"].value then
        for _, player in pairs(game.connected_players) do
            player.print("Save for the server: " .. filename .. " ### total_characters: " .. total_characters .. " ### Data: " .. data_chunk)
        end
      end
  end

  -- Write file for each player with kFacts_player_enabled setting
  for _, player in pairs(game.connected_players) do
      if player.mod_settings["kFacts_player_enabled"].value then
          local success, err = pcall(function()
              write_file_with_newline(player.index)
          end)

          if not success then
              player.print("Error writing file for the player: " .. err)
          else
              -- Debug output for the player
              if settings.global["kFacts_in_game_debug_text"].value then
                if player.index ~= 0 then -- Add this condition
                    player.print("Save for the player: " .. filename .. " ### total_characters: " .. total_characters .. " ### Data: " .. data_chunk)
                end
              end
          end
      end
  end

  global.current_character = global.current_character + characters_to_write

  if global.current_character > total_characters then
      global.json_data_buffer = nil
      global.current_character = nil
  end
end

  
local function save_information_to_file(data)
    if global.json_data_buffer and global.current_character then
        return  -- Skip update if previous write is still in progress
    end

    local json_data = json.encode(data)
    global.json_data_buffer = json_data
    global.current_character = 1
end


local function take_screenshot()
  local subdir = "kFacts"
  local filename = subdir .. "/minimap.png"
  local resolution = {
    x = settings.global["kFacts_screenshot_resolution_x"].value,
    y = settings.global["kFacts_screenshot_resolution_y"].value
  }
  local numTiles = settings.global["kFacts_screenshot_tiles"].value

  local totalTilesWidth = numTiles
  local totalTilesHeight = numTiles

  local zoom_x = resolution.x / (totalTilesWidth * 32)
  local zoom_y = resolution.y / (totalTilesHeight * 32)
  local zoom = math.min(zoom_x, zoom_y)

  -- Ensure zoom is within the allowed range
  if zoom < 0.03125 then
    zoom = 0.03125
  end

  local screenshot_settings = {
    position = {x = 0, y = 0},
    resolution = resolution,
    zoom = zoom,
    show_entity_info = false,
    anti_alias = false,
    path = filename,
    daytime = 1,
    surface = "nauvis"
  }

  game.take_screenshot(screenshot_settings)
  for _, player in pairs(game.connected_players) do
    player.print("Screenshot taken and saved as: " .. filename .. " Zoom level is " .. zoom)
  end
end


local function get_map_information()
  local timestamp = game.tick
  local resolution = {
    settings.global["kFacts_screenshot_resolution_x"].value,
    settings.global["kFacts_screenshot_resolution_y"].value
  }

  local numTiles = settings.global["kFacts_screenshot_tiles"].value
  local data = {
    resolution = resolution,
    numTiles = numTiles,
    nextScreenshotTick = game.tick + (60 * settings.global["kFacts_screenshot_interval_seconds"].value)
  }

  
  return {timestamp = timestamp, data = data}
end


global.modState = {
  writeState = "idle",
  entities = {},
  scanState = "player",
  playerTickCount = 0,
  trainTickCount = 0,
  turretTickCount = 0,
  screenshotTickCount = 0 
}


local function initialize_mod_state()
  global.modState = {
    writeState = "idle",
    entities = {},
    scanState = "player",
    playerTickCount = 0,
    trainTickCount = 0,
    turretTickCount = 0,
    screenshotTickCount = 0 
  }
end


-- Initialize modState on game start or when the mod is added to an existing save
script.on_init(function()
  global.json_data_buffer = ""
  global.current_character = 1
  if global.ticks_since_last_screenshot == nil then
      global.ticks_since_last_screenshot = 0
  end
  initialize_mod_state()
end)


-- Initialize modState when configuration changes (mod updates, other mod changes, etc.)
script.on_configuration_changed(function()
  if not global.modState then
    initialize_mod_state()
  end
end)


script.on_event(defines.events.on_tick, function(event)
  -- Update variables
  global.ticks_since_last_screenshot = global.ticks_since_last_screenshot or 0

  -- Call file_write_handler every tick
  file_write_handler()

  local game_information = {}

  
  global.modState.playerTickCount = global.modState.playerTickCount + 1
  global.modState.trainTickCount = global.modState.trainTickCount + 1
  global.modState.turretTickCount = global.modState.turretTickCount + 1
  global.modState.screenshotTickCount = global.modState.screenshotTickCount + 1

  if global.modState.writeState == "idle" then
    if global.modState.scanState == "player" then
      local player_scan_interval_ticks = settings.global["kFacts_player_scan_interval_ticks"].value
      if global.modState.playerTickCount >= player_scan_interval_ticks then
        game_information.player_information = get_player_information()
        global.modState.entities = game_information
        global.modState.writeState = "writing"
        global.modState.playerTickCount = 0
      end
      global.modState.scanState = "train"

    elseif global.modState.scanState == "train" then
      local train_update_interval_ticks = settings.global["kFacts_train_update_interval_ticks"].value
      if global.modState.trainTickCount >= train_update_interval_ticks then
        game_information.train_information = get_train_information()
        global.modState.entities = game_information
        global.modState.writeState = "writing"
        global.modState.trainTickCount = 0
      end
      global.modState.scanState = "turret"

    elseif global.modState.scanState == "turret" then
      local turret_update_interval_ticks = settings.global["kFacts_turret_update_interval_ticks"].value
      if global.modState.turretTickCount >= turret_update_interval_ticks then
        game_information.turret_information = get_turret_information()
        global.modState.entities = game_information
        global.modState.writeState = "writing"
        global.modState.turretTickCount = 0
      end
      global.modState.scanState = "ScreenshotPrep"

    elseif global.modState.scanState == "ScreenshotPrep" then
      local screenshot_interval_ticks = 60 * settings.global["kFacts_screenshot_interval_seconds"].value
      if global.modState.screenshotTickCount >= screenshot_interval_ticks then
        for _, player in pairs(game.connected_players) do
          player.print("Updating the map image. Brace for lag...")
        end
        global.modState.scanState = "ScreenshotCapture"
      else
        global.modState.scanState = "player"
      end

    elseif global.modState.scanState == "ScreenshotCapture" then
      local screenshot_interval_ticks = 60 * settings.global["kFacts_screenshot_interval_seconds"].value
      if global.modState.screenshotTickCount >= screenshot_interval_ticks then
        game.speed = 0.01 -- Slowest speed a multiplayer game can go
        take_screenshot()
        game.speed = 1
        game_information.map_information = get_map_information()
        global.modState.entities = game_information
        global.modState.writeState = "writing"
        global.modState.screenshotTickCount = 0
      end
      global.modState.scanState = "player"
    end

  elseif global.modState.writeState == "writing" then
    save_information_to_file(global.modState.entities)
    global.modState.writeState = "idle"
  end
end)
  