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
local FB = "HOF"
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
    local mainFrame = TJ.frame[FB][bossIndex]
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
            nil)
        TJ.CreateEdit(FB, bossIndex, L["坦克1"])
        TJ.CreateEdit(FB, bossIndex, L["坦克2"])
        TJ.CreateEdit(FB, bossIndex, L["坦克3"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 生命重塑
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 122370, },
                            tooltip = "aura+castAll",
                        },
                    },
                },
            },
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                122402,
                            },
                        },
                    },
                },
                title = { name = L["漏打断（琥珀畸怪的琥珀爆炸）"], icon = "ability_warrior_bloodnova",color={1,0,0} }
            },
            {
                interrupt = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                122402,
                            },
                        },
                    },
                },
                title = { name = L["成功打断（琥珀畸怪的琥珀爆炸）"], icon = "ability_warrior_bloodnova" }
            },
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                122398,
                            },
                        },
                    },
                    sourceNpcType = { "Player" },
                },
                title = { name = L["漏打断（自身的琥珀爆炸）"], icon = "ability_warrior_bloodnova", color = { 1, 0, 0 } },
                canSend = "count",
            },
            {
                interrupt = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                122398,
                            },
                        },
                    },
                },
                title = { name = L["成功打断（自身的琥珀爆炸）"], icon = "ability_warrior_bloodnova" }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 463485, L["生命重塑"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 琥珀打击
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 123059, },
                            tooltip = "aura+castSuccess:122389",
                        },
                    },
                }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 122370, },
                            tooltip = "aura+castAll",
                        },
                    },
                },
                title = { name = L["生命重塑"], icon = 122370 }
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_criticalstrike", L["易伤层数"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 寄生增长
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 121949, },
                        tooltip = "health",
                    },
                },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_yorsahj_bloodboil_yellow", L["寄生增长"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 琥珀宝珠
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 125502, },
                        },
                    },
                },
                title = L["点名"]
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                125508,
                            },
                            colorNum = 1
                        },
                    },
                },
                title = { name = L["琥珀审判"] }
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 463485, L["琥珀宝珠"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转火小黄
    do
        local info = {
            {
                dps_friend = {
                    type = "s",
                    startTime = 0,
                    endTime = "P2",
                    endTime2 = "duration",
                    banSpell = { 122457, 122398 },
                },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 122370, },
                            tooltip = "aura+castAll",
                        },
                    },
                },
                title = { name = L["生命重塑"], icon = 122370 }
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_elemental_primal_fire", L["转火小黄(P1)"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转火小黄
    do
        local info = {
            {
                dps_friend = {
                    type = "s",
                    startTime = "P2",
                    endTime = "P3",
                    endTime2 = "duration",
                    banSpell = { 122457, 122398 },
                },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 122370, },
                            tooltip = "aura+castAll",
                        },
                    },
                },
                title = { name = L["生命重塑"], icon = 122370 }
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_elemental_primal_fire", L["转火小黄(P2)"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转火小软
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    62691
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_festergutgas", L["转火小软"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("我最伟大的创造") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
            return
        end
        if msg:match("我决不允许") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P3",
            })
            return
        end
    end

    local cd = {}
    mainFrame.UNIT_SPELLCAST_INTERRUPTED = function(unit, spellID, castGUID)
        if spellID == 122398 and not TJ.SetCD(cd, 2, castGUID) then
            TJ.GetNewEvent()["SPELL_INTERRUPT"] =
                TJ.GetNewEvent()["SPELL_INTERRUPT"] or {}
            local tbl = {
                TJ.GetDurTime(),
                "SPELL_INTERRUPT",
                nil,
                UnitGUID(unit),
                "",
                nil,
                nil,
                UnitGUID(unit),
                "",
                nil,
                nil,
                122395,
                "",
                nil,
                122398,
                "",
            }
            tbl.i = 1
            tinsert(TJ.GetNewEvent()["SPELL_INTERRUPT"], tbl)
        end
    end
end
