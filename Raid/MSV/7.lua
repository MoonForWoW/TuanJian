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
    local bossSpellID = 122713
    do
        local isload
        local init = function()
            isload = true
            local s1, s2, s3, s4, s5, s6, s7 = ns.s1, ns.s2, ns.s3, ns.s4, ns.s5, ns.s6, ns.s7
            local spellTbl = {
                {
                    title = L["第1"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["第2"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["第3"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
            }
            local function AutoFuc()
                -- 1-2
                local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, nil, true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s2)
                    TJ.SetBoardEditFormNum(v, i, nil, s3)
                end
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s7)
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s9)
                end
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s1)
                end
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, TuanJian.talentInfo[v.name] == 1 and s5 or ns.s13)
                end

                -- 2-3
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
                for i, v in ipairs(tbl) do
                    for i = 2, 3, 1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s6)
                            done[i] = true
                            break
                        end
                    end
                end
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "MONK" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = 2, 3, 1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s11)
                            done[i] = true
                            break
                        end
                    end
                end
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "DRUID" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = 2, 3, 1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s12)
                            done[i] = true
                            break
                        end
                    end
                end

                -- 3
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "dps", true)
                for i, v in ipairs(tbl) do
                    for i = 3, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s9)
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s10)
                            done[i] = true
                            break
                        end
                    end
                end
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "dps", true)
                for i, v in ipairs(tbl) do
                    for i = 3, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s14)
                            done[i] = true
                            break
                        end
                    end
                end
            end

            local tbl = {
                {
                    name = L["力与魄减伤链"],
                    bossSpellID = bossSpellID,
                    arrange = 6,
                    icon = "warrior_disruptingshout",
                    id = 1,
                    spell = spellTbl,
                    event = "SPELL_CAST_START",
                    canUpdate = nil,
                    autoNextSpell = nil,
                    startIndex = 1,
                    maxIndex = 3,
                    bossTime = { 2, 2, },
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
                    After(0,function ()
                        info[bossSpellID].index = info[bossSpellID].index + info[bossSpellID].step
                    end)
                end
            end

            TJ.CreateBoard(FB, bossIndex, tbl)
            --[[
/run TJ.Board_ENCOUNTER_START("HOF", 1)
/run TJ.Board_SPELL_CAST_START(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,122713)
/run TJ.Board_SPELL_CAST_SUCCESS(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,122713)
/run TJ.Board_info[122713].index = 1
 ]]
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
        TJ.CreateEdit(FB, bossIndex, L["回响"])
    end
    -- 2台子治疗
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "healer", true)
            for i = 1, 2 do
                for i, v in ipairs(tbl) do
                    if v.class == "PALADIN" then
                        TJ.SetEditText(v, title)
                        tremove(tbl, i)
                        break
                    end
                end
            end
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["优先安排奶骑，其次其他治疗。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_holy_holybolt", L["2台子治疗"],
            text, TJ.healerClass, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L[""])
        TJ.CreateEdit(FB, bossIndex, L[""])
    end

    -- 3台子治疗
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "healer", true)
            for i = 1, 2 do
                for i, v in ipairs(tbl) do
                    if v.class == "PALADIN" then
                        TJ.SetEditText(v, title)
                        tremove(tbl, i)
                        break
                    end
                end
            end
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["优先安排奶骑，其次其他治疗。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_holy_holybolt", L["3台子治疗"],
            text, TJ.healerClass, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L[""])
        TJ.CreateEdit(FB, bossIndex, L[""])
        TJ.CreateEdit(FB, bossIndex, L[""])
    end

    -- 3台子DPS
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN", "DRUID", "MAGE", "WARLOCK", "PRIEST" }, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排法系DPS。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_arcane_mindmastery", L["3台子DPS"],
            text, nil, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L[""])
        TJ.CreateEdit(FB, bossIndex, L[""])
        TJ.CreateEdit(FB, bossIndex, L[""])
        TJ.CreateEdit(FB, bossIndex, L[""])
        TJ.CreateEdit(FB, bossIndex, L[""])
        TJ.CreateEdit(FB, bossIndex, L[""])
        TJ.CreateEdit(FB, bossIndex, L[""])
        TJ.CreateEdit(FB, bossIndex, L[""])
        TJ.CreateEdit(FB, bossIndex, L[""])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 力与魂
    do
        local info = {
            {
                aura = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 122713, },
                            colorNum = 2,
                        },
                    },
                },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                122706
                            },
                            colorNum = 1
                        },
                    },
                },
                notShowDead = true,
                title = { name = L["噪音取消"], icon = "warrior_talent_icon_deadlycalm" },
                showRaidMember = L["缺少噪音取消BUFF"],
            },
            isMany = true,
        }
        tinsert(info, 2, TJ.combatInfoMore)

        local f = TJ.CreateTitle(FB, bossIndex, nil, "warrior_disruptingshout", L["力与魂"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 音波
    do
        local info = {
            {
                aura = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                122479,
                                -- 122497,
                                -- 122496,
                                127834 },
                            colorNum = 2,
                        },
                    },
                },
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                122336, 124673
                            },
                            colorNum = 1
                        },
                    },
                },
                canSend = "count",
                title = { name = L["受到音波伤害"] }
            },
        }

        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_vehicle_sonicshockwave", L["音波"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 策反
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            122740
                        },
                        colorNum = 1
                    },
                },
            },
            title = L["点名"]
        }

        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_arcane_mindmastery", L["策反"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 吐气
    --[[     do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 122761, },
                        colorNum = 2,
                    },
                },
            },
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            122760
                        },
                        colorNum = 1
                    },
                },
            },
        }

        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_psychicscream", L["吐气"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end ]]

    -- P2BOSS本体伤害排名
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    62980,
                },
                startTime = "40%",
                endTime = "duration",
            },
            title = { name = L["BOSS本体伤害排名(P2)"] }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warrior_battleshout", L["伤害排名(P2)"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    local event = "UNIT_HEALTH"
    local saved = {}
    local tbl = { .8, .6, .4 }
    local f = CreateFrame("Frame")
    f:SetScript("OnEvent", function(self, event, unit, ...)
        if unit:match("boss") then
            if TJ.GetNPCID(UnitGUID(unit)) == 62980 then
                for _, num in ipairs(tbl) do
                    if UnitHealth(unit) / UnitHealthMax(unit) <= num and not saved[num] then
                        saved[num] = true
                        tinsert(TJ.GetNewCombatLog().otherTime, {
                            time = TJ.GetDurTime(),
                            name = (num * 100) .. "%",
                        })
                        if num == .4 then
                            TJ.Board_info[bossSpellID].index = 1
                        end
                        return
                    end
                end
            end
        end
    end)
    TJ.frame[FB][bossIndex].ENCOUNTER_START = function()
        f:RegisterEvent(event)
        wipe(saved)
    end
    TJ.frame[FB][bossIndex].ENCOUNTER_END = function()
        f:UnregisterEvent(event)
    end
end
