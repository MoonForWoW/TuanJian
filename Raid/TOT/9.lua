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
local bossIndex = 9
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
    local bossSpellID = 139867
    do
        local isload
        local init = function()
            isload = true
            local s1, s2, s3, s4, s5, s6, s7 = ns.s1, ns.s2, ns.s3, ns.s4, ns.s5, ns.s6, ns.s7
            local spellTbl = {
                {
                    title = L["1/9"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["2/10"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["3/11"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["4/12"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["5/13"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["6/14"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["7/15"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["8/16"],
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
                        startIndex = startIndex + 1
                        tremove(tbl, ii)
                        break
                    end
                end
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, nil, true)
                for i = startIndex, maxIndex, 1 do
                    for ii, v in ipairs(tbl) do
                        TJ.SetBoardEditFormNum(v, i, nil, s1)
                        startIndex = startIndex + 1
                        tremove(tbl, ii)
                        break
                    end
                end
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
                for i = startIndex, maxIndex, 1 do
                    for ii, v in ipairs(tbl) do
                        TJ.SetBoardEditFormNum(v, i, nil, s7)
                        startIndex = startIndex + 1
                        tremove(tbl, ii)
                        break
                    end
                end
                local tbl = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, "dps", true)
                for i = startIndex, maxIndex, 1 do
                    for ii, v in ipairs(tbl) do
                        TJ.SetBoardEditFormNum(v, i, nil, s4)
                        startIndex = startIndex + 1
                        tremove(tbl, ii)
                        break
                    end
                end
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
                for i = startIndex, maxIndex, 1 do
                    for ii, v in ipairs(tbl) do
                        if TuanJian.talentInfo[v.name] == 1 then
                            TJ.SetBoardEditFormNum(v, i, nil, s5)
                            startIndex = startIndex + 1
                            tremove(tbl, ii)
                            break
                        end
                    end
                end
                local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
                for i = startIndex, maxIndex, 1 do
                    for ii, v in ipairs(tbl) do
                        TJ.SetBoardEditFormNum(v, i, nil, s6)
                        startIndex = startIndex + 1
                        tremove(tbl, ii)
                        break
                    end
                end
            end

            local tbl = {
                {
                    name = L["震荡干涉减伤链（H模式）"],
                    bossSpellID = bossSpellID,
                    arrange = 3,
                    icon = "spell_nature_lightningoverload",
                    id = 1,
                    spell = spellTbl,
                    event = "SPELL_CAST_SUCCESS",
                    canUpdate = nil,
                    autoNextSpell = true,
                    startIndex = 1,
                    maxIndex = nil,
                    bossTime = { 20, 22, },
                    H = true,
                    autoHide = nil,
                },
                AutoFuc = AutoFuc,
            }

            mainFrame.Board_test = function()
                if TJ.IsH() then
                    TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
                    TJ.Board_info[bossSpellID].canUpdate = true
                    local t = TJ.Board_info[bossSpellID].updateFrame.t
                    local nextTime = TJ.Board_info[bossSpellID].bossTime[1]
                    if t and nextTime and nextTime - t > 10 then
                        TJ.Board_info[bossSpellID].updateFrame.t = nextTime - 10
                    end
                else
                    TJ.StopTestBoard()
                    ns.SendSystemMessage(L["|cffff0000该Boss的战术板需在H模式才能测试。"])
                end
            end
            --[[
/run TJ.Board_ENCOUNTER_START("TOT", 9)
/run TJ.frame["TOT"][9].SPELL_CAST_SUCCESS(nil,nil,nil,"1",nil,nil,nil,"1-2-3-4-5-70235",nil,nil,nil,138644)
/run TJ.Board_SPELL_CAST_SUCCESS(nil,nil,nil,"1",nil,nil,nil,"1-2-3-4-5-70235",nil,nil,nil,139867)
 ]]

            TJ.CreateBoard(FB, bossIndex, tbl)

            mainFrame.SPELL_CAST_SUCCESS = function(...)
                local tbl = { ... }
                local spellID = tbl[12]
                if spellID == 138644 and TJ.IsH() then
                    TJ.AddTimer(2, function()
                        local power = UnitPower("boss1")
                        if (power >= 70 and power < 75)
                        -- or BGDEBUG
                        then
                            TJ.Board_info[bossSpellID].canUpdate = true
                            TJ.Board_info[bossSpellID].updateFrame.t = 0
                        end
                    end)
                end
            end
        end
        tinsert(TJ.boardCallback, init)
        if TJ.boardInited and not isload then init() end
    end

    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 320, -121 } },
            { point = "TOPLEFT", xy = { 177, -59 } },
            { point = "TOPLEFT", xy = { 466, -58 } },
            { point = "TOPLEFT", xy = { 228, -60 } },
            { point = "TOPLEFT", xy = { 413, -58 } },
            { point = "TOPLEFT", xy = { 108, -99 } },
            { point = "TOPLEFT", xy = { 541, -93 } },
            { point = "TOPLEFT", xy = { 108, -150 } },
            { point = "TOPLEFT", xy = { 543, -144 } },
            { point = "TOPLEFT", xy = { 107, -199 } },
            { point = "TOPLEFT", xy = { 543, -194 } },
            { point = "TOPLEFT", xy = { 265, -119 } },
            { point = "TOPLEFT", xy = { 372, -120 } },
            { point = "TOPLEFT", xy = { 159, -231 } },
            { point = "TOPLEFT", xy = { 501, -229 } },
            { point = "TOPLEFT", xy = { 158, -281 } },
            { point = "TOPLEFT", xy = { 501, -284 } },
            { point = "TOPLEFT", xy = { 158, -331 } },
            { point = "TOPLEFT", xy = { 501, -330 } },
            { point = "TOPLEFT", xy = { 105, -369 } },
            { point = "TOPLEFT", xy = { 549, -368 } },
            { point = "TOPLEFT", xy = { 106, -422 } },
            { point = "TOPLEFT", xy = { 550, -424 } },
            { point = "TOPLEFT", xy = { 105, -475 } },
            { point = "TOPLEFT", xy = { 550, -478 } },
            [100] = { xy = { 316, -44 }, isNPC = "b" .. bossIndex },
        }

        --[[


]]
        local xy = {
            { 679, -372 }, -- 星星
            { 676, -322 }, -- 大饼
            { 677, -272 }, -- 紫菱
            { 676, -222 }, -- 三角
            { 678, -174 },
            { 677, -126 },
            { 678, -77 },
            { 677, -27 },
        }
        for index = 1, 8 do
            local left = mod((index - 1) / 4, 1);
            local right = left + 0.25;
            local top = floor((index - 1) / 4) * 0.25;
            local bottom = top + 0.25;
            tbl[index + 80] = {
                xy = xy[index],
                isNPC = true,
                isNPC_help = true,
                isNPC_icon = [[Interface\TargetingFrame\UI-RaidTargetingIcons]],
                coord = { left, right, top, bottom },
                notMask = true,
            }
        end

        local function AutoFuc()
            local tbl = TJ.SortRaidRosterInfo(nil, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, { min = 1, max = 3 })
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, { min = 14, max = 19 })
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "dps", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
        end
        local text = {
            L["1-3：坦克。"],
            L["14-19：治疗。"],
            L["剩余位置：DPS。"],
        }

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local width = 650
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 909 * 750)
        local t = map:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 30, "OUTLINE")
        t:SetPoint("TOPLEFT", 20, -20)
        t:SetText(L["小魔像"])
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
        TJ.CreateEdit(FB, bossIndex, L["左巨型魔像"])
        TJ.CreateEdit(FB, bossIndex, L["右巨型魔像"])
    end

    -- 驱散物质交换
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "DRUID", "PRIEST", "SHAMAN", "MONK" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排治疗。"]
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                138609,
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["物质交换（点名）"] },
            },
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                138609,
                            },
                            colorNum = 1
                        }
                    },
                    sourceNpcType = { "Player" },
                },
                title = { name = L["驱散物质交换"] },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_massteleport", L["驱散物质交换"],
            text, TJ.healerClass, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["驱散物质交换"])
        TJ.CreateEdit(FB, bossIndex, L["驱散物质交换"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 换嘲
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 138569, },
                            colorNum = 2,
                            combatRole = { "Istank" },
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
                    destNPCID = { 69427, 69699 },
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_reincarnation", L["换嘲"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 急速链接
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 138453, },
                            colorNum = 1,
                        },
                    },
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_rewindtime", L["急速链接"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 强化魔像
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 138780, },
                            colorNum = 1,
                        },
                    },
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "warrior_talent_icon_bloodandthunder", L["强化魔像"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 心能之环
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                136962
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                canSend = "count",
                title = { name = L["受到%s伤害"]:format(L["心能之环"]) }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_animusorbs", L["心能之环"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 心能之泉
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                138707
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                canSend = "count",
                title = { name = L["受到%s伤害"]:format(L["心能之泉"]) }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_misc_volatilelife", L["心能之泉"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 震荡干涉
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 138763, 139867, 139869, },
                            colorNum = 2,
                        },
                    },
                },
            },
            {
                interrupt = {
                    type = "d",
                    spell = {
                        {},
                    },
                },
                title = { name = L["玩家被打断"], color = { 1, 0, 0 } }
            },
        }
        tinsert(info, TJ.combatInfoMore)

        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_lightningoverload", L["震荡干涉"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("") then
            return
        end
    end
end
