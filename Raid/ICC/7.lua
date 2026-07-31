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
    -- 主坦克
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
        local text = L["BOSS优先安排DKT，畸变安排其他坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["主坦克"],
            text, TJ.tankClass, nil, nil, nil, true)
        TJ.CreateEdit(FB, bossIndex, L["BOSS"])
        TJ.CreateEdit(FB, bossIndex, L["畸变"])
    end
    -- P3坦克链
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            if #tbl >= 3 then
                local T1, T2, T3
                for i, v in ipairs(tbl) do
                    if v.class == "DEATHKNIGHT" then
                        TJ.SetEditTextFormNum(v, title, 1)
                        T1 = v
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v ~= T1 then
                        TJ.SetEditTextFormNum(v, title, 2)
                        T2 = v
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v ~= T1 and v ~= T2 then
                        TJ.SetEditTextFormNum(v, title, 3)
                        T3 = v
                        break
                    end
                end
                if T1 then
                    TJ.SetEditTextFormNum(T1, title, 4)
                end
                if T2 then
                    TJ.SetEditTextFormNum(T2, title, 5)
                end
                if T1 then
                    TJ.SetEditTextFormNum(T1, title, 6)
                end
            else
                local T1, T2
                for i, v in ipairs(tbl) do
                    if v.class == "DEATHKNIGHT" then
                        TJ.SetEditTextFormNum(v, title, 1)
                        T1 = v
                        break
                    end
                end
                local dpstbl = TJ.SortRaidRosterInfo({ "DEATHKNIGHT", "WARRIOR", "DRUID" }, "dps1", true)
                for i, v in ipairs(dpstbl) do
                    if v.class == "DEATHKNIGHT" then
                        TJ.SetEditTextFormNum(v, title, 2)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v ~= T1 then
                        TJ.SetEditTextFormNum(v, title, 3)
                        T2 = v
                        break
                    end
                end
                for i, v in ipairs(dpstbl) do
                    if v.class == "WARRIOR" or v.class == "DRUID" then
                        TJ.SetEditTextFormNum(v, title, 4)
                        tremove(tbl, i)
                        break
                    end
                end
                if T2 then
                    TJ.SetEditTextFormNum(T2, title, 5)
                end
                if T1 then
                    TJ.SetEditTextFormNum(T1, title, 6)
                end
                if T2 then
                    TJ.SetEditTextFormNum(T2, title, 7)
                end
            end
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            72451, -- 畸变瘟疫
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
                        combatRole = { "Istank" },
                    },
                },
                startTime = "P3",
                endTime = "duration",
                notShowCount = true,
            }
        }
        local text = {
            L["|cff00ff002T阵容："],
            L["1、主T2层"],
            L["2、输出DK冰封+压制2层"],
            L["3、副T2层"],
            L["4、战士/熊群嘲+保护1层"],
            L["5、副T3层"],
            L["6、主T4层"],
            L["7、副T4层"],
            L["|cff00ff003T阵容："],
            L["1、1T2层"],
            L["2、2T2层"],
            L["3、3T3层"],
            L["4、1T3层"],
            L["5、2T4层"],
            L["6、1T4层"],
        }
        TJ.CreateTitle(FB, bossIndex, AutoFuc, 236271, L["P3坦克链"],
            text, TJ.tankClass, nil, info, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["1"])
        TJ.CreateEdit(FB, bossIndex, L["2"])
        TJ.CreateEdit(FB, bossIndex, L["3"])
        TJ.CreateEdit(FB, bossIndex, L["4"])
        TJ.CreateEdit(FB, bossIndex, L["5"])
        TJ.CreateEdit(FB, bossIndex, L["6"])
        TJ.CreateEdit(FB, bossIndex, L["7"])
    end

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

    -- 软泥喷发
    do
        local info = {
            {
                beDamage2 = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                70492,
                            },
                            colorNum = 1,
                            frameLevel = 2,
                        },
                    },
                    destNpcType = { "Player" },
                },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                70447,
                            },
                            colorNum = 2,
                            frameLevel = 1,
                        },
                    },
                },
                title = { name = L["绿软点名"], icon = "ability_warlock_chaosbolt" }
            },
            isMany = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_felcano", L["软泥喷发"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火软泥
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    37697,
                    37562,
                },
                phase = { "P1", "P2" },
            },
            showRaidMember = true,
            canSend = "dps",
            title = { name = L["软泥伤害(非转阶段)"], icon = "ability_creature_poison_05", }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_creature_poison_05", L["软泥常规"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转阶段软泥1
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    37697,
                    37562,
                },
                phase = "P1.5",
            },
            showRaidMember = true,
            canSend = "dps",
            title = { name = L["软泥伤害(第一次转阶段)"], icon = "ability_creature_poison_05", }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_creature_poison_05", L["转阶段1"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转阶段软泥2
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    37697,
                    37562,
                },
                phase = "P2.5",
                phase2 = "P3",
            },
            showRaidMember = true,
            canSend = "dps",
            title = { name = L["软泥伤害(第二次转阶段)"], icon = "ability_creature_poison_05", }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_creature_poison_05", L["转阶段2"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 红软点名
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            70672,
                        },
                        colorNum = 2,
                        frameLevel = 1,
                    },
                },
            },
            beDamage2 = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            70701,
                        },
                        colorNum = 1,
                        frameLevel = 2,
                    },
                },
                destNpcType = { "Player" },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 135867, L["红软点名"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 延展
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            70853,
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_misc_herb_evergreenmoss", L["延展"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 毒气弹
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            71278,
                        },
                        colorNum = 1
                    },
                },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 136173, L["毒气弹"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- P3伤害排名
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    37697, 37690, 37562, 36678,
                },
                startTime = "P3",
                endTime = "duration",
            },
            showRaidMember = true,
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 236271, L["P3伤害"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    TJ.frame[FB][bossIndex].SPELL_CAST_START = function(...)
        local tbl = { ... }
        local spellID = tbl[12]
        local diff = GetRaidDifficultyID()
        local time = TJ.GetDurTime()
        local isPT
        if TJ.ValueInTable({ 3, 4, 175, 176 }, diff) then
            isPT = true
        end
        if spellID == 71621 then -- 调制化合药剂
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = time,
                name = "P1.5",
            })
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = time + (isPT and 16.5 or 42.5),
                name = "P2",
            })
            tinsert(TJ.GetNewCombatLog().otherTime, {
                startTime = 0,
                endTime = time,
                name = "P1",
            })
            tinsert(TJ.GetNewCombatLog().otherTime, {
                startTime = time,
                endTime = time + (isPT and 16.5 or 42.5),
                name = "P1.5",
            })
        elseif spellID == 71893 then -- 疯狂试药
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = time,
                name = "P2.5",
            })
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = time + (isPT and 16.5 or 30.5),
                name = "P3",
            })
            for _, v in ipairs(TJ.GetNewCombatLog().otherTime) do
                if v.name == "P2" and v.time then
                    local startTime = v.time
                    tinsert(TJ.GetNewCombatLog().otherTime, {
                        startTime = startTime,
                        endTime = time,
                        name = "P2",
                    })
                    break
                end
            end
            tinsert(TJ.GetNewCombatLog().otherTime, {
                startTime = time,
                endTime = time + (isPT and 16.5 or 30.5),
                name = "P2.5",
            })
        end
    end
    TJ.frame[FB][bossIndex].ENCOUNTER_END = function(...)
        if TJ.GetNewCombatLog().duration then
            for _, v in ipairs(TJ.GetNewCombatLog().otherTime) do
                if v.name == "P3" and v.time then
                    local startTime = v.time
                    tinsert(TJ.GetNewCombatLog().otherTime, {
                        startTime = startTime,
                        endTime = TJ.GetNewCombatLog().duration,
                        name = "P3",
                    })
                    break
                end
            end
        end
    end
end
