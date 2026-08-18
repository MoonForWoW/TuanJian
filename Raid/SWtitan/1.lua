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
local FB = "SWtitan"
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

    local instanceID = TJ.FBinfo[FB].ID
    TJ.autoRaidTargetInfo[instanceID] = TJ.autoRaidTargetInfo[instanceID] or {}
    TJ.autoRaidTargetInfo[instanceID][25372] = { [8] = true, [7] = true } -- 斥候
    TJ.autoRaidTargetInfo[instanceID][25588] = { -- 欺诈者之手
        [8] = true,
        [7] = true,
        [6] = true,
        [5] = true,
        np = true,
    }

    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 620,-57 } },
            { point = "TOPLEFT", xy = { 621,-91 } },
            { point = "TOPLEFT", xy = { 622,-124 } },
            { point = "TOPLEFT", xy = { 622,-159 } },
            { point = "TOPLEFT", xy = { 622,-191 } },
            { point = "TOPLEFT", xy = { 158,-256 } },
            { point = "TOPLEFT", xy = { 100,-209 } },
            { point = "TOPLEFT", xy = { 224,-208 } },
            { point = "TOPLEFT", xy = { 92,-292 } },
            { point = "TOPLEFT", xy = { 220,-296 } },
            { point = "TOPLEFT", xy = { 447,-256 } },
            { point = "TOPLEFT", xy = { 379,-211 } },
            { point = "TOPLEFT", xy = { 506,-208 } },
            { point = "TOPLEFT", xy = { 388,-294 } },
            { point = "TOPLEFT", xy = { 504,-291 } },
            { point = "TOPLEFT", xy = { 177,-401 } },
            { point = "TOPLEFT", xy = { 115,-362 } },
            { point = "TOPLEFT", xy = { 242,-369 } },
            { point = "TOPLEFT", xy = { 132,-436 } },
            { point = "TOPLEFT", xy = { 245,-440 } },
            { point = "TOPLEFT", xy = { 421,-403 } },
            { point = "TOPLEFT", xy = { 369,-366 } },
            { point = "TOPLEFT", xy = { 481,-365 } },
            { point = "TOPLEFT", xy = { 363,-450 } },
            { point = "TOPLEFT", xy = { 468,-446 } },

            [80] = {
                xy = { 622,-18 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["空气\n图腾"],
                isNPC_icon = "Interface\\Icons\\spell_nature_slowingtotem",
            },
            [98] = {
                xy = { 309,-137},
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [99] = {
                xy = { 251,-81 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["坦克"],
                isNPC_icon = "Interface\\Icons\\Spell_Deathknight_BloodPresence",
            },
            [100] = { xy = { 306,-82 }, isNPC = "b" .. bossIndex, size = 70, },
        }

        --[[


]]

        local function AutoFuc()
            local mapIndex = ""
            local team = TJ.GetRaidPointByTeam(1)
            if team then
                for i, v in ipairs(team) do
                    TJ.SetMapIconPlayer(v, { min = 1, max = 5 }, mapIndex)
                end
            end
            local team = TJ.GetRaidPointByTeam(2)
            if team then
                for i, v in ipairs(team) do
                    TJ.SetMapIconPlayer(v, { min = 6, max = 10 }, mapIndex)
                end
            end
            local team = TJ.GetRaidPointByTeam(3)
            if team then
                for i, v in ipairs(team) do
                    TJ.SetMapIconPlayer(v, { min = 11, max = 15 }, mapIndex)
                end
            end
            local team = TJ.GetRaidPointByTeam(4)
            if team then
                for i, v in ipairs(team) do
                    TJ.SetMapIconPlayer(v, { min = 16, max = 20 }, mapIndex)
                end
            end
            local team = TJ.GetRaidPointByTeam(5)
            if team then
                for i, v in ipairs(team) do
                    TJ.SetMapIconPlayer(v, { min = 21, max = 25 }, mapIndex)
                end
            end
        end
        local text = {
            L["1-5：1队。"],
            L["6-10：2队。"],
            L["11-15：3队。"],
            L["16-20：4队。"],
            L["21-25：5队。"],
        }

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local width = 600
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 886 * 780, nil, nil, nil, "v2.0.3")
    end

    -- 坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                if v.class == "DEATHKNIGHT" then
                    TJ.SetEditText(v, title)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil, true)
        TJ.CreateEdit(FB, bossIndex, L["1坦"])
        TJ.CreateEdit(FB, bossIndex, L["2坦"])
        TJ.CreateEdit(FB, bossIndex, L["3坦"])
    end

    -- 治疗
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST", "SHAMAN", "DRUID", "MONK" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排治疗。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Holy_HolyBolt", L["治疗"],
            text, TJ.healerClass, nil, nil, nil, true)
        TJ.CreateEdit(FB, bossIndex, L["1奶"])
        TJ.CreateEdit(FB, bossIndex, L["2奶"])
        TJ.CreateEdit(FB, bossIndex, L["3奶"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 顺劈斩
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                44799
                            },
                            combatRole = { "Isdps", "Ishealer" },
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["受到%s伤害"]:format(L["顺劈斩"]) },
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                45122,
                            },
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["受到%s伤害"]:format(L["扫尾"]), icon = 45122 },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_frost_frostblast", L["吐息扫尾"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 进内场
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 46021, },
                            colorNum=1,
                        },
                        {
                            spellID = { 44867, },
                            colorNum = 5,
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L['进内场(黄色是进了内场，灰色是灵魂疲惫)'] },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_charm", L["进内场"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 奥术打击
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 45018, },
                        },
                    },
                    destNpcType = { "Player" },
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_arcane_arcane03", L["奥术打击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 驱散诅咒
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                45032, 45034
                            },
                            colorNum = 1,
                        }
                    },
                    destNpcType = { "Player" },
                }
            },
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                45032, 45034
                            },
                            colorNum = 1
                        }
                    },
                },
                title = { name = L["驱散无边苦痛诅咒"] },
                notShowDead = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_curseofsargeras", L["驱散诅咒"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 狂野魔法
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 44978, },
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L['法术的治疗效果提高100%'], icon=44978, color = { 0, 1, 0 } },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 45010, },
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L['法术和技能消耗降低50%'], icon = 45010, color = { 0, 1, 0 } },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 45004, },
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L['爆击所造成的伤害提高100%'], icon = 45004, color = { 0, 1, 0 } },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 45001, },
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L['施法时间延长100%'], icon = 45001, color = { 1, 0, 0 } },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 45002, },
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L['近战和远程命中几率降低50%'], icon = 45002, color = { 1, 0, 0 } },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 45006, },
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L['仇恨提高100%'], icon = 45006, color = { 1, 0, 0 } },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_misc_monsterscales_11", L["狂野魔法"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("^^") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
            return
        end
    end
end
