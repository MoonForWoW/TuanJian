local AddonName, ns = ...

local LibBG = ns.LibBG
local L = ns.L

local AddTexture = ns.AddTexture

local pt = print
local After = C_Timer.After
local BG = TJ

local realmID = GetRealmID()
local player = UnitName("player")


local T = {}
local FB = "ZAMtitan"
local bossIndex = 1
--[[
"DEATHKNIGHT"
"PALADIN"
"WARRIOR"
"SHAMAN"
"HUNTER"
"DRUID"
"ROGUE"
"MAGE"
"WARLOCK"
"PRIEST"
 ]]

TJ.Load[FB .. bossIndex] = function()
    local mainFrame = TJ.frame[FB][bossIndex]
--[=[ 
    -- 站位图
    do
        local tbl = {
            -- { point = "TOPLEFT", xy = { 307, -237 } },
            -- { point = "TOPLEFT", xy = { 298, -330 } },
            -- { point = "TOPLEFT", xy = { 370, -250 } },
            -- { point = "TOPLEFT", xy = { 351, -357 } },
            -- { point = "TOPLEFT", xy = { 343, -192 } },
            -- { point = "TOPLEFT", xy = { 284, -386 } },
            -- { point = "TOPLEFT", xy = { 153, -303 } },
            -- { point = "TOPLEFT", xy = { 399, -207 } },
            -- { point = "TOPLEFT", xy = { 342, -405 } },
            -- { point = "TOPLEFT", xy = { 433, -256 } },
            -- { point = "TOPLEFT", xy = { 397, -392 } },
            -- { point = "TOPLEFT", xy = { 371, -144 } },
            -- { point = "TOPLEFT", xy = { 290, -442 } },
            -- { point = "TOPLEFT", xy = { 426, -160 } },
            -- { point = "TOPLEFT", xy = { 343, -478 } },
            -- { point = "TOPLEFT", xy = { 452, -210 } },
            -- { point = "TOPLEFT", xy = { 394, -450 } },
            -- { point = "TOPLEFT", xy = { 407, -109 } },
            -- { point = "TOPLEFT", xy = { 290, -510 } },
            -- { point = "TOPLEFT", xy = { 487, -264 } },
            -- { point = "TOPLEFT", xy = { 444, -423 } },

            -- [80] = {
            --     xy = { 620, -23 },
            --     isNPC = true,
            --     isNPC_help = true,
            --     isNPC_text = L["空气\n图腾"],
            --     isNPC_icon = "Interface\\Icons\\spell_nature_slowingtotem",
            -- },
            -- [81] = {
            --     xy = { 154, -369 },
            --     isNPC = true,
            --     isNPC_help = true,
            --     isNPC_text = L["被点燃"],
            --     isNPC_icon = "Interface\\Icons\\spell_fire_felfire",
            -- },
            -- [82] = {
            --     xy = { 151, -243 },
            --     isNPC = true,
            --     isNPC_help = true,
            --     isNPC_text = L["被点燃"],
            --     isNPC_icon = "Interface\\Icons\\spell_fire_felfire",
            -- },
            -- [98] = {
            --     xy = { 218, -300 },
            --     isNPC = true,
            --     isNPC_help = true,
            --     isNPC_text = L["近战"],
            --     isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            -- },
            -- [100] = { xy = { 270, -279 }, isNPC = "b" .. bossIndex, size = 70, },
        }

        --[[


]]

        local function AutoFuc()
            -- local tbl = TJ.SortRaidRosterInfo({ 'DEATHKNIGHT' }, "tank", true)
            -- for i, v in ipairs(tbl) do
            --     TJ.SetMapIconPlayer(v, { min = 1, max = 2 })
            -- end
            -- local tbl = TJ.SortRaidRosterInfo({ "PALADIN", "WARRIOR", "DRUID", "MONK" }, "tank", true)
            -- for i, v in ipairs(tbl) do
            --     TJ.SetMapIconPlayer(v, { min = 1, max = 2 })
            -- end
            -- local tbl = TJ.SortRaidRosterInfo(nil, "healer", true)
            -- for i, v in ipairs(tbl) do
            --     TJ.SetMapIconPlayer(v)
            -- end
            -- local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
            -- for i, v in ipairs(tbl) do
            --     TJ.SetMapIconPlayer(v, { min = 8, max = 21 })
            -- end
        end
        local text = {
            -- L["1-2：坦克。"],
            -- L["3-7：治疗。"],
            -- L["8-21：远程DPS。"],
        }

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local width = 650
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 1156 * 761, nil, nil, nil, "v2.0.3")
    end
 ]=]


    TJ.CreateSPTitle(FB, bossIndex, nil, nil)





    mainFrame.BOSS_SAY = function(msg)
        if msg:match("^^") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
            return
        end
    end
end
