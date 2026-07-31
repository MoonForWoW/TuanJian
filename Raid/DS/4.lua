local AddonName, ns = ...

local LibBG = ns.LibBG
local L = ns.L

local AddTexture = ns.AddTexture
local Round = ns.Round

local pt = print
local After = C_Timer.After
local BG = TJ

local realmID = GetRealmID()
local player = UnitName("player")


local T = {}
local FB = "DS"
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
    TJ.frame[FB][bossIndex].showPhase=true

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 冰枪
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            105316,
                        },
                        colorNum = 1,
                    },
                },
                destNpcType = { "Player" },
            },
            notShowDead = true,
            -- showPhase=true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_jewelcrafting_icediamond_02", L["冰枪"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 寒冰之墓
    do
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        55695,
                    },
                },
                canSend = "dps",
                title = { name = L["打冰墓"], icon = "spell_frost_frozencore", }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                104451,
                            },
                            colorNum = 2,
                        },
                    },
                },
                title = { name = L["冰墓点名"], icon = "spell_frost_frozencore", },
                notShowDead = true,
            },
            isMany = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_frost_frozencore", L["寒冰之墓"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 霜冻
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                109325,
                            },
                            colorNum = 2,
                        },
                    },
                },
                dispel = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                109325,
                            },
                            colorNum = 1,
                            frameLevel = 3,
                        }
                    },
                },
                title = { name = L["霜冻"]},
                notShowDead = true,
            },
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                109325,
                            },
                            colorNum = 1,
                            frameLevel = 2,
                        }
                    },
                },
                title = { name = L["驱散霜冻"] },
                notShowDead = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_sigil_hodir", L["霜冻"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 寒冰之潮
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            105314,
                        },
                        colorNum = 1
                    },
                },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 429385, L["寒冰之潮"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 冰锥
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            69425,
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_frost_freezingbreath", L["冰锥"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 风暴之柱
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            109563,
                        },
                        colorNum = 1
                    },
                },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_lightningbolt", L["风暴之柱"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    local start1, start2
    TJ.frame[FB][bossIndex].SPELL_AURA_APPLIED = function(...)
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == 105409 then     -- 水盾
            start1 = TJ.GetDurTime()
        elseif spellID == 105256 then -- 寒冰暴雨
            start2 = TJ.GetDurTime()
        end
    end
    TJ.frame[FB][bossIndex].SPELL_AURA_REMOVED = function(...)
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == 105409 and start1 then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                startTime = start1,
                endTime = TJ.GetDurTime(),
                name = "fb",
                name2 = L["风暴"]
            })
            start1 = nil
        elseif spellID == 105256 and start2 then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                startTime = start2,
                endTime = TJ.GetDurTime(),
                name = "by",
                name2 = L["暴雨"]
            })
            start2 = nil
        end
    end
    TJ.frame[FB][bossIndex].ENCOUNTER_START = function(...)
        start1 = nil
        start2 = nil
    end
    TJ.frame[FB][bossIndex].ENCOUNTER_END = function(...)
        if start1 then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                startTime = start1,
                endTime = TJ.GetDurTime(),
                name = "fb",
                name2 = L["风暴"]
            })
            start1 = nil
        end
        if start2 then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                startTime = start2,
                endTime = TJ.GetDurTime(),
                name = "by",
                name2 = L["暴雨"]
            })
            start2 = nil
        end
    end
end
