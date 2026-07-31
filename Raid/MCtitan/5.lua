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
local FB = "MCtitan"
local bossIndex = 5
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
    -- 坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                if v.class == "DEATHKNIGHT" then
                    TJ.SetEditTextFormNum(v, title, 1)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["BOSS优先安排DKT。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil, nil)
        TJ.CreateEdit(FB, bossIndex, L["BOSS坦"])
    end

    -- 偷取衰减魔法
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "MAGE" }, nil, true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local info = {
            dispel = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            19714,
                        },
                        colorNum = 1,
                        frameLevel = 1,
                    },
                },
            }
        }
        local text = L["安排法师。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_holy_sealofsalvation", L["偷取衰减魔法"],
            text, { "PRIEST", "MAGE" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["偷取BUFF"])
        TJ.CreateEdit(FB, bossIndex, L["偷取BUFF"])
        TJ.CreateEdit(FB, bossIndex, L["偷取BUFF"])

        TJ.AddDispelInfo(19714, 1, FB, bossIndex)
    end

    -- 驱散诅咒
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "MAGE" }, nil, true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo({ "DRUID" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo({ "DRUID" }, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local info = {
            dispel = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            19713,
                        },
                        colorNum = 1,
                        frameLevel = 1,
                    },

                },
                sourceNpcType = { "Player" },
            }
        }
        local text = L["安排法师、奶德和鸟德。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_antishadow", L["解诅咒"],
            text, { "DRUID", "MAGE" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])

        TJ.AddDispelInfo(19713, 2, FB, bossIndex)
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)
end
