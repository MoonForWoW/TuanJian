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
            { point = "TOPLEFT", xy = { 327, -51 } },
            { point = "TOPLEFT", xy = { 327, -96 } },
            { point = "TOPLEFT", xy = { 154, -223 } },
            { point = "TOPLEFT", xy = { 509, -223 } },
            { point = "TOPLEFT", xy = { 329, -369 } },
            { point = "TOPLEFT", xy = { 327, -417 } },
            { point = "TOPLEFT", xy = { 154, -265 } },
            { point = "TOPLEFT", xy = { 508, -265 } },
            { point = "TOPLEFT", xy = { 216, -348 } },
            { point = "TOPLEFT", xy = { 186, -383 } },
            { point = "TOPLEFT", xy = { 437, -343 } },
            { point = "TOPLEFT", xy = { 465, -379 } },
            { point = "TOPLEFT", xy = { 210, -141 } },
            { point = "TOPLEFT", xy = { 454, -134 } },
            { point = "TOPLEFT", xy = { 174, -111 } },
            { point = "TOPLEFT", xy = { 488, -97 } },

            [80] = {
                xy = { 673, -22 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["空气\n图腾"],
                isNPC_icon = "Interface\\Icons\\spell_nature_slowingtotem",
            },
            [97] = {
                xy = { 289, -270 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["1队\n近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [98] = {
                xy = { 375, -271 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["2队\n近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [99] = {
                xy = { 331, -183 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["坦克"],
                isNPC_icon = "Interface\\Icons\\Spell_Deathknight_BloodPresence",
            },
            [100] = { xy = { 332, -234 }, isNPC = "b" .. bossIndex, size = 70, },
        }

        --[[

]]

        local function AutoFuc()
            local healers = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
            for _, v in ipairs(healers) do
                TJ.SetMapIconPlayer(v)
            end

            healers = TJ.SortRaidRosterInfo({ "PRIEST", "SHAMAN", "DRUID" }, "healer", true)
            for _, v in ipairs(healers) do
                TJ.SetMapIconPlayer(v)
            end

            local rangedDps = TJ.SortRaidRosterInfo(nil, "dps2", true)
            for _, v in ipairs(rangedDps) do
                TJ.SetMapIconPlayer(v)
            end
        end
        local text = {
            L["1-2：奶骑。"],
            L["3-5：其他治疗。"],
            L["6-16：远程DPS。"],
        }

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["P2站位"],
            text)
        local width = 650
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 1234 * 936, nil, nil, nil, "v3.0.2")
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
