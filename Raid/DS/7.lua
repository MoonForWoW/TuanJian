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
local bossIndex = 7
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

    -- 驱散死亡
    do
        local info = {
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                106199,
                            },
                            colorNum = 1,
                        }
                    },
                },

                notShowDead = true,
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                105490,
                            },
                            colorNum = 2,
                            combatRole = { "Ishealer" },
                        }
                    },
                    showCount=true,
                },
                title = { name = L["治疗被抓（灼热之握）"], icon = "ability_deathwing_fierygrip" },
                notShowDead = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_deathwing_bloodcorruption_earth", L["驱散死亡"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 驱散大地
    do
        local info = {
            dispel = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            106200,
                        },
                        colorNum = 1,
                        frameLevel = 2,
                    }
                },
            },
            notShowDead = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_elemental_mote_nether", L["驱散大地"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    local hp = 100
    local index = 0
    local startTime, new
    TJ.frame[FB][bossIndex].ENCOUNTER_START = function(...)
        hp = 100
        startTime = nil
        index = 0
    end

    TJ.frame[FB][bossIndex].SPELL_AURA_APPLIED = function(...)
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == 106199 then
            new = true
            if not startTime then
                startTime = TJ.GetDurTime()
            end
        end
    end
    TJ.frame[FB][bossIndex].SPELL_AURA_REMOVED = function(...)
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == 106199 and startTime then
            new = nil
            After(0.1, function()
                if new then return end
                for i = 1, GetNumGroupMembers() do
                    local unitToken = "raid" .. i
                    for i = 1, 40 do
                        local name, _, count, _, _, _, _, _, _, spellID = UnitDebuff(unitToken, i)
                        if not name then break end
                        if spellID == 106199 then
                            return
                        end
                    end
                end
                index = index + 1
                tinsert(TJ.GetNewCombatLog().otherTime, {
                    startTime = startTime,
                    endTime = TJ.GetDurTime(),
                    name = "debuff" .. index,
                })
                startTime = nil
            end)
        end
    end
end
