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
local FB = "MSV"
local bossIndex = 6
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
        local isload
        local init = function()
            isload = true
            local s81, s71 = ns.s81, ns.s71
            local spellTbl = {
                {
                    title = L["1群拉"],
                    class = { "DEATHKNIGHT" },
                    spell =  TJ.Board_TJ7,
                    onlyTitle = true,
                },
                {
                    title = L["2群拉"],
                    class = { "DEATHKNIGHT" },
                    spell =  TJ.Board_TJ7,
                    onlyTitle = true,
                },
            }
            local spellTbl2 = {
                {
                    title = L["1群缠"],
                    class = { "DRUID", },
                    spell = TJ.Board_TJ8 ,
                    onlyTitle = true,
                },
            }
            local spellTbl3 = {
                {
                    title = L["2群缠"],
                    class = { "DRUID", },
                    spell = TJ.Board_TJ8 ,
                    onlyTitle = true,
                },
            }
            local function AutoFuc()
                local tbl = TJ.SortRaidRosterInfo({ "DRUID" }, "dps2", true)
                for i, v in ipairs(TJ.SortRaidRosterInfo({ "DRUID" }, "healer", true)) do
                    tinsert(tbl, v)
                end
                for i, v in ipairs(TJ.SortRaidRosterInfo({ "DRUID" }, "dps1", true)) do
                    tinsert(tbl, v)
                end
                local done = {}
                for i, v in ipairs(tbl) do
                    if not done[1] then
                        TJ.SetBoardEditFormNum(v, 1, 1, s81, 2)
                        done[1] = true
                    elseif not done[2] then
                        TJ.SetBoardEditFormNum(v, 1, 1, s81, 3)
                        done[2] = true
                    end
                end
                local tbl = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, "dps", true)
                local done = {}
                for i, v in ipairs(tbl) do
                    if not done[3] then
                        TJ.SetBoardEditFormNum(v, 1, 1, s71)
                        done[3] = true
                    elseif not done[4] then
                        TJ.SetBoardEditFormNum(v, 2, 1, s71)
                        done[4] = true
                    end
                end
            end

            local cd1 = 17
            local cd2 = 33.5
            local speTime = 20
            local tbl = {
                {
                    name = L["小怪群拉"],
                    bossSpellID = 1,
                    arrange = 1,
                    icon = "ability_deathknight_aoedeathgrip",
                    id = 1,
                    spell = spellTbl,
                    event = "SPELL_CAST_SUCCESS",
                    canUpdate = true,
                    autoNextSpell = nil,
                    startIndex = 1,
                    maxIndex = 18,
                    bossTime = {
                        cd1, cd2, cd2,
                        35, cd2, cd2,
                        80, cd2, cd2,
                        80, cd2, cd2,
                        80, cd2, cd2,
                        40, cd2, cd2,
                    },
                },
                {
                    name = L["小怪1群缠"],
                    bossSpellID = 2,
                    arrange = 1,
                    icon = "spell_druid_massentanglement",
                    id = 2,
                    spell = spellTbl2,
                    event = "SPELL_CAST_SUCCESS",
                    canUpdate = true,
                    autoNextSpell = nil,
                    startIndex = 1,
                    maxIndex = 22,
                    bossTime = {
                        cd1, cd2, cd2,
                        35, cd2, cd2, 40,
                        40, cd2, cd2, 40,
                        40, cd2, cd2, 40,
                        40, cd2, cd2, 40,
                        40, cd2, cd2,
                    },
                    special = {
                        id = 3,
                        arrange = 1,
                        bossSpellID = 3,
                        time = speTime,
                    },
                    ["timeEndNextSpell" .. 7] = true,
                    ["timeEndNextSpell" .. 11] = true,
                    ["timeEndNextSpell" .. 15] = true,
                    ["timeEndNextSpell" .. 19] = true,
                },
                {
                    name = L["小怪2群缠"],
                    bossSpellID = 3,
                    arrange = 1,
                    icon = "spell_druid_massentanglement",
                    id = 3,
                    spell = spellTbl3,
                    event = "SPELL_CAST_SUCCESS",
                    canUpdate = nil,
                    autoNextSpell = nil,
                    startIndex = 1,
                    bossTime = { cd1 + speTime, cd2 },
                    notSetInfo = true,
                },
                AutoFuc = AutoFuc,
            }

            TJ.CreateBoard(FB, bossIndex, tbl)

            --[[
16
53
1.25

1.58
2.31
3.07

*3.47

4.27
4.59
5.35

*6.15

6.55
7.31
8.04

*8.44

9.27
10.00
10.37

11.18
11.50
            ]]
            local bossSpellID = 116525

            local guids = {}
            local lastTime = 0

            mainFrame.Board_ENCOUNTER_START = function(info)
                wipe(guids)
                lastTime = 0
            end

            -- 如果获得专注DEBUFF，则进入下一轮
            mainFrame.Board_SPELL_AURA_APPLIED = function(info, ...)
                local tbl = { ... }
                local guid = tbl[4]
                local spellID = tbl[12]
                if spellID == bossSpellID and not guids[guid] then
                    guids[guid] = true
                    if GetTime() - lastTime >= 5 then
                        lastTime = GetTime()
                        for id = 1, 2 do
                            TJ.Board_NextSpell(id)
                        end
                    end
                end
            end

            mainFrame.Board_test = function()
                TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
                TJ.Board_info[1].updateFrame.t = 7
                TJ.Board_info[2].updateFrame.t = 7
            end

            --[[
/run TJ.Board_ENCOUNTER_START("MSV", 6)
/run TJ.Board_SPELL_AURA_APPLIED(nil,nil,nil,"1",nil,nil,nil,nil,nil,nil,nil,116525)
/run TJ.Board_SPELL_AURA_APPLIED(nil,nil,nil,"2",nil,nil,nil,nil,nil,nil,nil,116525)
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
        TJ.CreateEdit(FB, bossIndex, L["剑羲（左侧）"])
        TJ.CreateEdit(FB, bossIndex, L["秦希（右侧）"])
    end
    -- 接大锤
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "WARRIOR", "PALADIN" }, "dps", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排战士、惩戒骑"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "inv_hammer_09", L["接大锤"],
            text, nil, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["左侧"])
        TJ.CreateEdit(FB, bossIndex, L["右侧"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 跳舞
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                116835, 116969, 132425,
                            },
                            colorNum = 1
                        },
                    },
                },
                title = { name = L["跳舞没躲开"] }
            },
            {
                damageHarm = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                116809
                            },
                            colorNum = 1
                        },
                    },
                },
                notShowDead = true,
                canSend = "count",
                title = { name = L["投机打击"], icon = 116809 }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warstomp", L["跳舞"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 造物之能
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            116805,
                        },
                        colorNum = 1
                    },
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_lightningoverload", L["造物之能"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转火盾兵
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    60398,
                },
            },
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_defend", L["转火盾兵"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转火大锤
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    60768, 60397
                },
            },
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_hammer_09", L["转火大锤"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 控制小怪
    do
        local info = {
            castSuccess = {
                type = "s",
                spell = {
                    {
                        spellID = { 102359, },
                        colorNum = 1,
                    },
                    {
                        spellID = { 108199 },
                        colorNum = 2,
                    },
                },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_druid_massentanglement", L["控制小怪"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
end
