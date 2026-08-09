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
local FB = "SOO"
local bossIndex = 9
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

    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 214, -179 } },
            { point = "TOPLEFT", xy = { 393, -383 } },
            { point = "TOPLEFT", xy = { 390, -179 } },
            { point = "TOPLEFT", xy = { 210, -381 } },
            { point = "TOPLEFT", xy = { 167, -281 } },
            { point = "TOPLEFT", xy = { 439, -280 } },
            { point = "TOPLEFT", xy = { 304, -415 } },
            { point = "TOPLEFT", xy = { 233, -90 } },
            { point = "TOPLEFT", xy = { 379, -91 } },
            { point = "TOPLEFT", xy = { 114, -203 } },
            { point = "TOPLEFT", xy = { 499, -203 } },
            { point = "TOPLEFT", xy = { 118, -364 } },
            { point = "TOPLEFT", xy = { 494, -362 } },
            { point = "TOPLEFT", xy = { 232, -479 } },
            { point = "TOPLEFT", xy = { 381, -477 } },
            { point = "TOPLEFT", xy = { 162, -128 } },
            { point = "TOPLEFT", xy = { 459, -139 } },

            [97] = {
                xy = { 324, -320 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["奶骑\n奶僧"],
                isNPC_icon = "Interface\\Icons\\Spell_Holy_AuraOfLight",
            },
            [98] = {
                xy = { 280, -320 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [99] = {
                xy = { 302, -234 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["坦克"],
                isNPC_icon = "Interface\\Icons\\Spell_Deathknight_BloodPresence",
            },
            [100] = { xy = { 303, -279 }, isNPC = "b" .. bossIndex },
        }

        --[[


]]
        local xy = {
            { 624, -371 }, -- 星星
            { 623, -321 }, -- 大饼
            { 623, -273 }, -- 紫菱
            { 623, -225 }, -- 三角
            { 623, -177 },
            { 623, -128 },
            { 624, -75 },
            { 623, -23 },
        }
        for index = 1, 8 do
            local left = mod((index - 1) / 4, 1);
            local right = left + 0.25;
            local top = floor((index - 1) / 4) * 0.25;
            local bottom = top + 0.25;
            tbl[index + 80] = {
                xy = xy[index],
                isNPC = true,
                isNPC_help = true,
                isNPC_icon = [[Interface\TargetingFrame\UI-RaidTargetingIcons]],
                coord = { left, right, top, bottom },
                notMask = true,
            }
        end

        local function AutoFuc()
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN", "DRUID", "PRIEST", }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN", "PRIEST" }, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
            local tbl = TJ.SortRaidRosterInfo({ "HUNTER", "DRUID", "MAGE", "WARLOCK", }, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
        end
        local text = {
            L["1-4号位：治疗。"],
            L["5-7号位：优先元素萨/暗牧。"],
            L["剩余位置：远程DPS。"],
        }

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["新图"],
            text)
        local width = 600
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 1150 * 1071, nil, nil, nil, "v2.3.1", '-2')
    end

    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 214, -179 } },
            { point = "TOPLEFT", xy = { 393, -383 } },
            { point = "TOPLEFT", xy = { 390, -179 } },
            { point = "TOPLEFT", xy = { 210, -381 } },
            { point = "TOPLEFT", xy = { 167, -281 } },
            { point = "TOPLEFT", xy = { 439, -280 } },
            { point = "TOPLEFT", xy = { 304, -415 } },
            { point = "TOPLEFT", xy = { 233, -90 } },
            { point = "TOPLEFT", xy = { 379, -91 } },
            { point = "TOPLEFT", xy = { 114, -203 } },
            { point = "TOPLEFT", xy = { 499, -203 } },
            { point = "TOPLEFT", xy = { 118, -364 } },
            { point = "TOPLEFT", xy = { 494, -362 } },
            { point = "TOPLEFT", xy = { 232, -479 } },
            { point = "TOPLEFT", xy = { 381, -477 } },
            { point = "TOPLEFT", xy = { 162, -128 } },
            { point = "TOPLEFT", xy = { 459, -139 } },

            [97] = {
                xy = { 324, -320 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["奶骑\n奶僧"],
                isNPC_icon = "Interface\\Icons\\Spell_Holy_AuraOfLight",
            },
            [98] = {
                xy = { 280, -320 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [99] = {
                xy = { 302, -234 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["坦克"],
                isNPC_icon = "Interface\\Icons\\Spell_Deathknight_BloodPresence",
            },
            [100] = { xy = { 303, -279 }, isNPC = "b" .. bossIndex },
        }

        --[[


]]
        local xy = {
            { 624, -371 }, -- 星星
            { 623, -321 }, -- 大饼
            { 623, -273 }, -- 紫菱
            { 623, -225 }, -- 三角
            { 623, -177 },
            { 623, -128 },
            { 624, -75 },
            { 623, -23 },
        }
        for index = 1, 8 do
            local left = mod((index - 1) / 4, 1);
            local right = left + 0.25;
            local top = floor((index - 1) / 4) * 0.25;
            local bottom = top + 0.25;
            tbl[index + 80] = {
                xy = xy[index],
                isNPC = true,
                isNPC_help = true,
                isNPC_icon = [[Interface\TargetingFrame\UI-RaidTargetingIcons]],
                coord = { left, right, top, bottom },
                notMask = true,
            }
        end

        local function AutoFuc()
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN", "DRUID", "PRIEST", }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, nil, 2)
            end
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN", "PRIEST" }, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, nil, 2)
            end
            local tbl = TJ.SortRaidRosterInfo({ "HUNTER", "DRUID", "MAGE", "WARLOCK", }, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, nil, 2)
            end
        end
        local text = {
            L["1-4号位：治疗。"],
            L["5-7号位：优先元素萨/暗牧。"],
            L["剩余位置：远程DPS。"],
        }

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["旧图"],
            text)
        local width = 600
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 1144 * 1071, 2, nil, nil, "v2.2.5")
    end

    TJ.CreateMapTab(mainFrame, FB, bossIndex)

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)





    -- mainFrame.BOSS_SAY = function(msg)
    --     if msg:match("") then
    --         tinsert(TJ.GetNewCombatLog().otherTime, {
    --             time = TJ.GetDurTime(),
    --             name = "P2",
    --         })
    --         return
    --     end
    -- end
end
