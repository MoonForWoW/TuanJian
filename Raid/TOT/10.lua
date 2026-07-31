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
local bossIndex = 10
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
    local bossSpellID = 136147
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
                local maxIndex = #spellTbl
                -- 减伤
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
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
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
                        TJ.SetBoardEditFormNum(v, i, nil, ns.s9)
                        TJ.SetBoardEditFormNum(v, i, nil, ns.s8)
                        startIndex = startIndex + 1
                        tremove(tbl, ii)
                        break
                    end
                end

                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
                for i = maxIndex, 1, -1 do
                    for ii, v in ipairs(tbl) do
                        TJ.SetBoardEditFormNum(v, i, nil, TuanJian.talentInfo[v.name] == 1 and s5 or ns.s13)
                        startIndex = startIndex + 1
                        tremove(tbl, ii)
                        break
                    end
                end
                local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
                for i = maxIndex, 1, -1 do
                    for ii, v in ipairs(tbl) do
                        TJ.SetBoardEditFormNum(v, i, nil, s6)
                        startIndex = startIndex + 1
                        tremove(tbl, ii)
                        break
                    end
                end

                -- 抬血
                local startIndex = 1
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "dps", true)
                for i = startIndex, maxIndex, 1 do
                    for ii, v in ipairs(tbl) do
                        TJ.SetBoardEditFormNum(v, i, nil, ns.s9)
                        TJ.SetBoardEditFormNum(v, i, nil, ns.s10)
                        startIndex = startIndex + 1
                        tremove(tbl, ii)
                        break
                    end
                end
                local tbl = TJ.SortRaidRosterInfo({ "DRUID" }, "healer", true)
                for i = startIndex, maxIndex, 1 do
                    for ii, v in ipairs(tbl) do
                        TJ.SetBoardEditFormNum(v, i, nil, ns.s12)
                        startIndex = startIndex + 1
                        tremove(tbl, ii)
                        break
                    end
                end
                local tbl = TJ.SortRaidRosterInfo({ "MONK" }, "healer", true)
                for i = startIndex, maxIndex, 1 do
                    for ii, v in ipairs(tbl) do
                        TJ.SetBoardEditFormNum(v, i, nil, ns.s11)
                        startIndex = startIndex + 1
                        tremove(tbl, ii)
                        break
                    end
                end
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "dps", true)
                for i = maxIndex, 1, -1 do
                    for ii, v in ipairs(tbl) do
                        TJ.SetBoardEditFormNum(v, i, nil, ns.s14)
                        startIndex = startIndex + 1
                        tremove(tbl, ii)
                        break
                    end
                end
            end

            local tbl = {
                {
                    name = L["碎击拳减伤链"],
                    bossSpellID = bossSpellID,
                    arrange = 6,
                    icon = "spell_nature_earthquake",
                    id = 1,
                    spell = spellTbl,
                    event = "SPELL_CAST_SUCCESS",
                    canUpdate = nil,
                    autoNextSpell = nil,
                    startIndex = 1,
                    maxIndex = #spellTbl,
                    bossTime = function()
                        return TJ.IsH()
                            and { 62, 28, }
                            or { 22.5, 20, }
                    end,
                    autoHide = nil,
                },
                AutoFuc = AutoFuc,
            }

            mainFrame.Board_test = function()
                TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
                TJ.Board_info[bossSpellID].canUpdate = true
                local t = TJ.Board_info[bossSpellID].updateFrame.t
                local nextTime = TJ.Board_info[bossSpellID].bossTime[1]
                if t and nextTime and nextTime - t > 10 then
                    TJ.Board_info[bossSpellID].updateFrame.t = nextTime - 10
                end
            end

            mainFrame.UNIT_SPELLCAST_SUCCEEDED = function(unit, spellID)
                if spellID == 136146 and not TJ.SetCD(mainFrame, 10, spellID) then
                    TJ.Board_NextSpell(bossSpellID)
                    local newEvent = TJ.GetNewEvent()
                    if newEvent then
                        newEvent["SPELL_CAST_SUCCESS"] = newEvent["SPELL_CAST_SUCCESS"] or {}
                        local time = TJ.GetDurTime()
                        After(1, function()
                            local tbl = {
                                time,
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
                                bossSpellID,
                            }
                            tbl.i = 1
                            tinsert(newEvent["SPELL_CAST_SUCCESS"], tbl)
                        end)
                    end
                    return
                end
            end

            --[[
/run TJ.Board_ENCOUNTER_START("TOT", 10) TJ.frame["TOT"][10].BOSS_SAY("没用的杂种")
/run TJ.frame["TOT"][10].UNIT_SPELLCAST_SUCCEEDED(nil,136146)
 ]]

            mainFrame.BOSS_SAY = function(msg)
                if msg:match("向我的敌人发起风暴") then
                    tinsert(TJ.GetNewCombatLog().otherTime, {
                        time = TJ.GetDurTime(),
                        name = "P2",
                    })
                    return
                end
                if msg:match("冻死他们") then
                    tinsert(TJ.GetNewCombatLog().otherTime, {
                        time = TJ.GetDurTime(),
                        name = "P3",
                    })
                    return
                end
                if msg:match("没用的杂种") then
                    TJ.Board_info[bossSpellID].canUpdate = true
                    TJ.Board_info[bossSpellID].updateFrame.t = 0
                    tinsert(TJ.GetNewCombatLog().otherTime, {
                        time = TJ.GetDurTime(),
                        name = "P4",
                    })
                    return
                end
            end

            TJ.CreateBoard(FB, bossIndex, tbl)
        end
        tinsert(TJ.boardCallback, init)
        if TJ.boardInited and not isload then init() end
    end

    -- 站位图P1
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 276, -469 } },
            { point = "TOPLEFT", xy = { 195, -424 } },
            { point = "TOPLEFT", xy = { 363, -435 } },
            { point = "TOPLEFT", xy = { 178, -340 } },
            { point = "TOPLEFT", xy = { 377, -334 } },
            { point = "TOPLEFT", xy = { 277, -573 } },
            { point = "TOPLEFT", xy = { 200, -551 } },
            { point = "TOPLEFT", xy = { 354, -555 } },
            { point = "TOPLEFT", xy = { 137, -514 } },
            { point = "TOPLEFT", xy = { 419, -509 } },
            { point = "TOPLEFT", xy = { 106, -451 } },
            { point = "TOPLEFT", xy = { 457, -448 } },
            { point = "TOPLEFT", xy = { 98, -376 } },
            { point = "TOPLEFT", xy = { 462, -367 } },
            { point = "TOPLEFT", xy = { 95, -287 } },
            { point = "TOPLEFT", xy = { 460, -280 } },
            { point = "TOPLEFT", xy = { 174, -244 } },
            { point = "TOPLEFT", xy = { 378, -244 } },

            [97] = {
                xy = { 300, -262 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["奶骑\n奶僧"],
                isNPC_icon = "Interface\\Icons\\Spell_Holy_AuraOfLight",
            },
            [98] = {
                xy = { 255, -265 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [99] = {
                xy = { 279, -353 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["坦克"],
                isNPC_icon = "Interface\\Icons\\Spell_Deathknight_BloodPresence",
            },
            [100] = { xy = { 278, -301 }, isNPC = "b" .. bossIndex },
        }

        --[[

]]
        local xy = {
            { 578, -377 }, -- 星星
            { 577, -331 }, -- 大饼
            { 577, -286 }, -- 紫菱
            { 579, -234 }, -- 三角
            { 579, -182 },
            { 577, -130 },
            { 576, -78 },
            { 576, -23 },
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
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN", "DRUID", "PRIEST", }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
        end
        local text = {
            L["治疗：1-5号位。"],
            L["剩余位置：远程DPS。"],
        }

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["P1站位"],
            text)
        local width = 550
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 574 * 692, nil, nil, nil, "v1.26.2")
    end

    -- 站位图P2
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 209, -215 } },
            { point = "TOPLEFT", xy = { 445, -226 } },
            { point = "TOPLEFT", xy = { 250, -307 } },
            { point = "TOPLEFT", xy = { 402, -306 } },
            { point = "TOPLEFT", xy = { 103, -76 } },
            { point = "TOPLEFT", xy = { 549, -85 } },
            { point = "TOPLEFT", xy = { 199, -81 } },
            { point = "TOPLEFT", xy = { 442, -86 } },
            { point = "TOPLEFT", xy = { 145, -151 } },
            { point = "TOPLEFT", xy = { 496, -164 } },
            { point = "TOPLEFT", xy = { 74, -200 } },
            { point = "TOPLEFT", xy = { 566, -207 } },
            { point = "TOPLEFT", xy = { 137, -274 } },
            { point = "TOPLEFT", xy = { 511, -289 } },
            { point = "TOPLEFT", xy = { 79, -326 } },
            { point = "TOPLEFT", xy = { 570, -354 } },
            { point = "TOPLEFT", xy = { 171, -378 } },
            { point = "TOPLEFT", xy = { 474, -380 } },

            [97] = {
                xy = { 345, -142 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["奶骑\n奶僧"],
                isNPC_icon = "Interface\\Icons\\Spell_Holy_AuraOfLight",
            },
            [98] = {
                xy = { 308, -145 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [99] = {
                xy = { 325, -63 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["坦克"],
                isNPC_icon = "Interface\\Icons\\Spell_Deathknight_BloodPresence",
            },
            [100] = { xy = { 323, -105 }, isNPC = "b" .. bossIndex },
        }

        --[[
]]
        local xy = {
            { 675, -377 }, -- 星星
            { 675, -331 }, -- 大饼
            { 675, -286 }, -- 紫菱
            { 675, -234 }, -- 三角
            { 675, -182 },
            { 675, -130 },
            { 675, -78 },
            { 675, -23 },
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
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN", "DRUID", "PRIEST", }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, nil, 2)
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, nil, 2)
            end
        end
        local text = {
            L["治疗：1-5号位。"],
            L["剩余位置：远程DPS。"],
        }

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["P2站位"],
            text)
        local width = 650
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 589 * 450, 2, nil, nil, "v1.28.5", "-2")
    end

    TJ.CreateMapTab(mainFrame, FB, bossIndex)

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
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 134691, },
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
                },
                title = { name = L["穿刺"], icon = 134691 }
            },
            -- {
            --     aura = {
            --         type = "d",
            --         spell = {
            --             {
            --                 spellID = { 137408, },
            --                 colorNum = 2,
            --                 combatRole = { "Istank" },
            --             },
            --         },
            --         destNpcType = { "Player" },
            --     },
            --     castSuccess = {
            --         type = "s",
            --         spell = {
            --             {
            --                 spellID = ns.sp["单嘲+群嘲"],
            --                 colorNum = 1,
            --                 frameLevel = 2,
            --                 combatRole = { "Istank" },
            --             },
            --         },
            --         notShowCount = true,
            --         destNPCID = { 68904, 68905 },
            --     },
            --     title = { name = L["烈焰刃舞"], icon = 137408 }
            -- },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_reincarnation", L["换嘲"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 脱缰烈焰
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 134647, },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["脱缰烈焰层数"] }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_burningspeed", L["脱缰烈焰"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 闪电风暴
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 136192, },
                            colorNum = 1,
                        },
                    },
                },
                title = L["点名"]
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_rod_enchantedadamantite", L["闪电风暴"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 雷矛
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 137669, },
                            colorNum = 1,
                        },
                    },
                },
                title = { name = L["风暴雷云层数"] }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_elemental_primal_air", L["雷矛"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 冰矛
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 137664, },
                            colorNum = 1,
                        },
                    },
                },
                title = { name = L["冻结之血层数"] }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_deathknight_icygrip", L["冰矛"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 碎击拳
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { bossSpellID },
                            colorNum = 2,
                        },
                    },
                },
            },
        }
        tinsert(info, TJ.combatInfoMore)

        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_earthquake", L["碎击拳"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
end
