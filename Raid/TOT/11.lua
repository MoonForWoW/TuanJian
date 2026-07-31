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
local bossIndex = 11
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
    local bossSpellID = 137491
    TJ.AddBoard(mainFrame, function()
        local s1, s2, s3, s4, s5, s6, s7 = ns.s1, ns.s2, ns.s3, ns.s4, ns.s5, ns.s6, ns.s7
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
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s9)
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s8)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
            for i = startIndex, maxIndex, 1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, TuanJian.talentInfo[v.name] == 1 and s5 or ns.s13)
                    tremove(tbl, ii)
                    break
                end
            end

            local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
            for i = maxIndex, startIndex, -1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s6)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "dps", true)
            for i = maxIndex, startIndex, -1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s9)
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s10)
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
            local tbl = TJ.SortRaidRosterInfo({ "MONK" }, "healer", true)
            for i = maxIndex, startIndex, -1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s11)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, "dps", true)
            for i = maxIndex, startIndex, -1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s4)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "dps", true)
            for i = maxIndex, startIndex, -1 do
                for ii, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s14)
                    tremove(tbl, ii)
                    break
                end
            end
        end

        local tbl = {
            {
                name = L["浩劫炼狱减伤链"],
                bossSpellID = bossSpellID,
                arrange = 7,
                icon = "spell_mage_flameorb",
                id = 1,
                spell = spellTbl,
                event = "SPELL_CAST_START",
                canUpdate = nil,
                autoNextSpell = nil,
                startIndex = 1,
                maxIndex = nil,
                bossTime = { 4, 4, },
                autoHide = true,
            },
            AutoFuc = AutoFuc,
        }

        --[[
/run m=TJ.frame["TOT"][11] TJ.Board_ENCOUNTER_START("TOT", 11)
/run TJ.Board_SPELL_CAST_START(nil,nil,nil,"1",nil,nil,nil,"1-2-3-4-5-70235",nil,nil,nil,137491)
/run ChatThrottleLib:SendAddonMessage("ALERT", 'D5', 'Inferno', "RAID")

 ]]
        mainFrame.Board_test = function()
            TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
            TJ.Board_info[bossSpellID].canUpdate = true
        end

        mainFrame.Board_SPELL_CAST_START = function(info, ...)
            local tbl = { ... }
            local spellID = tbl[12]
            if spellID == bossSpellID and not TJ.SetCD(mainFrame, 10) then
                TJ.Board_info[bossSpellID].canUpdate = true
                TJ.Board_info[bossSpellID].updateFrame.t = 0
                After(0, function()
                    info[bossSpellID].index = info[bossSpellID].index + info[bossSpellID].step
                end)
            end
        end

        TJ.RegisterEvent("CHAT_MSG_ADDON", function(_, _, ...)
            local prefix, msg, distType, sender = ...
            if TJ.startTime and prefix == "D5" and distType == "RAID"
                and msg:find("Inferno") and not TJ.SetCD(mainFrame, 10) then
                TJ.Board_info[bossSpellID].canUpdate = true
                TJ.Board_info[bossSpellID].updateFrame.t = 0
                After(0, function()
                    TJ.Board_info[bossSpellID].index = TJ.Board_info[bossSpellID].index + TJ.Board_info[bossSpellID].step
                end)
            end
        end)

        TJ.CreateBoard(FB, bossIndex, tbl)
    end)

    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 306, -500 } },
            { point = "TOPLEFT", xy = { 199, -472 } },
            { point = "TOPLEFT", xy = { 414, -474 } },
            { point = "TOPLEFT", xy = { 115, -398 } },
            { point = "TOPLEFT", xy = { 489, -403 } },
            { point = "TOPLEFT", xy = { 92, -291 } },
            { point = "TOPLEFT", xy = { 512, -294 } },
            { point = "TOPLEFT", xy = { 121, -196 } },
            { point = "TOPLEFT", xy = { 479, -186 } },
            { point = "TOPLEFT", xy = { 179, -129 } },
            { point = "TOPLEFT", xy = { 417, -116 } },
            { point = "TOPLEFT", xy = { 301, -93 } },
            { point = "TOPLEFT", xy = { 188, -292 } },
            { point = "TOPLEFT", xy = { 429, -290 } },
            { point = "TOPLEFT", xy = { 228, -389 } },
            { point = "TOPLEFT", xy = { 389, -389 } },
            { point = "TOPLEFT", xy = { 303, -172 } },

            [97] = {
                xy = { 328, -248 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["奶骑\n奶僧"],
                isNPC_icon = "Interface\\Icons\\Spell_Holy_AuraOfLight",
            },
            [98] = {
                xy = { 285, -247 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [99] = {
                xy = { 305, -336 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["坦克"],
                isNPC_icon = "Interface\\Icons\\Spell_Deathknight_BloodPresence",
            },
            [100] = { xy = { 303, -290 }, isNPC = "b" .. bossIndex },
        }

        --[[

]]
        local xy = {
            { 624, -371 }, -- 星星
            { 623, -321 }, -- 大饼
            { 623, -273 }, -- 紫菱
            { 623, -225 }, -- 三角
            { 623, -177 },
            { 623, -128 },
            { 624, -75 },
            { 623, -23 },
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
            if TJ.Is10Man() then
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN", "DRUID", "PRIEST", }, "healer", true)
                for _, i in ipairs({ 2, 3 }) do
                    for ii, v in ipairs(tbl) do
                        TJ.SetMapIconPlayerFormNum(i, v)
                        tremove(tbl, ii)
                        break
                    end
                end
                local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
                for i, v in ipairs(tbl) do
                    TJ.SetMapIconPlayer(v)
                end
            else
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN", "DRUID", "PRIEST", }, "healer", true)
                for _, i in ipairs({ 1, 4, 5, 8, 9 }) do
                    for ii, v in ipairs(tbl) do
                        TJ.SetMapIconPlayerFormNum(i, v)
                        tremove(tbl, ii)
                        break
                    end
                end
                local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
                for i, v in ipairs(tbl) do
                    TJ.SetMapIconPlayer(v)
                end
            end
        end
        local text = {
            L["治疗：1、4、5、8、9号位。"],
            L["剩余位置：远程DPS。"],
        }

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local width = 600
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 789 * 749, nil, nil, nil, "v1.26.2")
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

    -- 天神画图
    do
        local function AutoFuc(title)
        end
        local info = {
        }
        local text = L["此任务只能手动安排。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "monk_stance_whitetiger", L["天神画图"],
            text, nil, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["天神画图"])
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
                            spellID = { 137341, },
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
                    destNPCID = { 68904, 68905 },
                },
                title = { name = L["梦魇兽"], icon = 137341 }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 137408, },
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
                    destNPCID = { 68904, 68905 },
                },
                title = { name = L["烈焰刃舞"], icon = 137408 }
            },

        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_reincarnation", L["换嘲"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 月光莲
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 136722, },
                            colorNum = 1,
                        },
                    },
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_misc_herb_frostlotus", L["月光莲"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 梦魇兽
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 137341, },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = L["点名"],
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 137360, },
                            colorNum = 1,
                        },
                    },
                },
                title = { name = L["堕落治疗"], icon = 137360 },
            },

        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "creatureportrait_twilightshammer_dragonegg_02", L["梦魇兽"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 炽热光辉
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 139412, },
                            colorNum = 1,
                        },
                    },
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_priest_divinestar_holy", L["炽热光辉"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 浩劫炼狱
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 137491 },
                            colorNum = 2,
                        },
                    },
                },
            },
        }
        tinsert(info, TJ.combatInfoMore)

        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_mage_flameorb", L["浩劫炼狱"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 潮汐之力
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                137716
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                canSend = "count",
                title = { name = L["受到%s伤害"]:format(L["潮汐之力"]) },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_frost_summonwaterelemental", L["潮汐之力"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 天神之助
    do
        local info = {
            {
                castSuccess = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 138264, 138189, 138267, 138254 },
                            colorNum = 2,
                        },
                    },
                    showIcon = true,
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "monk_stance_whitetiger", L["天神之助"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    69591
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_shadowbolt", L["转火小怪"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.UNIT_SPELLCAST_SUCCEEDED = function(unit, spellID)
        if spellID == 137187 and not TJ.SetCD(mainFrame, 2, spellID) then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
        end
    end

    mainFrame.INSTANCE_ENCOUNTER_ENGAGE_UNIT = function()
        if TJ.GetNPCID("boss2") == 68905 then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P3",
            })
        end
    end
end
