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
local FB = 'ULDtitan'
local bossIndex = 13
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
            { point = "TOPLEFT", xy = { 390, -156 } },
            { point = "TOPLEFT", xy = { 439, -220 } },
            { point = "TOPLEFT", xy = { 439, -299 } },
            { point = "TOPLEFT", xy = { 398, -370 } },
            { point = "TOPLEFT", xy = { 295, -415 } },
            { point = "TOPLEFT", xy = { 185, -368 } },
            { point = "TOPLEFT", xy = { 154, -291 } },
            { point = "TOPLEFT", xy = { 163, -205 } },
            { point = "TOPLEFT", xy = { 215, -149 } },
            { point = "TOPLEFT", xy = { 301, -125 } },

            [100] = { xy = { 296, -271 }, isNPC = "b" .. bossIndex, size = 250, },
        }

        --[[


]]

        local function AutoFuc()
            local healers = TJ.SortRaidRosterInfo(nil, "dps1", true)
            for _, v in ipairs(healers) do
                TJ.SetMapIconPlayer(v)
            end
            local rangedDps = TJ.SortRaidRosterInfo(nil, "dps2", true)
            for _, v in ipairs(rangedDps) do
                TJ.SetMapIconPlayer(v)
            end
        end
        local text = L["优先安排近战DPS，其次远程DPS。"]

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["P2进门"],
            text)
        local width = 600
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 1020 * 910, nil, nil, nil, "v3.0.2")
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
