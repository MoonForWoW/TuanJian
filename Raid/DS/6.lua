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
local bossIndex = 6
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

    -- 暮光杀戮
    do
        local info = {
            {
                beDamage2 = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                106401,
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                }
            },
        }
        tinsert(info, 2, TJ.combatInfoMore)
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_twilightflamebreath", L["暮光杀戮"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 毁灭打击
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            108043,
                        },
                        colorNum = 2,
                        frameLevel = 1,
                    },
                },
            },
            castSuccess = {
                type = "s",
                spell = {
                    {
                        spellID = ns.sp["单嘲+群嘲"],
                        colorNum = 1,
                        frameLevel = 2,
                        -- combatRole = { "Istank" },
                    },
                },
                destNPCID = { 56427 },
                notShowCount = true,
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_sword_11", L["毁灭打击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 震荡波
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            108046,
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warrior_shockwave", L["震荡波"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 暮光之息
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            110212,
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_twilightflamebreath", L["暮光之息"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    TJ.frame[FB][bossIndex].BOSS_SAY = function(msg)
        if msg:match(L["亲自动手"]) then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
        end
    end
end
