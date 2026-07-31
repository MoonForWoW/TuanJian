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

    -- 战术板
    do
        local bossSpellID = 1
        local isload
        local init = function()
            isload = true
            local s1, s2, s3, s4, s5, s6, s7 = ns.s1, ns.s2, ns.s3, ns.s4, ns.s5, ns.s6, ns.s7
            local spellTbl = {
                {
                    title = L["1-1"],
                    class = nil,
                    spell = TJ.Board_TJ1,
                    onlyTitle = true,
                },
                {
                    title = L["2-1"],
                    class = nil,
                    spell = TJ.Board_TJ1,
                    onlyTitle = true,
                },
                {
                    title = L["3-1"],
                    class = nil,
                    spell = TJ.Board_TJ1,
                    onlyTitle = true,
                },
                {
                    title = L["4-1"],
                    class = nil,
                    spell = TJ.Board_TJ1,
                    onlyTitle = true,
                },
                {
                    title = L["5-1"],
                    class = nil,
                    spell = TJ.Board_TJ1,
                    onlyTitle = true,
                },
                {
                    title = L["6-1"],
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
                {
                    title = L["2-2"],
                    class = nil,
                    spell = TJ.Board_TJ1,
                    onlyTitle = true,
                },
                {
                    title = L["3-2"],
                    class = nil,
                    spell = TJ.Board_TJ1,
                    onlyTitle = true,
                },
                {
                    title = L["4-2"],
                    class = nil,
                    spell = TJ.Board_TJ1,
                    onlyTitle = true,
                },
                {
                    title = L["5-2"],
                    class = nil,
                    spell = TJ.Board_TJ1,
                    onlyTitle = true,
                },
                {
                    title = L["6-2"],
                    class = nil,
                    spell = TJ.Board_TJ1,
                    onlyTitle = true,
                },
            }
            local function AutoFuc()
                local maxIndex = #spellTbl
                -- 第1棒
                local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, nil, true)
                for i = maxIndex, 1, -1 do
                    for ii, v in ipairs(tbl) do
                        TJ.SetBoardEditFormNum(v, i, nil, s2, 1)
                        TJ.SetBoardEditFormNum(v, i, nil, s3, 1)
                        tremove(tbl, ii)
                        break
                    end
                end
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "dps", true)
                for i = maxIndex, 1, -1 do
                    for ii, v in ipairs(tbl) do
                        TJ.SetBoardEditFormNum(v, i, nil, ns.s9, 1)
                        TJ.SetBoardEditFormNum(v, i, nil, ns.s10, 1)
                        tremove(tbl, ii)
                        break
                    end
                end
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
                for i = 4, 1, -1 do
                    for ii, v in ipairs(tbl) do
                        TJ.SetBoardEditFormNum(v, i, nil, TuanJian.talentInfo[v.name] == 1 and s5 or ns.s13)
                        tremove(tbl, ii)
                        break
                    end
                end
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "dps", true)
                for i = 3, 1, -1 do
                    for ii, v in ipairs(tbl) do
                        TJ.SetBoardEditFormNum(v, i, nil, ns.s14)
                        tremove(tbl, ii)
                        break
                    end
                end
                local tbl = TJ.SortRaidRosterInfo({ "DRUID" }, "healer", true)
                for i = 3, 1, -1 do
                    for ii, v in ipairs(tbl) do
                        TJ.SetBoardEditFormNum(v, i, nil, ns.s12)
                        tremove(tbl, ii)
                        break
                    end
                end

                -- 第2棒
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
                for i = maxIndex, 1, -1 do
                    for ii, v in ipairs(tbl) do
                        TJ.SetBoardEditFormNum(v, i, nil, s7, 2)
                        TJ.SetBoardEditFormNum(v, i, nil, ns.s9, 2)
                        TJ.SetBoardEditFormNum(v, i, nil, ns.s8, 2)
                        tremove(tbl, ii)
                        break
                    end
                end
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, nil, true)
                for i = maxIndex, 1, -1 do
                    for ii, v in ipairs(tbl) do
                        TJ.SetBoardEditFormNum(v, i, nil, s1, 2)
                        tremove(tbl, ii)
                        break
                    end
                end
                local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
                for i = 4, 1, -1 do
                    for ii, v in ipairs(tbl) do
                        TJ.SetBoardEditFormNum(v, i, nil, s6, 2)
                        tremove(tbl, ii)
                        break
                    end
                end
                local tbl = TJ.SortRaidRosterInfo({ "MONK" }, "healer", true)
                for i = 4, 1, -1 do
                    for ii, v in ipairs(tbl) do
                        TJ.SetBoardEditFormNum(v, i, nil, ns.s11, 2)
                        tremove(tbl, ii)
                        break
                    end
                end
                local tbl = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, "dps", true)
                for i = 3, 1, -1 do
                    for ii, v in ipairs(tbl) do
                        TJ.SetBoardEditFormNum(v, i, nil, s4, 2)
                        tremove(tbl, ii)
                        break
                    end
                end
            end

            local tbl = {
                {
                    name = L["狂暴第1棒减伤链"],
                    bossSpellID = 1,
                    arrange = 6,
                    icon = "trade_archaeology_whitehydrafigurine",
                    id = 1,
                    spell = spellTbl,
                    event = "SPELL_CAST_SUCCESS",
                    canUpdate = nil,
                    autoNextSpell = nil,
                    startIndex = 1,
                    maxIndex = 6,
                    bossTime = { 8, 8, },
                    special = {
                        id = 2,
                        bossSpellID = 2,
                        time = 9.5,
                    },
                    autoHide = true,
                },
                {
                    name = L["狂暴第2棒减伤链"],
                    bossSpellID = 2,
                    arrange = 6,
                    icon = "trade_archaeology_whitehydrafigurine",
                    id = 2,
                    spell = spellTbl2,
                    event = "SPELL_CAST_SUCCESS",
                    canUpdate = nil,
                    autoNextSpell = nil,
                    startIndex = 1,
                    maxIndex = 6,
                    bossTime = { 10, 10, },
                    autoHide = true,
                },
                AutoFuc = AutoFuc,
            }

            mainFrame.Board_test = function()
                TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
                TJ.Board_info[bossSpellID].canUpdate = true
                TJ.AddTimer(8.5, function()
                    TJ.Board_RunSpecial(bossSpellID)
                end)
            end

            --[[
/run TJ.Board_ENCOUNTER_START("TOT", 5) TJ.frame["TOT"][5].UNIT_DIED(nil,nil,nil,"1",nil,nil,nil,"1-2-3-4-5-70235",nil,nil,nil,116525)
/run TJ.frame["TOT"][5].UNIT_DIED(nil,nil,nil,"1",nil,nil,nil,"1-2-3-4-5-70235",nil,nil,nil,116525)
 ]]

            TJ.CreateBoard(FB, bossIndex, tbl)

            local count = 0
            local bossIDs = {
                { id = 70235, name = L["冰头"] },
                { id = 70212, name = L["火头"] },
                { id = 70247, name = L["毒头"] },
                { id = 70248, name = L["奥头"] },
            }

            mainFrame.Board_ENCOUNTER_START = function(info)
                count = 0
            end
            mainFrame.UNIT_DIED = function(...)
                local tbl = { ... }
                local guid = TJ.GetNPCID(tbl[8])
                if count < 6 then
                    for _, v in ipairs(bossIDs) do
                        if guid == v.id then
                            count = count + 1
                            TJ.Board_info[bossSpellID].canUpdate = true
                            TJ.Board_info[bossSpellID].updateFrame.t = 0
                            TJ.AddTimer(8.5, function()
                                TJ.Board_RunSpecial(bossSpellID)
                                if TJ.Board_info[bossSpellID] then
                                    TJ.Board_info[bossSpellID].index = TJ.Board_info[bossSpellID].index + TJ.Board_info[bossSpellID].step
                                end
                            end)
                            tinsert(TJ.GetNewCombatLog().otherTime, {
                                time = TJ.GetDurTime(),
                                name = v.name,
                            })
                            return
                        end
                    end
                end
            end
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
            nil)
        TJ.CreateEdit(FB, bossIndex, L["左侧BOSS"])
        TJ.CreateEdit(FB, bossIndex, L["右侧BOSS"])
    end

    -- 驱散燃烬
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "DRUID", "PRIEST", "SHAMAN", "MONK" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排一个治疗。"]
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                139822,
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["燃烬（点名）"] },
            },
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                139822,
                            },
                            colorNum = 1
                        }
                    },
                    sourceNpcType = { "Player" },
                },
                title = { name = L["驱散燃烬"] },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, AutoFuc, "inv_misc_volatilefire", L["驱散燃烬"],
            text, TJ.healerClass, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["驱散燃烬"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 换嘲
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 137731, 139843, 139993, 139840, },
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

    -- 寒冰洪流
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 139857, },
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = L["点名"]
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 429386, L["寒冰洪流"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 狂暴
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 139458, },
                            colorNum = 2,
                        },
                    },
                },
            },
        }
        tinsert(info, TJ.combatInfoMore)

        local f = TJ.CreateTitle(FB, bossIndex, nil, "trade_archaeology_whitehydrafigurine", L["狂暴"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    70507,
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_mage_nethertempest", L["转火小怪"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("spell:139458") then
            local newEvent = TJ.GetNewEvent()
            if newEvent then
                newEvent["SPELL_CAST_SUCCESS"] = newEvent["SPELL_CAST_SUCCESS"] or {}
                local tbl = {
                    TJ.GetDurTime(),
                    "SPELL_CAST_SUCCESS",
                    nil,
                    UnitGUID("boss1") or "",
                    nil,
                    nil,
                    nil,
                    "",
                    nil,
                    nil,
                    nil,
                    139458,
                }
                tbl.i = 1
                tinsert(newEvent["SPELL_CAST_SUCCESS"], tbl)
            end
            return
        end
    end
end
