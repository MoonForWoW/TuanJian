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
local bossIndex = 12
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

    local count = 0
    local isP3
    mainFrame.ENCOUNTER_START = function(...)
        count = 0
        isP3 = nil
    end
    mainFrame.SPELL_CAST_START = function(...) -- 进入转阶段的施法
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == 137045 then
            count = count + 1
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = count == 1 and "P1.5" or "P2.5",
            })
        end
    end
    mainFrame.BOSS_SAY = function(msg) -- 转阶段结束后的喊话
        if msg:match("spell:137176") then
            isP3 = count > 1
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = count == 1 and "P2" or "P3",
            })
            return
        end
    end

    -- 战术板
    local bossSpellID = 135095
    TJ.AddBoard(mainFrame, function()
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
            {
                title = L["第4"],
                class = nil,
                spell = TJ.Board_TJ1
            },
        }
        local spellTbl2 = {
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
            {
                title = L["第4"],
                class = nil,
                spell = TJ.Board_TJ1
            },
            {
                title = L["第5"],
                class = nil,
                spell = TJ.Board_TJ1
            },
        }

        local function AutoFuc()
            -- P1
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
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "dps", true)
            for i = startIndex, maxIndex, 1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s9)
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s10)
                    tremove(tbl, ii)
                    break
                end
            end

            local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
            for i = 2, maxIndex, 1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s6)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, "dps", true)
            for i = 2, maxIndex, 1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s4)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "MONK" }, "healer", true)
            for i = 2, maxIndex, 1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s11)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
            for i = 3, maxIndex, 1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, TuanJian.talentInfo[v.name] == 1 and s5 or ns.s13)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "dps", true)
            for i = 3, maxIndex, 1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s14)
                    tremove(tbl, ii)
                    break
                end
            end

            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
            for i = maxIndex, startIndex, -1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s7)
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s9)
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s8)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "DRUID" }, "healer", true)
            for i = maxIndex, startIndex, -1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s12)
                    tremove(tbl, ii)
                    break
                end
            end

            -- P3
            local maxIndex = #spellTbl2
            local startIndex = 1

            local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, nil, true)
            for i = startIndex, maxIndex, 1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s2, 2)
                    TJ.SetBoardEditFormNum(v, i, nil, s3, 2)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, nil, true)
            for i = startIndex, maxIndex, 1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s1, 2)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "dps", true)
            for i = startIndex, maxIndex, 1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s9, 2)
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s10, 2)
                    tremove(tbl, ii)
                    break
                end
            end

            local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
            for i = 2, maxIndex, 1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s6, 2)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, "dps", true)
            for i = 3, maxIndex, 1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s4, 2)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "MONK" }, "healer", true)
            for i = 3, maxIndex, 1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s11, 2)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
            for i = 4, maxIndex, 1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, TuanJian.talentInfo[v.name] == 1 and s5 or ns.s13, 2)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "dps", true)
            for i = 4, maxIndex, 1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s14, 2)
                    tremove(tbl, ii)
                    break
                end
            end

            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
            for i = maxIndex, startIndex, -1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s7, 2)
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s9, 2)
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s8, 2)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "DRUID" }, "healer", true)
            for i = maxIndex, startIndex, -1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s12, 2)
                    tremove(tbl, ii)
                    break
                end
            end
        end

        local tbl = {
            {
                name = L["P1雷霆打击"],
                bossSpellID = 1,
                arrange = 6,
                icon = "ability_thunderking_thunderstruck",
                id = 1,
                spell = spellTbl,
                event = "SPELL_CAST_START",
                canUpdate = nil,
                autoNextSpell = nil,
                startIndex = 1,
                maxIndex = #spellTbl,
                bossTime = { 3.5, 3.5, },
                autoHide = true,
            },
            {
                name = L["P3雷霆打击"],
                bossSpellID = 2,
                arrange = 6,
                icon = "ability_thunderking_thunderstruck",
                id = 2,
                spell = spellTbl2,
                event = "SPELL_CAST_START",
                canUpdate = nil,
                autoNextSpell = nil,
                startIndex = 1,
                maxIndex = #spellTbl2,
                bossTime = { 3.5, 3.5, },
                autoHide = true,
            },
            AutoFuc = AutoFuc,
        }
        --[[
/run m=TJ.frame["TOT"][12] TJ.Board_ENCOUNTER_START("TOT", 12)
/run m.SPELL_CAST_START(nil,nil,nil,"1",nil,nil,nil,"",nil,nil,nil,137045) m.BOSS_SAY("spell:137176")

/run m=TJ.frame["TOT"][12] TJ.Board_ENCOUNTER_START("TOT", 12) m.SPELL_CAST_START(nil,nil,nil,"1",nil,nil,nil,"",nil,nil,nil,137045) m.SPELL_CAST_START(nil,nil,nil,"1",nil,nil,nil,"",nil,nil,nil,137045) m.BOSS_SAY("spell:137176")
/run TJ.Board_SPELL_CAST_START(nil,nil,nil,"1",nil,nil,nil,"1-2-3-4-5-70235",nil,nil,nil,135095)
 ]]
        mainFrame.Board_test = function()
            TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
            TJ.Board_info[1].canUpdate = true
        end
        mainFrame.Board_SPELL_CAST_START = function(info, ...)
            local tbl = { ... }
            local spellID = tbl[12]
            if spellID == bossSpellID then
                local id = isP3 and 2 or 1
                TJ.Board_info[id].canUpdate = true
                TJ.Board_info[id].updateFrame.t = 0
                After(0, function()
                    info[id].index = info[id].index + info[id].step
                end)
            end
        end

        TJ.CreateBoard(FB, bossIndex, tbl)
    end)

    -- P1.5站位图
    local function CreateText(map)
        local t = map:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 20, "OUTLINE")
        t:SetPoint("BOTTOMLEFT", map, "BOTTOMRIGHT", 5, 0)
        t:SetJustifyH("LEFT")
        t:SetText(L["北部导管：静电冲击\n东部导管：散射闪电链\n南部导管：超载\n西部导管：弹跳闪电"])

        local offset = 5
        local t = map:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 20, "OUTLINE")
        t:SetPoint("TOPLEFT", offset, -offset)
        t:SetText(L["北"])
        local t = map:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 20, "OUTLINE")
        t:SetPoint("TOPRIGHT", -offset, -offset)
        t:SetText(L["东"])
        local t = map:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 20, "OUTLINE")
        t:SetPoint("BOTTOMLEFT", offset, offset)
        t:SetText(L["西"])
        local t = map:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 20, "OUTLINE")
        t:SetPoint("BOTTOMRIGHT", -offset, offset)
        t:SetText(L["南"])
    end
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 506, -71 } },
            { point = "TOPLEFT", xy = { 429, -69 } },
            { point = "TOPLEFT", xy = { 508, -137 } },
            { point = "TOPLEFT", xy = { 368, -116 } },
            { point = "TOPLEFT", xy = { 414, -166 } },
            { point = "TOPLEFT", xy = { 458, -210 } },
            { point = "TOPLEFT", xy = { 512, -476 } },
            { point = "TOPLEFT", xy = { 443, -482 } },
            { point = "TOPLEFT", xy = { 512, -401 } },
            { point = "TOPLEFT", xy = { 364, -424 } },
            { point = "TOPLEFT", xy = { 421, -378 } },
            { point = "TOPLEFT", xy = { 464, -332 } },
            { point = "TOPLEFT", xy = { 93, -482 } },
            { point = "TOPLEFT", xy = { 94, -406 } },
            { point = "TOPLEFT", xy = { 161, -477 } },
            { point = "TOPLEFT", xy = { 138, -329 } },
            { point = "TOPLEFT", xy = { 191, -380 } },
            { point = "TOPLEFT", xy = { 241, -425 } },
            { point = "TOPLEFT", xy = { 99, -66 } },
            { point = "TOPLEFT", xy = { 107, -138 } },
            { point = "TOPLEFT", xy = { 177, -75 } },
            { point = "TOPLEFT", xy = { 144, -210 } },
            { point = "TOPLEFT", xy = { 196, -165 } },
            { point = "TOPLEFT", xy = { 244, -119 } },
            { point = "TOPLEFT", xy = { 306, -79 } },
            [100] = { xy = { 304, -270 }, isNPC = "b" .. bossIndex },
        }

        --[[


]]
        local xy = {
            { 626, -176 }, -- 星星
            { 626, -126 }, -- 大饼
            { 145, -430 }, -- 紫菱
            { 461, -112 }, -- 三角
            { 626, -71 },
            { 142, -106 },
            { 463, -430 },
            { 624, -17 },
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
            local tbl = TJ.SortRaidRosterInfo(nil, "healer", true)
            for _, i in ipairs({ 1, 7, 13, 19, 25 }) do
                for ii, v in ipairs(tbl) do
                    TJ.SetMapIconPlayerFormNum(i, v)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, { min = 2, max = 3 })
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "dps", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
        end
        local text = {
            L["治疗：1、7、13、 19、25号位。"],
            L["坦克:2、3号位。"],
            L["剩余位置：DPS。"],
        }

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["P1.5站位"],
            text)
        local width = 600
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 871 * 785, nil, nil, nil, "v1.26.2", nil, true)
        CreateText(map)
    end

    -- 沙包站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 410,-157} },
            { point = "TOPLEFT", xy = { 396,-114} },
            { point = "TOPLEFT", xy = { 406,-70 } },
            { point = "TOPLEFT", xy = { 437,-40 } },
            { point = "TOPLEFT", xy = { 477,-37 } },
            { point = "TOPLEFT", xy = { 516,-50 } },
            { point = "TOPLEFT", xy = { 529,-93 } },
            { point = "TOPLEFT", xy = { 522,-133} },
            { point = "TOPLEFT", xy = { 495,-164 } },
            { point = "TOPLEFT", xy = { 453,-170 } },
            [100] = { xy = { 463, -108 }, isNPC = "b" .. bossIndex },
        }

        --[[

]]
        local xy = {
            { 626, -176 }, -- 星星
            { 626, -126 }, -- 大饼
            { 145, -430 }, -- 紫菱
            { 461, -112 }, -- 三角
            { 626, -71 },
            { 142, -106 },
            { 463, -430 },
            { 624, -17 },
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
            local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, nil, 2)
            end
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN", "DRUID", "PRIEST", }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, nil, 2)
            end
        end
        local text = L["安排远程DPS。"]

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["沙包站位"],
            text)
        local width = 600
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 871 * 785, 2, nil, nil, "v1.26.2", nil, true)
        CreateText(map)
    end
    TJ.CreateMapTab(mainFrame, FB, bossIndex, "TOP")

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

    -- 群体反射
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, "", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排战士。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "ability_warrior_shieldbreak", L["群体反射"],
            text, { "WARRIOR" }, nil, nil, nil,
            nil)
        TJ.CreateEdit(FB, bossIndex, L["1群反"])
        TJ.CreateEdit(FB, bossIndex, L["2群反"])
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
                            spellID = { 134916, },
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
                    destNPCID = { 68397 },
                },
                title = { name = L["斩首"], icon = 134916 }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 136478, },
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
                    destNPCID = { 68397 },
                },
                title = { name = L["熔解削砍"], icon = 136478 }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 136914, },
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
                    destNPCID = { 68397 },
                },
                title = { name = L["压倒能量"], icon = 136914 }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_reincarnation", L["换嘲"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 雷电导管
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 135680, },
                            colorNum = 1,
                        },
                        {
                            spellID = { 135681, },
                            colorNum = 1,
                        },
                        {
                            spellID = { 135682, },
                            colorNum = 1,
                        },
                        {
                            spellID = { 135683, },
                            colorNum = 1,
                        },
                    },
                    destNPCID = { 68397 },
                    showIcon = true,
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shaman_measuredinsight", L["雷电导管"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 静电冲击
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 135695, },
                            colorNum = 1,
                        },
                    },
                },
                title = L["点名"]
            },
            {
                beDamage2 = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                135703,
                            },
                            colorNum = 1,
                            frameLevel = 2,
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["伤害分摊人数"] }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shaman_staticshock", L["静电冲击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 散射闪电链
    do
        local info = {
            {
                castSuccess = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 135991 },
                            colorNum = 2,
                        },
                    },
                },
                canSend = "count",
                title = L["点名"],
                notShowDead = true,
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                135991
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                canSend = "count",
                title = { name = L["受到%s伤害"]:format(L["散射闪电链"]) },
                notShowDead = true,
            },
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 114028 },
                            colorNum = 2,
                        },
                    },
                },
                notShowDead = true,
                title = { name = L["使用群体反射"], icon = 114028 }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_lightningbolt", L["散射闪电链"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 超载
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                136326
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                canSend = "count",
                title = { name = L["受到%s伤害"]:format(L["超载"]) },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_thunderking_overcharge", L["超载"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 弹跳闪电
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                136366
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                canSend = "count",
                title = { name = L["受到%s伤害"]:format(L["弹跳闪电"]) },
                notShowDead = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shaman_measuredinsight", L["接球"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 命令头盔
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 139011, },
                            colorNum = 1,
                        },
                    },
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_misc_desecrated_platehelm", L["命令头盔"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 召唤球状闪电
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                136543
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                canSend = "count",
                title = { name = L["受到%s伤害"]:format(L["召唤球状闪电"]) }
            },
            {
                beDamage2 = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                136543
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["受伤人数"] }
            },
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 108199 },
                            colorNum = 2,
                        },
                    },
                },
                notShowDead = true,
                title = { name = L["使用血魔之握"], icon = 108199 }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_thunderking_balllightning", L["召唤球状"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 闪电之鞭
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                136850
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                canSend = "count",
                title = { name = L["受到%s伤害"]:format(L["闪电之鞭"]) }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_thunderking_lightningwhip", L["闪电之鞭"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 雷霆打击
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 135095 },
                            colorNum = 2,
                        },
                    },
                },
            },
        }
        tinsert(info, TJ.combatInfoMore)

        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_thunderking_thunderstruck", L["雷霆打击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火散射闪电
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    69012, 69013, 69014
                },
            },
            canSend = "dps",
            title = { name = L["转火散射闪电"] },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_lightningbolt", L["转火散射"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火球状闪电
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    69232
                },
            },
            canSend = "dps",
            title = { name = L["转火球状闪电"] },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_thunderking_balllightning", L["转火球状"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
end
