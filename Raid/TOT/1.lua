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
local FB = "TOT"
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
    local mainFrame = TJ.frame[FB][bossIndex]

    -- 战术板
    local bossSpellID = 1
    TJ.AddBoard(mainFrame, function()
        local s1, s2, s3, s4, s5, s6, s7 = ns.s1, ns.s2, ns.s3, ns.s4, ns.s5, ns.s6, ns.s7
        local spellTbl = {
            {
                title = L["1-1"],
                class = nil,
                spell = TJ.Board_TJ1,
                onlyTitle = true,
            },
        }
        local spellTbl2 = {
            {
                title = L["1-2"],
                class = nil,
                spell = TJ.Board_TJ1,
                onlyTitle = true,
            },
        }
        local spellTbl3 = {
            {
                title = L["1-3"],
                class = nil,
                spell = TJ.Board_TJ1,
                onlyTitle = true,
            },
        }
        local function AutoFuc()
            local maxIndex = 3
            local startIndex = 1

            local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, nil, true)
            for i = startIndex, maxIndex, 1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, 1, nil, s2, i)
                    TJ.SetBoardEditFormNum(v, 1, nil, s3, i)
                    tremove(tbl, ii)
                    break
                end
            end

            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, nil, true)
            for i = startIndex, maxIndex, 1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, 1, nil, s1, i)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
            for i = startIndex, maxIndex, 1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, 1, nil, s6, i)
                    tremove(tbl, ii)
                    break
                end
            end

            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
            for i = startIndex, maxIndex, 1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, 1, nil, s7, i)
                    TJ.SetBoardEditFormNum(v, 1, nil, ns.s9, i)
                    TJ.SetBoardEditFormNum(v, 1, nil, ns.s8, i)
                    tremove(tbl, ii)
                    break
                end
            end

            local tbl = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, "dps", true)
            for i = 2, maxIndex, 1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, 1, nil, s4, i)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
            for i = 2, maxIndex, 1 do
                for ii, v in ipairs(tbl) do
                    if TuanJian.talentInfo[v.name] == 1 then
                        TJ.SetBoardEditFormNum(v, 1, nil, s5, i)
                        tremove(tbl, ii)
                        break
                    end
                end
            end

            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "dps", true)
            for i = maxIndex, startIndex, -1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, 1, nil, ns.s9, i)
                    TJ.SetBoardEditFormNum(v, 1, nil, ns.s8, i)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "DRUID" }, "healer", true)
            for i = maxIndex, startIndex, -1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, 1, nil, ns.s12, i)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "MONK" }, "healer", true)
            for i = maxIndex, startIndex, -1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, 1, nil, ns.s11, i)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "dps", true)
            for i = maxIndex, startIndex, -1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, 1, nil, ns.s14, i)
                    tremove(tbl, ii)
                    break
                end
            end
        end

        local arrange = 6
        local tbl = {
            {
                name = L["闪电风暴第1棒"],
                bossSpellID = 1,
                arrange = arrange,
                icon = "spell_shaman_thunderstorm",
                id = 1,
                spell = spellTbl,
                event = "SPELL_CAST_START",
                canUpdate = nil,
                autoNextSpell = nil,
                startIndex = 1,
                maxIndex = 1,
                bossTime = { 2.5, 2.5, },
                special = {
                    id = 2,
                    bossSpellID = 2,
                    time = 4.5,
                },
                special2 = {
                    id = 3,
                    bossSpellID = 3,
                    time = 4.5,
                },
                autoHide = true,
            },
            {
                name = L["闪电风暴第2棒"],
                bossSpellID = 2,
                arrange = arrange,
                icon = "spell_shaman_thunderstorm",
                id = 2,
                spell = spellTbl2,
                event = "SPELL_CAST_START",
                canUpdate = nil,
                autoNextSpell = nil,
                startIndex = 1,
                maxIndex = 1,
                bossTime = { 2.5, 2.5, },
                autoHide = true,
            },
            {
                name = L["闪电风暴第3棒"],
                bossSpellID = 3,
                arrange = arrange,
                icon = "spell_shaman_thunderstorm",
                id = 3,
                spell = spellTbl3,
                event = "SPELL_CAST_START",
                canUpdate = nil,
                autoNextSpell = nil,
                startIndex = 1,
                maxIndex = 1,
                bossTime = { 2.5, 2.5, },
                autoHide = true,
            },
            AutoFuc = AutoFuc,
        }

        mainFrame.Board_test = function()
            TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
            TJ.Board_info[bossSpellID].canUpdate = true
            TJ.AddTimer(3, function()
                TJ.Board_RunSpecial(bossSpellID)
                TJ.AddTimer(5, function()
                    TJ.Board_RunSpecial(bossSpellID, 2)
                end)
            end)
        end
        --[[
/run TJ.Board_ENCOUNTER_START("TOT", 1) TJ.Board_SPELL_CAST_START(nil,nil,nil,"1",nil,nil,nil,"1-2-3-4-5-70235",nil,nil,nil,137313)
/run TJ.Board_SPELL_CAST_START(nil,nil,nil,"1",nil,nil,nil,"1-2-3-4-5-70235",nil,nil,nil,137313)
 ]]

        mainFrame.Board_SPELL_CAST_START = function(info, ...)
            local tbl = { ... }
            local spellID = tbl[12]
            if spellID == 137313 and TJ.Board_info[bossSpellID].index <= TJ.Board_info[bossSpellID].maxIndex then
                TJ.Board_info[bossSpellID].canUpdate = true
                TJ.Board_info[bossSpellID].updateFrame.t = 0
                TJ.AddTimer(3, function()
                    TJ.Board_RunSpecial(bossSpellID)
                    if TJ.Board_info[bossSpellID] then
                        TJ.Board_info[bossSpellID].index = TJ.Board_info[bossSpellID].index + TJ.Board_info[bossSpellID].step
                    end
                    TJ.AddTimer(5, function()
                        TJ.Board_RunSpecial(bossSpellID, 2)
                    end)
                end)
            end
        end

        TJ.CreateBoard(FB, bossIndex, tbl)
    end)

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
        TJ.CreateEdit(FB, bossIndex, L["主坦克"])
        TJ.CreateEdit(FB, bossIndex, L["副坦克"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 换嘲
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 138349 },
                        colorNum = 2,
                    },
                },
                destNpcType = { "Player" },
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
                notShowCount = true,
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_reincarnation", L["换嘲"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 专注闪电
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 137422 },
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = L["点名"],
            },
            {
                damageFriend = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                137530, -- 专注闪电传导
                            },
                            colorNum = 1,
                        },
                    },
                },
                title = { name = L["闪电球在水中爆炸"] },
            },
            {
                beDamage2 = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                137507, -- 内爆
                            },
                            colorNum = 1,
                        },
                    },
                },
                title = { name = L["闪电球碰撞到其他闪电裂隙"] },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_vehicle_electrocharge", L["闪电球"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 流体
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 138002 },
                    },
                },
                destNpcType = { "Player" },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_misc_volatilewater", L["流体"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 电离反应
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 138732 },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                },
                damageFriend = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                138733
                            },
                            colorNum = 4,
                        },
                    },
                },
            },
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                138732,
                            },
                            colorNum = 1
                        }
                    },
                    sourceNpcType = { "Player" },
                },
                title = { name = L["驱散电离反应"], icon = 138732 },
                notShowDead = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_callstorm", L["电离反应"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 闪电打击
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 137313, },
                            colorNum = 2,
                        },
                    },
                },
                title = { name = L["Boss施放%s"]:format(L["闪电风暴"]), icon = 137313 }
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                137647, -- 闪电打击
                            },
                            colorNum = 1
                        },
                    },
                },
                canSend = "count",
                title = { name = L["受到%s伤害"]:format(L["闪电打击"]), icon = 137647 }
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                137905, -- 闪电漫射
                            },
                            colorNum = 1
                        },
                    },
                },
                canSend = "count",
                title = { name = L["受到%s伤害"]:format(L["闪电漫射"]), icon = 137905 }
            },
        }

        local f = TJ.CreateTitle(FB, bossIndex, nil, "warrior_talent_icon_thunderstruck", L["闪电打击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 闪电风暴
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 137313, },
                            colorNum = 2,
                        },
                    },
                },
                title = { name = L["Boss施放%s"]:format(L["闪电风暴"]), icon = 137313 }
            },
        }
        tinsert(info, TJ.combatInfoMore)

        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shaman_thunderstorm", L["闪电风暴"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.saveAura = { [138002] = true }

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("") then
            return
        end
    end
end
