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
local FB = "SWtitan"
local bossIndex = 3
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

    mainFrame.saveAura = {
        [45665] = true, -- 压缩
    }

    -- 坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                if v.class == "PALADIN" then
                    TJ.SetEditTextFormNum(v, title, 2)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil, true)
        TJ.CreateEdit(FB, bossIndex, L["BOSS"])
        TJ.CreateEdit(FB, bossIndex, L["P2小怪"])
    end

    -- 驱散毒气新星
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排奶牧/奶骑。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_fire_felflamering", L["驱散毒气新星"],
            text, { "PRIEST", "PALADIN" }, nil, nil)
        TJ.CreateEdit(FB, bossIndex, L["驱散毒气新星"])
        TJ.CreateEdit(FB, bossIndex, L["驱散毒气新星"])
        TJ.CreateEdit(FB, bossIndex, L["驱散毒气新星"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 腐蚀
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                45866, -- 腐蚀
                            },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                },
            },
        }
        tinsert(info, TJ.combatInfoTank)
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_elementalshields", L["腐蚀"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 压缩
    do
        local info = {
            {
                castSuccess = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                45661, -- 压缩
                            },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = L["点名"],
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                45662, 45665, -- 压缩
                            },
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["受到%s伤害"]:format(L["压缩"]) },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_arcane_blast", L["压缩"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 毒气新星
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                45855, -- 毒气新星
                            },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                },
            },
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                45855,
                            },
                            colorNum = 1,
                        },
                    },
                },
                title = { name = L["驱散毒气新星"] },
                notShowDead = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_felflamering", L["毒气新星"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 恶魔蒸汽
    do
        local info = {
            {
                trigger = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                45392,
                            },
                            colorNum = 1,
                            frameLevel = 1,
                            tooltipText = TJ.AddIconBySpellID(45402) .. L["恶魔蒸汽点名"],
                            tooltip = "trigger",
                        },
                    },
                    showCount = true,
                },
                title =L["点名"],
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                45402, 46931,
                            },
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["受到%s伤害"]:format(L["恶魔蒸汽"]) },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_soulleech_1", L["恶魔蒸汽"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 腐蚀迷雾
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            45717, -- 腐蚀迷雾
                        },
                        colorNum = 1,
                    },
                },
                destNpcType = { "Player" },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_regeneration_02", L["腐蚀之雾"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火骷髅
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    25268, -- 不屈的死者
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_creature_disease_02", L["转火骷髅"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.UNIT_SPELLCAST_SUCCEEDED = function(unit, spellID)
        if spellID == 45661 and not TJ.SetCD(mainFrame, 2, spellID) then
            local newEvent = TJ.GetNewEvent()
            if newEvent then
                local targetGUID = TJ.FindTarget(25038)
                if targetGUID then
                    newEvent["SPELL_CAST_SUCCESS"] = newEvent["SPELL_CAST_SUCCESS"] or {}
                    local time = TJ.GetDurTime()
                    local tbl = {
                        time,
                        "SPELL_CAST_SUCCESS",
                        nil,
                        '',
                        nil,
                        nil,
                        nil,
                        targetGUID,
                        nil,
                        nil,
                        nil,
                        spellID,
                    }
                    tbl.i = 1
                    tinsert(newEvent["SPELL_CAST_SUCCESS"], tbl)
                end
            end
        end
    end

    mainFrame.SPELL_SUMMON = function(...)
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == 45392 then
            local newEvent = TJ.GetNewEvent()
            if newEvent then
                newEvent["TRIGGER"] = newEvent["TRIGGER"] or {}
                local tbl = {
                    TJ.GetDurTime(),
                    "TRIGGER",
                    nil,
                    tbl[4],
                    nil,
                    nil,
                    nil,
                    '',
                    nil,
                    nil,
                    nil,
                    45392,
                }
                tbl.i = 1
                tinsert(newEvent["TRIGGER"], tbl)
            end
        end
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("我比以前更强大") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
            TJ.AddTimer(99, function()
                if TJ.GetNewCombatLog() then
                    tinsert(TJ.GetNewCombatLog().otherTime, {
                        time = TJ.GetDurTime(),
                        name = "P1",
                    })
                end
            end)
            return
        end
    end
end
