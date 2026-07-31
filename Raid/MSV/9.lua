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
    local bossSpellID = 122774
    local canUpdateBoard = true
    -- 战术板
    do
        local isload
        local init = function()
            isload = true
            local s1, s2, s3, s4, s5, s6, s7, s8 = ns.s1, ns.s2, ns.s3, ns.s4, ns.s5, ns.s6, ns.s7, ns.s8
            local spellTbl = {
                {
                    title = L["1/6"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["2/7"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["3/8"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["4/9"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["5/10"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
            }
            local function AutoFuc()
                local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, nil, true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s2)
                    TJ.SetBoardEditFormNum(v, i, nil, s3)
                end

                local startIndex = #tbl + 1
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = startIndex, 5, 1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s7)
                            done[i] = true
                            break
                        end
                    end
                end
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
                for i, v in ipairs(tbl) do
                    for i = startIndex, 5, 1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s6)
                            done[i] = true
                            break
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = 5, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s1)
                            done[i] = true
                            break
                        end
                    end
                end
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
                for i, v in ipairs(tbl) do
                    if TuanJian.talentInfo[v.name] == 1 then
                        for i = 5, 1, -1 do
                            if not done[i] then
                                TJ.SetBoardEditFormNum(v, i, nil, s5)
                                done[i] = true
                                break
                            end
                        end
                    end
                end
            end

            local tbl = {
                {
                    name = L["重碾减伤链（H模式）"],
                    bossSpellID = 122774,
                    arrange = 6,
                    icon = "spell_shaman_earthquake",
                    id = 1,
                    spell = spellTbl,
                    event = "SPELL_CAST_SUCCESS",
                    canUpdate = true,
                    autoNextSpell = false,
                    startIndex = 1,
                    bossTime = { 32, 36, },
                    H = true,
                },
                AutoFuc = AutoFuc,
            }

            mainFrame.Board_SPELL_CAST_SUCCESS = function(info, ...)
                if canUpdateBoard then
                    local tbl = { ... }
                    local spellID = tbl[12]
                    if spellID == bossSpellID then
                        local index = info[bossSpellID].index
                        local bossTime = info[bossSpellID].bossTime
                        local nextTime = bossTime[index] or bossTime[#bossTime]
                        if info[bossSpellID].updateFrame.t >= nextTime - 2 then
                            TJ.Board_NextSpell(bossSpellID)
                        end
                    end
                end
            end
            mainFrame.Board_ENCOUNTER_START = function(info)
                canUpdateBoard = true
            end

            mainFrame.Board_test = function()
                if TJ.IsH() then
                    TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
                    TJ.Board_info[bossSpellID].updateFrame.t = 22
                else
                    TJ.StopTestBoard()
                    ns.SendSystemMessage(L["|cffff0000该Boss的战术板需在H模式才能测试。"])
                end
            end

            TJ.CreateBoard(FB, bossIndex, tbl)
            --[[
/run TJ.Board_ENCOUNTER_START("HOF", 3)
/run TJ.Board_SPELL_CAST_SUCCESS(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,122774)
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
            nil)
        TJ.CreateEdit(FB, bossIndex, L["主坦克"])
        TJ.CreateEdit(FB, bossIndex, L["副坦克"])
    end

    -- 治疗信息素
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排一个治疗。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_holy_holybolt", L["治疗信息素"],
            text, TJ.healerClass, nil, nil, nil,
            nil)
        TJ.CreateEdit(FB, bossIndex, L["治疗信息素"])
    end

    -- 吃信息素
    do
        local function AutoFuc(title)
            TJ.SetEditTextFormNum(title.list[4], title, 1)
            TJ.SetEditTextFormNum(title.list[3], title, 2)
            TJ.SetEditTextFormNum(title.list[2], title, 3)
            TJ.SetEditTextFormNum(title.list[5], title, 4)
            TJ.SetEditTextFormNum(title.list[1], title, 5)
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 123081, },
                    },
                },
            }
        }
        local text = L["安排4队=>3队=>2队=>5队=>1队。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, 136044, L["吃信息素"],
            text, TJ.tankClass, nil, info, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["1吃"], nil, TJ.teamList)
        TJ.CreateEdit(FB, bossIndex, L["2吃"], nil, TJ.teamList)
        TJ.CreateEdit(FB, bossIndex, L["3吃"], nil, TJ.teamList)
        TJ.CreateEdit(FB, bossIndex, L["4吃"], nil, TJ.teamList)
        TJ.CreateEdit(FB, bossIndex, L["5吃"], nil, TJ.teamList)
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 狂怒
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 122754, },
                        },
                    },
                    destNPCID = { 62164 },
                    showCount=true,
                },
                canSend = "count",
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 122735, },
                        },
                    },
                    destNpcType = { "Player" }
                },
                title = { name = L["受到横扫伤害"] },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_druid_ravage", L["狂怒"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 横扫
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = { 122735, },
                    },
                },
                destNpcType = { "Player" }
            },
            title = { name = L["受到横扫伤害"] },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_druid_ravage", L["横扫"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 重碾
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 122774, },
                            colorNum = 2,
                        },
                    },
                },
                trigger = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                122774,
                            },
                            colorNum = 1,
                            tooltipText = TJ.AddIconBySpellID(122774) .. L["进紫圈触发重碾"],
                        },
                    },
                    showCount = true,
                },
                notShowDead = true,
            },
            isMany = true,
        }
        tinsert(info, TJ.combatInfoMore)

        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shaman_earthquake", L["重碾"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 进紫圈
    do
        local info = {
            trigger = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            122774,
                        },
                        colorNum = 1,
                        tooltipText = TJ.AddIconBySpellID(122774) .. L["进紫圈触发重碾"],
                    },
                },
                showCount = true,
            },
            notShowDead = true,
        }

        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shaman_earthquake", L["进紫圈"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 腿部伤害
    do
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        63053
                    },
                },
                canSend = "dps",
                title = { name = L["腿部伤害"] }
            },
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        63191
                    },
                },
                canSend = "dps",
                title = { name = L["Boss本体伤害"] }
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_deathknight_brittlebones", L["伤害排名"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.BOSS_SAY = function(msg, _, _, _, player)
        if msg:find("spell:122774") and player then
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
                    122774,
                    L["重碾"],
                }
                tbl.i = 1
                tinsert(TJ.GetNewEvent()["TRIGGER"], tbl)
            end
            return
        end
        if msg:match("巨型盔甲开始") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
            canUpdateBoard = false
            TJ.Board_HideNextSpell(bossSpellID)
            return
        end
    end
end
