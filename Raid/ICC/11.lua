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
local FB = "ICC"
local bossIndex = 11
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
    -- 团员冰抗
    TJ.CreateResistanceFrame(FB, bossIndex, "spell_frost_wizardmark", L["团员冰抗"], 4)
    -- 灵魂石
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local function updateFuc(index)
            local count = 0
            for i, v in ipairs(TJ.raidRosterInfo) do
                if count >= 3 then break end
                if v.role ~= "MAINASSIST" and v.class == "WARLOCK" then
                    count = count + 1
                    local name = "|c" .. select(4, GetClassColor(v.class)) .. TJ.GetIconAndName(v) .. "|r"
                    TJ.CreateEdit(FB, bossIndex, name, index)
                end
            end
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = ns.sp["灵魂石"],
                    },
                },
            }
        }
        local text = L["绑定坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_soulgem", L["灵魂石"],
            text, nil, updateFuc, info)
    end
    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 寒霜刺骨
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            70106,
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 135854, L["寒霜刺骨"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 狂咒点名
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            69766,
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_arcane_focusedpower", L["狂咒点名"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 狂咒误伤
    do
        local info = {
            damageFriend = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            69770,
                        },
                        colorNum = 1
                    },
                },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_arcane_focusedpower", L["狂咒误伤"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 严寒
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            70123,
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 135854, L["严寒"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 冰霜炸弹
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            69845,
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 135836, L["冰霜炸弹"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 冰墓点名
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            70126, -- 冰霜道标
                        },
                        colorNum = 2,
                    },
                    {
                        spellID = {
                            70157, -- 冰墓
                        },
                        colorNum = 1,
                    },
                },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 135851, L["冰墓点名"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 打冰墓
    do
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        36980,
                    },
                    phase = "P2-5",
                },
                canSend = "dps",
                title = { name = L["打冰墓(第五次上天)"], icon = 70157, }
            },
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        36980,
                    },
                    phase = "P2-4",
                },
                canSend = "dps",
                title = { name = L["打冰墓(第四次上天)"], icon = 70157, }
            },
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        36980,
                    },
                    phase = "P2-3",
                },
                canSend = "dps",
                title = { name = L["打冰墓(第三次上天)"], icon = 70157, }
            },
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        36980,
                    },
                    phase = "P2-2",
                },
                canSend = "dps",
                title = { name = L["打冰墓(第二次上天)"], icon = 70157, }
            },
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        36980,
                    },
                    phase = "P2-1",
                },
                canSend = "dps",
                title = { name = L["打冰墓(第一次上天)"], icon = 70157, }
            },
            isMany = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 135851, L["冰墓P2"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 打冰墓
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    36980,
                },
                startTime = "P3",
                endTime = "duration",
            },
            canSend = "dps",
            title = { name = L["打冰墓(P3)"], icon = 70157, }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 135851, L["冰墓P3"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 秘法打击
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            70127,
                        },
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 135730, L["秘法打击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 冰霜光环承伤
    do
        local info = {
            dps = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            70084,
                        },
                    },
                },
                destNpcType = { "Player", },
                startTime = 0,
                endTime = "P3",
                endTime2 = "duration",
            },
            showRaidMember = true,
            canSend = "dps",
            title = { name = L["冰霜光环承伤(不含P3)"], icon = 70084 }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 135849, L["冰霜光环承伤"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    local count = 0
    TJ.frame[FB][bossIndex].ENCOUNTER_START = function(...)
        count = 0
    end
    TJ.frame[FB][bossIndex].BOSS_SAY = function(msg)
        if msg:match(L["无人可以生还！"]) then
            count = count + 1
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime() + 50,
                name = "P1",
            })
            tinsert(TJ.GetNewCombatLog().otherTime, {
                startTime = TJ.GetDurTime(),
                endTime = TJ.GetDurTime() + 50,
                name = "P2-" .. count,
            })
        elseif msg:match(L["绝望吧"]) then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P3",
            })
        end
    end
end

