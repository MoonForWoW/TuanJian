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
    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 穿刺
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                106400,
                            },
                            colorNum = 2,
                        }
                    },
                },
                title = L["承伤"]
            },
        }
        for i, v in ipairs(TJ.combatInfoTank) do
            tinsert(info, v)
        end
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_searingarrow", L["穿刺"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 腐蚀寄生虫
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            108649,
                        },
                        colorNum = 2,
                    }
                },
                showCount = true,
            },
            title = L["点名"],
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_rhyolith_magmaflow_wave", L["腐蚀寄生虫"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 寄生虫
    do
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        57479,
                    },
                },
                title = { name = L["打寄生虫(全程)"] }
            },
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        57479,
                    },
                    phase = "last",
                },
                title = { name = L["打寄生虫(最后一轮)"] }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_rhyolith_magmaflow_wave", L["打寄生虫"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 大触须
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    56471,
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warrior_titansgrip", L["打大触须"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 源质箭
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    56262,
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_meteorstorm", L["打源质箭"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end


    local hp = 100
    TJ.frame[FB][bossIndex].ENCOUNTER_START = function(...)
        hp = 100
    end
    TJ.frame[FB][bossIndex].SPELL_CAST_SUCCESS = function(...)
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == 106548 then -- 苦痛折磨
            hp = hp - 20
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = hp .. "%",
            })
        end
    end

    TJ.frame[FB][bossIndex].SPELL_AURA_REMOVED = function(...)
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == 108649 then -- 腐蚀寄生虫
            local time = TJ.GetDurTime()
            TJ.GetNewCombatLog().otherTime["last"] = {
                startTime = time,
                endTime = time + 15,
            }
        end
    end
end