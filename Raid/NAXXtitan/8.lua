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
local FB = "NAXXtitan"
local bossIndex = 8
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

    local instanceID = TJ.FBinfo[FB].ID
    TJ.autoRaidTargetInfo[instanceID] = TJ.autoRaidTargetInfo[instanceID] or {}
    TJ.autoRaidTargetInfo[instanceID][16803] = {
        [7] = true,
        [6] = true,
        [5] = true,
        [4] = true,
        np = true,
    }
    TJ.autoRaidTargetInfo[instanceID][16061] = {
        [8] = true,
        np = true,
    }

    -- 坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["左侧学员"])
        TJ.CreateEdit(FB, bossIndex, L["右侧学员"])
    end

    -- -- 精神控制
    -- do
    --     local function AutoFuc(title)
    --         local tbl = TJ.SortRaidRosterInfo(title.classTbl, "dps", true)
    --         for i, v in ipairs(tbl) do
    --             TJ.SetEditText(v, title)
    --         end
    --         local tbl = TJ.SortRaidRosterInfo(title.classTbl, "healer", true)
    --         for i, v in ipairs(tbl) do
    --             TJ.SetEditText(v, title)
    --         end
    --     end
    --     local text = L["安排牧师。"]
    --     TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_shadowworddominate", L["精神控制"],
    --         text, { "PRIEST" }, nil, nil, nil,
    --         true)
    --     TJ.CreateEdit(FB, bossIndex, L["左侧学员"])
    --     TJ.CreateEdit(FB, bossIndex, L["右侧学员"])
    -- end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- -- 精神控制
    -- do
    --     local info = {
    --         {
    --             aura = {
    --                 type = "d",
    --                 spell = {
    --                     {
    --                         spellID = {
    --                             605,
    --                         },
    --                         colorNum = 1
    --                     },
    --                 },
    --                 destNpcType = { "Player" },
    --             },
    --             castSuccess = {
    --                 type = "s",
    --                 spell = {
    --                     {
    --                         spellID = {
    --                             605,
    --                         },
    --                         colorNum = 2
    --                     },
    --                 },
    --             },
    --             title = { name = L["玩家"] },
    --         },
    --         {
    --             aura = {
    --                 type = "d",
    --                 spell = {
    --                     {
    --                         spellID = {
    --                             605,
    --                         },
    --                         colorNum = 1
    --                     },
    --                 },
    --                 destNpcType = { "Creature" },
    --             },
    --             title = { name = L["学员"] },
    --         },
    --     }
    --     local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_shadowworddominate", L["精神控制"],
    --         nil, nil, nil, info)
    --     TJ.AddSPTitle(FB, bossIndex, f)
    -- end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("") then
            return
        end
    end
end
