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
local FB = "DS"
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
    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 暮光审判
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            103327,
                        },
                        colorNum = 1
                    },
                },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_twilight", L["暮光审判"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 黯淡之光
    do
        local info = {
            trigger = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            105926,
                        },
                        colorNum = 1,
                        tooltipText = TJ.AddIconBySpellID(105926) .. L["死于黯淡之光"],
                    },
                },
                showCount = true,
            },
            title = { name = L["死于黯淡之光"] },
            notShowDead = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_druid_twilightswrath", L["黯淡之光"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 龙BUFF
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            105896, -- 红龙
                        },
                        colorNum = 8,
                    },
                    {
                        spellID = {
                            105900, -- 绿龙
                        },
                        colorNum = 7,
                    },
                    {
                        spellID = {
                            105903, -- 蓝龙
                        },
                        colorNum = 6,
                    },
                },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_misc_head_dragon_01", L["龙BUFF"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
        TJ.frame[FB][bossIndex].saveAura = {
            [105896] = true, -- 巨龙之魂5号BOSSBUFF：红龙
            [105900] = true, -- 巨龙之魂5号BOSSBUFF：绿龙
            [105903] = true, -- 巨龙之魂5号BOSSBUFF：蓝龙
        }
    end

    -- 黯淡之光
    local auraTbl = {}
    TJ.frame[FB][bossIndex].ENCOUNTER_START = function(...)
        auraTbl = {}
    end
    TJ.frame[FB][bossIndex].SPELL_AURA_APPLIED = function(...)
        local tbl = { ... }
        local GUID = tbl[8]
        local spellID = tbl[12]
        if spellID == 105925 or spellID == 109075 then
            auraTbl[GUID] = true
        end
    end
    TJ.frame[FB][bossIndex].SPELL_AURA_REMOVED = function(...)
        local tbl = { ... }
        local GUID = tbl[8]
        local spellID = tbl[12]
        if spellID == 105925 or spellID == 109075 then
            After(1, function()
                auraTbl[GUID] = nil
            end)
        end
    end
    TJ.frame[FB][bossIndex].UNIT_DIED = function(...)
        local tbl = { ... }
        local GUID = tbl[8]
        if auraTbl[GUID] then
            TJ.GetNewEvent()["TRIGGER"] =
                TJ.GetNewEvent()["TRIGGER"] or {}
            local tbl = {
                TJ.GetDurTime(),
                "TRIGGER",
                nil,
                GUID,
                "",
                nil,
                nil,
                nil,
                nil,
                nil,
                nil,
                105926,
                L["黯淡之光"],
            }
            tbl.i = 1
            tinsert(TJ.GetNewEvent()["TRIGGER"], tbl)
        end
    end
end
