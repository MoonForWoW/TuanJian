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
local bossIndex = 13
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
                    title = L["1/3"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["2/4"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
            }
            local function AutoFuc()
                local maxIndex = #spellTbl
                local startIndex = 1

                local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, nil, true)
                for i = startIndex, maxIndex, 1 do
                    for ii, v in ipairs(tbl) do
                        TJ.SetBoardEditFormNum(v, i, nil, s2)
                        TJ.SetBoardEditFormNum(v, i, nil, s3)
                        tremove(tbl, ii)
                        break
                    end
                end

                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, nil, true)
                for i = startIndex, maxIndex, 1 do
                    for ii, v in ipairs(tbl) do
                        TJ.SetBoardEditFormNum(v, i, nil, s1)
                        tremove(tbl, ii)
                        break
                    end
                end
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
                for i = startIndex, maxIndex, 1 do
                    for ii, v in ipairs(tbl) do
                        TJ.SetBoardEditFormNum(v, i, nil, s7)
                        tremove(tbl, ii)
                        break
                    end
                end
            end

            local tbl = {
                {
                    name = L["释放的生命减伤链"],
                    bossSpellID = bossSpellID,
                    arrange = 7,
                    icon = "spell_fire_bluefirenova",
                    id = 1,
                    spell = spellTbl,
                    event = "SPELL_CAST_START",
                    canUpdate = true,
                    autoNextSpell = nil,
                    startIndex = 1,
                    bossTime = { 16, 10, },
                    autoHide = nil,
                },
                AutoFuc = AutoFuc,
            }

            mainFrame.Board_test = function()
                TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
                local t = TJ.Board_info[bossSpellID].updateFrame.t
                local nextTime = TJ.Board_info[bossSpellID].bossTime[1]
                if t and nextTime and nextTime - t > 10 then
                    TJ.Board_info[bossSpellID].updateFrame.t = nextTime - 10
                end
            end
            --[[
/run TJ.Board_ENCOUNTER_START("TOT", 13)
/run TJ.frame["TOT"][13].SPELL_CAST_SUCCESS(nil,nil,nil,"1",nil,nil,nil,"1-2-3-4-5-70235",nil,nil,nil,138330)
/run TJ.frame["TOT"][13].SPELL_CAST_START(nil,nil,nil,"1",nil,nil,nil,"1-2-3-4-5-70235",nil,nil,nil,138321)
 ]]

            local count = -1
            mainFrame.Board_ENCOUNTER_START = function(info)
                count = -1
            end
            mainFrame.SPELL_CAST_START = function(...)
                local tbl = { ... }
                local spellID = tbl[12]
                if spellID == 138321 then
                    count = count + 1
                    if count == 3 then
                        count = 0
                        TJ.Board_info[bossSpellID].canUpdate = true
                        TJ.Board_info[bossSpellID].updateFrame.t = 0
                    end
                end
            end
            mainFrame.SPELL_CAST_SUCCESS = function(...)
                local tbl = { ... }
                local spellID = tbl[12]
                if spellID == 138330 then
                    TJ.Board_HideNextSpell(bossSpellID)
                end
            end

            mainFrame.UNIT_SPELLCAST_SUCCEEDED = function(_, spellID)
                if spellID == 139073 and not TJ.SetCD(mainFrame, 2, spellID) then
                    TJ.Board_HideBar(bossSpellID)
                    tinsert(TJ.GetNewCombatLog().otherTime, {
                        time = TJ.GetDurTime(),
                        name = "P2",
                    })
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

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- BOSS增益
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 138450, },
                            colorNum = 1,
                        },
                    },
                    destNPCID = { 69473 },
                },
                title = { name = L["残存能量（每层伤害提高10%）"], icon = 138450 }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 138332, },
                            colorNum = 1,
                        },
                    },
                },
                title = { name = L["灌输生命"], icon = 138332 }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 138331, },
                            colorNum = 1,
                        },
                    },
                },
                title = { name = L["灌输心能"], icon = 138331 }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 139072, },
                            colorNum = 1,
                        },
                    },
                },
                title = { name = L["腐化生命（每层伤害提高10%）"], icon = 139072 }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 139071, },
                            colorNum = 1,
                        },
                    },
                },
                title = { name = L["腐化心能（每层生命提高10%）"], icon = 139071 }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_focusedmind", L["BOSS增益"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 不稳定的生命
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 138297, },
                            colorNum = 2,
                        },
                        {
                            spellID = { 138308 },
                            colorNum = 1,
                        },
                    },
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_lightningbolt", L["传电"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 炙燃耀斑
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                138337
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                canSend = "count",
                title = { name = L["受到%s伤害"]:format(L["炙燃耀斑"]) }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_lightningoverload", L["炙燃耀斑"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 释放的生命
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 138330 },
                            colorNum = 2,
                        },
                    },
                },
            },
        }
        tinsert(info, TJ.combatInfoMore)

        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_bluefirenova", L["释放的生命"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火龟裂
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    69872
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_elemental_primal_air", L["转火龟裂"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火腐化心能
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    69869, -- 心能精华
                    69870, -- 生命精华
                    -- 69957, -- 腐化心能
                    -- 69958, -- 腐化生命
                },
                startTime = 0,
                endTime = 'P2',
                endTime2 = "duration",
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_elemental_primal_fire", L["P1转球"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
end
