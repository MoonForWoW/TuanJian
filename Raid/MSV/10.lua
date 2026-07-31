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
local FB = "HOF"
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
    local mainFrame = TJ.frame[FB][bossIndex]
    mainFrame.showPhase = true
    -- 自动标记
    local name = "rt" .. FB .. bossIndex
    do
        local instanceID = TJ.FBinfo[FB].ID
        TJ.autoRaidTargetInfo[instanceID] = TJ.autoRaidTargetInfo[instanceID] or {}
        TJ.autoRaidTargetInfo[instanceID][62405] = {
            [5] = true, -- 月亮
            [4] = true, -- 三角
            [3] = true, -- 菱形
            np = true,
        }
        TJ.autoRaidTargetInfo[instanceID][62408] = {
            [8] = true,
            [7] = true,
            [6] = true,
            np = true,
        }

        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local icon = TJ.SetRaidTargetingIcons(nil, "kulou")
            .. TJ.SetRaidTargetingIcons(nil, "chacha")
            .. TJ.SetRaidTargetingIcons(nil, "fangkuai")
        local ontext = {
        }
        local f = ns.O.CreateCheckButton(name, format(L["战斗中把助战者标记为%s（需要团长/助理）"], icon),
            mainFrame, 40, -150, ontext)
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", TJ.spChild.title, "TOPRIGHT", 0, 15)
        f:SetHitRectInsets(0, 0, 0, 0)
    end

    -- 战术板
    do
        local bossSpellID = 122406
        local isload
        local init = function()
            isload = true
            local s1, s2, s3, s4, s5, s6, s7 = ns.s1, ns.s2, ns.s3, ns.s4, ns.s5, ns.s6, ns.s7
            local spellTbl = {
                {
                    title = L["1/5"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["2/6"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["3/7"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["4/8"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
            }
            local function AutoFuc()
                local maxIndex = #spellTbl
                local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, nil, true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s2)
                    TJ.SetBoardEditFormNum(v, i, nil, s3)
                end

                local startIndex = #tbl + 1
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s7)
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s9)
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s8)
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
                for i, v in ipairs(tbl) do
                    for i = startIndex, maxIndex, 1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s6)
                            done[i] = true
                            break
                        end
                    end
                end
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "dps", true)
                for i, v in ipairs(tbl) do
                    for i = startIndex, maxIndex, 1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s9)
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s10)
                            done[i] = true
                            break
                        end
                    end
                end
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "DRUID" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = startIndex, maxIndex, 1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s12)
                            done[i] = true
                            break
                        end
                    end
                end
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "dps", true)
                for i, v in ipairs(tbl) do
                    for i = startIndex, maxIndex, 1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s14)
                            done[i] = true
                            break
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = maxIndex, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, TuanJian.talentInfo[v.name] == 1 and s5 or ns.s13)
                            done[i] = true
                            break
                        end
                    end
                end
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = maxIndex, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s1)
                            done[i] = true
                            break
                        end
                    end
                end
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "MONK" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = maxIndex, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s11)
                            done[i] = true
                            break
                        end
                    end
                end
            end

            local tbl = {
                {
                    name = L["刃雨减伤链"],
                    bossSpellID = bossSpellID,
                    arrange = 6,
                    icon = "inv_sword_2h_mantid_01",
                    id = 1,
                    spell = spellTbl,
                    event = "SPELL_CAST_START",
                    canUpdate = nil,
                    autoNextSpell = nil,
                    startIndex = 1,
                    bossTime = { 1.5, 1.5, },
                    autoHide = true,
                },
                AutoFuc = AutoFuc,
            }

            mainFrame.Board_test = function()
                TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
                TJ.Board_info[bossSpellID].canUpdate = true
            end
            mainFrame.Board_SPELL_CAST_START = function(info, ...)
                local tbl = { ... }
                local spellID = tbl[12]
                if spellID == bossSpellID then
                    TJ.Board_info[bossSpellID].canUpdate = true
                    TJ.Board_info[bossSpellID].updateFrame.t = 0
                    After(0, function()
                        info[bossSpellID].index = info[bossSpellID].index + info[bossSpellID].step
                    end)
                end
            end

            TJ.CreateBoard(FB, bossIndex, tbl)
        end
        tinsert(TJ.boardCallback, init)
        if TJ.boardInited and not isload then init() end
    end

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
            true)
        TJ.CreateEdit(FB, bossIndex, L["BOSS"])
        TJ.CreateEdit(FB, bossIndex, L["小怪"])
    end
    -- 打断小怪
    do
        local function AutoFuc(title)
            local tbl = CopyTable(TJ.SortRaidRosterInfo({ "DEATHKNIGHT", "ROGUE", "WARRIOR", "MONK", "SHAMAN" }, "dps1", true))
            for i, v in ipairs(tbl) do
                if v.class == "DEATHKNIGHT" then
                    tbl[i].index = 1
                elseif v.class == "ROGUE" then
                    tbl[i].index = 2
                elseif v.class == "WARRIOR" then
                    tbl[i].index = 3
                elseif v.class == "SHAMAN" then
                    tbl[i].index = 4
                end
            end
            local tbl2 = CopyTable(TJ.SortRaidRosterInfo({ "SHAMAN", "MAGE" }, "dps2", true))
            for i, v in ipairs(tbl2) do
                if v.class == "SHAMAN" then
                    tbl2[i].index = 5
                elseif v.class == "MAGE" then
                    tbl2[i].index = 6
                end
            end
            for _, v in pairs(tbl2) do
                tinsert(tbl, v)
            end
            sort(tbl, function(a, b)
                if a.index and b.index then
                    return a.index < b.index
                end
                return false
            end)
            local done = {}
            for _, v in ipairs(tbl) do
                for _, i in ipairs({ 1, 3, 5, 2, 4, 6 }) do
                    if not done[i] then
                        TJ.SetEditTextFormNum(v, title, i)
                        done[i] = true
                        break
                    end
                end
            end
        end
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 122193 },
                        },
                    },
                },
                title = { name = L["漏打断"], color = { 1, 0, 0 } },
                canSend = "count",
            },
            {
                interrupt = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                122193
                            },
                        },
                    },
                },
                title = { name = L["成功打断"] }
            },
        }
        local text = L["安排近战打断。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "paladin_holy", L["打断助战者"],
            text, nil, nil, info, nil,
            true, 2)
        TJ.CreateEdit(FB, bossIndex, L["骷髅"] .. TJ.SetRaidTargetingIcons(nil, "kulou"))
        TJ.CreateEdit(FB, bossIndex, L["骷髅"] .. TJ.SetRaidTargetingIcons(nil, "kulou"))
        TJ.CreateEdit(FB, bossIndex, L["叉叉"] .. TJ.SetRaidTargetingIcons(nil, "chacha"))
        TJ.CreateEdit(FB, bossIndex, L["叉叉"] .. TJ.SetRaidTargetingIcons(nil, "chacha"))
        TJ.CreateEdit(FB, bossIndex, L["方块"] .. TJ.SetRaidTargetingIcons(nil, "fangkuai"))
        TJ.CreateEdit(FB, bossIndex, L["方块"] .. TJ.SetRaidTargetingIcons(nil, "fangkuai"))
    end
    -- 控制诱捕者
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "HUNTER" }, nil, true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo({ "MAGE" }, nil, true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                122224,                                 -- 穿刺之矛
                                1499, 3355,                             -- LR冰冻陷阱
                                118, 61305, 28272, 61780, 61721, 28271, -- FS
                                51514,                                  -- SM
                            },
                        },
                    },
                }
            },
            {
                broken = {
                    type = "s",
                    destNPCID = {
                        62405
                    },
                },
            }
        }
        local text = L["优先安排猎人，其次法师。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "inv_staff_2h_mantid_01", L["控制诱捕者"],
            text, nil, nil, info, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["月亮"] .. TJ.SetRaidTargetingIcons(nil, "yueliang"))
        TJ.CreateEdit(FB, bossIndex, L["三角"] .. TJ.SetRaidTargetingIcons(nil, "sanjiao"))
        TJ.CreateEdit(FB, bossIndex, L["菱形"] .. TJ.SetRaidTargetingIcons(nil, "ziling"))
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 刃雨
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 122406, },
                            colorNum = 2,
                        },
                    },
                },
            },
            isMany = true,
        }
        tinsert(info, TJ.combatInfoMore)

        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_sword_2h_mantid_01", L["刃雨"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 驱散加速
    do
        local info = {
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                122149
                            },
                            colorNum = 1,
                        },
                    },
                    -- sourceNpcType = { "Player" },
                }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                122149
                            },
                            colorNum = 1,
                        },
                    },
                },
                title = { name = L["加速Buff"] }
            }
        }

        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_elemental_primal_air", L["驱散加速"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 风爆弹
    do
        local info = {
            trigger = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            131813,
                        },
                        colorNum = 1,
                        tooltipText = TJ.AddIconBySpellID(131813) .. L["触发风爆弹"],
                    },
                },
                showCount = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 463565, L["风爆弹"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 警觉之眼
    do
        local info = {
            castSuccess = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            122399,
                        },
                        colorNum = 1,
                    },
                },
            },
            title = { name = L["警觉之眼（控制超过3个小怪）"], icon = "inv_misc_eye_02" }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_misc_eye_02", L["警觉之眼"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 打醒诱捕者
    do
        local info = {
            broken = {
                type = "s",
                destNPCID = {
                    62405
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_staff_2h_mantid_01", L["打醒诱捕者"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.BOSS_SAY = function(msg)
        local player = msg:match("(.+)引爆了")
        if player then
            local playerGUID = UnitGUID(player)
            if playerGUID then
                TJ.GetNewEvent()["TRIGGER"] =
                    TJ.GetNewEvent()["TRIGGER"] or {}
                local tbl = {
                    TJ.GetDurTime(),
                    "TRIGGER",
                    nil,
                    playerGUID,
                    player,
                    nil,
                    nil,
                    nil,
                    nil,
                    nil,
                    nil,
                    131813,
                    L["风爆弹"],
                }
                tbl.i = 1
                tinsert(TJ.GetNewEvent()["TRIGGER"], tbl)
            end
            return
        end
    end

    local start
    local targetSpellID = 125873
    mainFrame.SPELL_AURA_APPLIED = function(...)
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == targetSpellID then
            start = TJ.GetDurTime() + 1
        end
    end
    mainFrame.SPELL_AURA_REMOVED = function(...)
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == targetSpellID then
            if start then
                tinsert(TJ.GetNewCombatLog().otherTime, {
                    startTime = start,
                    endTime = TJ.GetDurTime(),
                    name = "鲁莽",
                    name2 = L["鲁莽"]
                })
                start = nil
            end
        end
    end
    mainFrame.ENCOUNTER_START = function(...)
        start = nil
        TJ.setRTinCombat = TuanJian.options[name] == 1
    end
    mainFrame.ENCOUNTER_END = function(...)
        if start then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                startTime = start,
                endTime = TJ.GetDurTime(),
                name = "鲁莽",
                name2 = L["鲁莽"]
            })
            start = nil
        end
    end
    mainFrame.UNIT_DIED = function(...)
        if TuanJian.options[name] == 1 then
            local tbl = { ... }
            if TJ.GetNPCID(tbl[8]) == 62408 then
                for i = 6, 8 do
                    TJ.ActiveAutoRaidTarget[i] = nil
                end
            end
        end
    end
end
