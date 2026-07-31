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
local bossIndex = 2
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
    local bossSpellID = 122994
    -- 战术板
    do
        local isload
        local init = function()
            isload = true
            local s1, s2, s3, s4, s5, s6, s7, s8 = ns.s1, ns.s2, ns.s3, ns.s4, ns.s5, ns.s6, ns.s7, ns.s8
            local spellTbl = {
                {
                    title = L["1/4"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["2/5"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["3/6"],
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

                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s7)
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
                for i, v in ipairs(tbl) do
                    for i = 3, 1, -1 do
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
                    for i = 3, 1, -1 do
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
                        for i = 3, 1, -1 do
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
                    name = L["无影击减伤链"],
                    bossSpellID = 122994,
                    arrange = 6,
                    icon = "ability_rogue_vigor",
                    id = 1,
                    spell = spellTbl,
                    event = "SPELL_CAST_SUCCESS",
                    canUpdate = true,
                    autoNextSpell = false,
                    startIndex = 1,
                    bossTime = { 35, 60, },
                },
                AutoFuc = AutoFuc,
            }

            mainFrame.Board_test = function()
                TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
                TJ.Board_info[bossSpellID].updateFrame.t = 25
            end

            TJ.CreateBoard(FB, bossIndex, tbl)

            local cd
            local function func(...)
                if cd then return end
                local tbl = { ... }
                local spellID = tbl[12]
                if spellID == bossSpellID then
                    TJ.Board_NextSpell(bossSpellID)
                    cd = true
                    After(5, function()
                        cd = nil
                    end)
                end
            end

            mainFrame.SPELL_DAMAGE = func
            mainFrame.SPELL_MISSED = func
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

    -- 狂奔怒吼
    do
        local function AutoFuc(title)
            local count = 0
            for _, role in ipairs({ "tank", "dps1", "dps2", "healer" }) do
                local tbl = TJ.SortRaidRosterInfo({ "DRUID", }, role, true)
                for i, v in ipairs(tbl) do
                    count = count + 1
                    TJ.SetEditText(v, title)
                end
            end
            if count > 0 then
                local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, "dps", true)
                for i, v in ipairs(tbl) do
                    if i > count then break end
                    TJ.SetEditText(v, title)
                end
            end
        end
        local info = {
            castSuccess = {
                type = "s",
                spell = {
                    {
                        spellID = ns.sp["狂奔"],
                    },
                },
            },
            notShowDead = true,
            title = { name = L["施放狂奔怒吼"] }
        }
        local text = L["安排小德。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_druid_stampedingroar_cat", L["狂奔怒吼"],
            text, { "DRUID", "WARRIOR" }, nil, info, nil,
            nil)
        TJ.CreateEdit(FB, bossIndex, L["1狂奔"])
        TJ.CreateEdit(FB, bossIndex, L["2狂奔"])
        TJ.CreateEdit(FB, bossIndex, L["3狂奔"])
        TJ.CreateEdit(FB, bossIndex, L["4狂奔"])
        TJ.CreateEdit(FB, bossIndex, L["5狂奔"])
        TJ.CreateEdit(FB, bossIndex, L["6狂奔"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 疾风
    do
        local info = {
            {
                castSuccess = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 123175, },
                            colorNum = 2,
                        },
                    },
                    destNpcType = { "Player" },
                },
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 123180, },
                        },
                    },
                    destNpcType = { "Player" },
                }
            },
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = ns.sp["保护"],
                        },
                    },
                },
                title = { name = L["给保护"], icon = 1022 }
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_frost_windwalkon", L["疾风"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 乱刃风暴
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 125310, },
                            colorNum = 2,
                        },
                    },
                },
                title = { name = L["Boss施放乱刃风暴"] }
            },
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = ns.sp["狂奔"],
                        },
                    },
                },
                notShowDead = true,
                title = { name = L["施放狂奔怒吼"], icon = 106898 }
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 125312, },
                        },
                    },
                },
                title = { name = L["受到乱刃风暴伤害"] },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_whirlwind", L["乱刃风暴"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 无影击
    do
        local info = {
            {
                trigger = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                123017,
                            },
                            colorNum = 2,
                            tooltipText = TJ.AddIconBySpellID(123017) .. L["被标记为无影击目标"],
                        },
                    },
                },
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                122994,
                            },
                            colorNum = 1
                        },
                    },
                },
            },
            isMany = true,
        }
        tinsert(info, TJ.combatInfoMore)

        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_hunter_markedfordeath", L["无影击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 换嘲
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 123474 },
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
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warrior_unrelentingassault", L["换嘲"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.BOSS_SAY = function(msg, _, _, _, player)
        if msg:find("spell:122949") and player then
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
                    123017,
                    L["无影击"],
                }
                tbl.i = 1
                tinsert(TJ.GetNewEvent()["TRIGGER"], tbl)
            end
            return
        end
    end
    mainFrame.UNIT_SPELLCAST_SUCCEEDED = function(unit, spellID)
        if unit:match("boss") and spellID == 123814 and not TJ.SetCD(mainFrame, 2, spellID) then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
            TJ.Board_HideNextSpell(bossSpellID)
        end
    end
end
