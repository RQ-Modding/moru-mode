-- Moru Mode. Does what TADA mode does in what TADA mode leaves alone, on its own switch, kept per
-- save. For now: the growth of Talent and Talent R equipment, rolled N times after each fight, and
-- three of the game's conditions on that growth that can each be turned off.
-- API reference: https://rq-modding.github.io/rq-modding-docs/reference/
--
-- The game (Ｔ戦闘後の取得経験値算出, after a fight won or ended with the actions run out) calls
-- Ｉ成長装備の処理(iic) once for each ally in the front party (PTA, 登録状態 1) that is not downed
-- (状態変化 3) and, in the first world, at most the quest's difficulty + 5 in level. Each call adds
-- RAND(30), RAND(10), RAND(3) or RAND(2) to a Talent effect (39) or a Talent R effect (81) of the
-- weapon and the armor, and gives the item a rank's stats each time the value passes a hundred. A
-- roll is at most 30, so a call passes at most one hundred: N calls give every rank its stats, where
-- one roll times N could jump two ranks for one rank's stats.

local GROW = "Ｉ成長装備の処理"
local RESULT = "Ｔ戦闘後の取得経験値算出"
local MIN, MAX, DEFAULT = 2, 100, 2
local DOWNED = 3                -- 状態変化: downed
local PARTY, RESERVE, USED = 1, 2, 3 -- 登録状態: in the party, the first army, switched out this quest
local SUPPORT_QUEST = 13        -- Alice's support menu
local DIFFICULTY_ROW = "Change difficulty"
local ROW_ID = 1301             -- our row in the support menu; the game's are 1, 2, 3, 4, 9 and 99
local ALICE = 2080              -- Alice's face, as the support menu's セリフ(2080, "")

local settings

local function on()
  return rq.game.mode() ~= nil and settings.get("on") == true
end

local function rolls()
  return settings.get("talent")
end

-- What the last fight did, for the log and the Lab.
local last = nil

-- The game's own calls: N - 1 more after each. A call made from this callback does not fire the hook
-- again (rq.ain.hook), and `adding` keeps the mod's own calls below from being multiplied twice.
local adding = false
rq.ain.hook(GROW, { after = function(h)
  if adding or not on() then return end
  local iic = h.args[1]
  for _ = 2, rolls() do rq.ain.call(GROW, iic) end
  if last then last.game[#last.game + 1] = iic end
end })

local function level(iic) return rq.ain.call("ＣＬＶ", iic, -1) end
local function status(iic) return rq.ain.call("Ｃ状態変化", iic, -1) end

-- The characters the game leaves out that the switches let in, read before the game's loop (the
-- reserve's levels rise later in the same function).
local extra = nil
local function left_out()
  local world = rq.ain.global("◆ワールド")
  local limit = 99
  local difficulty = rq.ain.call("Ｑ難易度", rq.ain.global("◆iiq"), -1)
  if difficulty ~= 0 then limit = difficulty + 5 end
  local fallen, any_level, reserve = settings.get("fallen"), settings.get("level"), settings.get("reserve")
  local function level_ok(iic) return world >= 2 or level(iic) <= limit end
  local out = {}
  for loop = 1, 5 do
    local iic = rq.ain.global("PTA", loop)
    if iic ~= 0 and rq.party.state(iic) == PARTY then
      local down = status(iic) == DOWNED
      local game_grows = not down and level_ok(iic)
      if not game_grows and (fallen or not down) and (any_level or level_ok(iic)) then
        out[#out + 1] = { iic = iic, why = down and "fallen" or "level" }
      end
    end
  end
  if reserve then
    for _, state in ipairs({ RESERVE, USED }) do
      for _, m in ipairs(rq.party.roster(state)) do
        local down = m.status == DOWNED
        if (fallen or not down) and (any_level or level_ok(m.iic)) then
          out[#out + 1] = { iic = m.iic, why = "reserve" }
        end
      end
    end
  end
  return out
end

rq.ain.hook(RESULT, {
  before = function()
    extra = nil
    last = nil
    if not on() then return end
    last = { rolls = rolls(), game = {}, extra = {} }
    extra = left_out()
  end,
  after = function()
    if not extra then return end
    local n = rolls()
    adding = true
    local ok, err = pcall(function()
      for _, e in ipairs(extra) do
        for _ = 1, n do rq.ain.call(GROW, e.iic) end
        last.extra[#last.extra + 1] = e
      end
    end)
    adding = false
    extra = nil
    if not ok then rq.log("Moru Mode: " .. tostring(err)) end
    rq.log(string.format("Moru Mode: Talent rolled %dx for %d in the party and %d more", n, #last.game, #last.extra))
  end,
})

-- The page in Config's Mods tab, kept in the save (rq.savedata), as TADA mode is.
local function off_grey() return not settings.get("on") end
settings = rq.config.settings{
  id = "moru-mode",
  title = "Moru Mode",
  keep = "save",
  rows = {
    { kind = "checkbox", key = "on", label = "Moru Mode", default = false,
      tip = { header = "Moru Mode", text = "On or off for this save, apart from TADA mode." } },
    { kind = "stepper", key = "talent", label = "Talent growth", min = MIN, max = MAX, default = DEFAULT,
      disabled = off_grey,
      tip = { header = "Talent growth", text = "How many times Talent and Talent R equipment roll their growth after a fight. The game rolls once." } },
    { kind = "space", h = 6 },
    { kind = "label", dim = true, size = 15, text = "The game's conditions on that growth, each turned off on its own:" },
    { kind = "checkbox", key = "reserve", label = "The reserve's too", default = false, disabled = off_grey,
      tip = { header = "The reserve's too", text = "The first army and the characters switched out during the quest roll too. The game: only the party in the fight." } },
    { kind = "checkbox", key = "fallen", label = "The fallen's too", default = false, disabled = off_grey,
      tip = { header = "The fallen's too", text = "Characters downed at the fight's end roll too. The game: only those standing." } },
    { kind = "checkbox", key = "level", label = "No level limit", default = false, disabled = off_grey,
      tip = { header = "No level limit", text = "In the first world, characters more than 5 levels over the quest's difficulty roll too. The game: not them (from the second world, any level)." } },
    { kind = "space", h = 6 },
    { kind = "label", dim = true, size = 15, text = "Talent grows after a fight won, or ended with the actions run out, as in the game." },
    { kind = "label", dim = true, size = 15, text = "Kept in this save. Also at Alice's support menu, beside Change difficulty." },
  },
}

-- The support menu (quest 13): a row "[OFF] Moru Mode" or "[ON] Moru Mode" under Change difficulty,
-- as the game's own [OFF] / [ON] rows in Other Settings. The game's menu has no pick that only shows
-- it again (an unknown one leaves the support), so a pick of the row is answered here and the menu
-- is shown again with the same rows, until another row is picked.
local menu = nil -- the rows of the support menu being built, to show it again
local replaying = false -- the mod adds the rows itself while it shows the menu again

local function row_text()
  return (settings.get("on") and "[ON]" or "[OFF]") .. " Moru Mode"
end

local function in_support()
  if rq.ain.global("◆iiq") ~= SUPPORT_QUEST then return false end
  for _, name in ipairs(rq.ain.stack(16)) do
    if name == "クエスト処理／基本" then return true end
  end
  return false
end

rq.ain.hook("選択_項目追加", { after = function(h)
  if replaying then return end
  local id, text = h.args[1], h.args[2]
  if id == 1 and text == DIFFICULTY_ROW and in_support() then
    menu = { { 1, text, h.args[3], h.args[4], h.args[5], h.args[6], h.args[7] } }
    menu[#menu + 1] = { ROW_ID }
    rq.ain.call("選択_項目追加", ROW_ID, row_text(), -1, -1, -1, "", -1)
  elseif menu then
    menu[#menu + 1] = { id, text, h.args[3], h.args[4], h.args[5], h.args[6], h.args[7] }
  end
end })

local function alice(lines, wait)
  rq.ain.call("セリフ", ALICE, "")
  for i, line in ipairs(lines) do
    if i > 1 then rq.scene.br() end
    rq.scene.text(line)
  end
  if wait then rq.scene.wait() else rq.scene.show() end
end

local function toggle()
  local now = not settings.get("on")
  settings.set("on", now)
  if now then
    alice({ "\"Very well.", " Moru Mode set to on: Talent equipment rolls its growth "
      .. rolls() .. " times after each fight.\"" }, true)
  else
    alice({ "\"Very well.", " Moru Mode set to off.\"" }, true)
  end
end

rq.ain.hook("選択_実行", { after = function(h)
  local rows = menu
  menu = nil
  if not rows or h.result ~= ROW_ID then return end
  local r = ROW_ID
  replaying = true
  local ok, err = pcall(function()
    while r == ROW_ID do
      toggle()
      alice({ "\"Please choose an entry.\"" }, false)
      rq.ain.call("選択初期")
      for _, row in ipairs(rows) do
        if row[1] == ROW_ID then
          rq.ain.call("選択_項目追加", ROW_ID, row_text(), -1, -1, -1, "", -1)
        else
          rq.ain.call("選択_項目追加", row[1], row[2], row[3], row[4], row[5], row[6], row[7])
        end
      end
      rq.ain.call("選択_カーソル設定", ROW_ID)
      r = rq.ain.call("選択_実行", false, 0, 0, false)
    end
  end)
  replaying = false
  if not ok then
    rq.log("Moru Mode: the support menu: " .. tostring(err))
    r = 99 -- Leave: the game ends the support as its own Leave does
  end
  h.result = r
end })

-- For the Lab and other mods: the switches as the page has them, and what the last fight did.
return {
  on = on,
  rolls = rolls,
  -- set(key, value): "on", "talent", "reserve", "fallen" or "level", as the page.
  set = function(key, value) settings.set(key, value) end,
  get = function(key) return settings.get(key) end,
  -- The last fight with Moru Mode on: rolls, game (the characters the game grew), extra ({iic, why}).
  last = function() return last end,
  row_id = ROW_ID,
}
