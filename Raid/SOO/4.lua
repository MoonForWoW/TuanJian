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
local bossIndex = 4
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
            { point = "TOPLEFT", xy = { 181, -139 } },
            { point = "TOPLEFT", xy = { 137, -174 } },
            { point = "TOPLEFT", xy = { 66, -149 } },
            { point = "TOPLEFT", xy = { 51, -95 } },
            { point = "TOPLEFT", xy = { 110, -43 } },
            { point = "TOPLEFT", xy = { 167, -58 } },
            { point = "TOPLEFT", xy = { 421, -446 } },
            { point = "TOPLEFT", xy = { 462, -403 } },
            { point = "TOPLEFT", xy = { 545, -426 } },
            { point = "TOPLEFT", xy = { 559, -490 } },
            { point = "TOPLEFT", xy = { 501, -543 } },
            { point = "TOPLEFT", xy = { 441, -523 } },
            { point = "TOPLEFT", xy = { 149, -408 } },
            { point = "TOPLEFT", xy = { 185, -443 } },
            { point = "TOPLEFT", xy = { 165, -528 } },
            { point = "TOPLEFT", xy = { 103, -543 } },
            { point = "TOPLEFT", xy = { 45, -487 } },
            { point = "TOPLEFT", xy = { 63, -427 } },
            { point = "TOPLEFT", xy = { 416, -134 } },
            { point = "TOPLEFT", xy = { 457, -173 } },
            { point = "TOPLEFT", xy = { 539, -150 } },
            { point = "TOPLEFT", xy = { 549, -94 } },
            { point = "TOPLEFT", xy = { 489, -39 } },
            { point = "TOPLEFT", xy = { 431, -54 } },
            [100] = { xy = { 302, -287 }, isNPC = "b" .. bossIndex },
        }

        --[[

]]
        local xy = {
            { 115, -111 }, -- 星星
            { 480, -111 }, -- 大饼
            { 116, -469 }, -- 紫菱
            { 486, -470 }, -- 三角
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
            local tbl = TJ.SortRaidRosterInfo(nil, "healer", true)
            for _, i in ipairs({ 6, 12, 18, 24 }) do
                for ii, v in ipairs(tbl) do
                    TJ.SetMapIconPlayerFormNum(i, v)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "tank", true)
            for _, i in ipairs({ 1, 7, }) do
                for ii, v in ipairs(tbl) do
                    TJ.SetMapIconPlayerFormNum(i, v)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "dps1", true)
            for _, i in ipairs({ 13, 19, 2, 8, 14, 20, 3, 9, 15, 21, }) do
                for ii, v in ipairs(tbl) do
                    TJ.SetMapIconPlayerFormNum(i, v)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
        end
        local text = L["每个方位尽量保持1治疗2近战3远程。"]
        

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local width = 600
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 848 * 840, nil, nil, nil, "v2.2.5")
    end



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
