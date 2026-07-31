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
    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 践踏
    do
        local info = {
            beDamage2 = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            103414,
                        },
                        colorNum = 1
                    },
                },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_misc_apexis_crystal", L["践踏"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    
    -- 共鸣水晶
    do
        local info = {
            beDamage2 = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            103545,
                        },
                        colorNum = 1
                    },
                },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_chaos_orb", L["共鸣水晶"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    
    -- 大地黑血
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            103785,
                        },
                        colorNum = 1,
                    },
                },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_creature_poison_06", L["大地黑血"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    local cd
    TJ.frame[FB][bossIndex].SPELL_AURA_APPLIED = function(...)
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == 103846 then -- 狂怒
            if cd then return end
            cd = true
            After(10, function()
                cd = nil
            end)
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = L["狂怒"],
            })
        end
    end
end
