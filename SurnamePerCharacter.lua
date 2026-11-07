-- The game stores UnitSurnameOwn account-wide. This keeps one value per character
-- and re-applies it on every login.
local CVAR = "UnitSurnameOwn"
local DEFAULT = "1" -- characters you haven't set yet show their surname

local function set(show)
  SetCVar(CVAR, show)
  SurnamePerCharacterDB.show = show
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(_, event, name, value)
  if event == "PLAYER_LOGIN" then
    SurnamePerCharacterDB = SurnamePerCharacterDB or { show = DEFAULT }
    SetCVar(CVAR, SurnamePerCharacterDB.show)
    -- Only listen after applying, so the account-wide value loaded at startup isn't saved here.
    f:RegisterEvent("CVAR_UPDATE")
  elseif name and name:lower() == CVAR:lower() then
    -- Changed in the game's own options: remember it for this character, silently.
    SurnamePerCharacterDB.show = tostring(value or GetCVar(CVAR))
  end
end)

-- Options > AddOns entry. Reads and writes the game setting directly.
local category = Settings.RegisterVerticalLayoutCategory("Surname Per Character")
local setting = Settings.RegisterProxySetting(category, "SurnamePerCharacter_show",
  Settings.VarType.Boolean, "Show my surname over my head", true,
  function() return GetCVar(CVAR) == "1" end,
  function(on) set(on and "1" or "0") end)
Settings.CreateCheckbox(category, setting,
  "Saved separately for each character. Same as the surname option in the game's settings.")
Settings.RegisterAddOnCategory(category)

SLASH_SURNAMEPC1 = "/surname"
SlashCmdList.SURNAMEPC = function()
  set(GetCVar(CVAR) == "1" and "0" or "1")
  print("|cffffd100Surname:|r " .. (GetCVar(CVAR) == "1" and "shown on this character" or "hidden on this character"))
end
