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
local bossIndex = 2
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

TJ.Load[FB .. bossIndex]  =function()
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

    -- 防恐结界
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, nil, true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            6346, -- 防护恐惧结界
                        },
                        colorNum = 1,
                    },
                },
            }
        }
        local text = L["安排牧师。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_holy_excorcism", L["坦克防恐结界"],
            text, { "PRIEST" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["1防恐"])
        TJ.CreateEdit(FB, bossIndex, L["2防恐"])
        TJ.CreateEdit(FB, bossIndex, L["3防恐"])

        TJ.AddDispelInfo(19408, 5, FB, bossIndex)
    end
    -- 宁神
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "dps", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            19451
                        },
                        colorNum = 2,
                        frameLevel = 1,
                    }
                },
            },
            dispel = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            19451,
                        },
                        colorNum = 1,
                        frameLevel = 2,
                    }
                },
            },
        }
        local text = L["安排猎人。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_drowsy", L["宁神"],
            text, { "HUNTER", }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["1宁神"])
        TJ.CreateEdit(FB, bossIndex, L["2宁神"])
        TJ.CreateEdit(FB, bossIndex, L["3宁神"])

        TJ.AddDispelInfo(19451, 5, FB, bossIndex)
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 燃烧
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            19428,
                        },
                        colorNum = 1,
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_incinerate", L["燃烧"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 熔岩喷吐
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            19450,
                        },
                        colorNum = 1,
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_meteorstorm", L["熔岩喷吐"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
end
