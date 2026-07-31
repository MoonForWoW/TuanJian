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
local FB = "NAXXtitan"
local bossIndex = 15
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

    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 301, -378 } },
            { point = "TOPLEFT", xy = { 163, -244 } },
            { point = "TOPLEFT", xy = { 443, -249 } },
            { point = "TOPLEFT", xy = { 210, -151 } },
            { point = "TOPLEFT", xy = { 397, -149 } },
            { point = "TOPLEFT", xy = { 196, -347 } },
            { point = "TOPLEFT", xy = { 404, -345 } },
            { point = "TOPLEFT", xy = { 304, -104 } },
            { point = "TOPLEFT", xy = { 303, -448 } },
            { point = "TOPLEFT", xy = { 182, -427 } },
            { point = "TOPLEFT", xy = { 431, -426 } },
            { point = "TOPLEFT", xy = { 104, -319 } },
            { point = "TOPLEFT", xy = { 501, -319 } },
            { point = "TOPLEFT", xy = { 113, -166 } },
            { point = "TOPLEFT", xy = { 486, -177 } },
            { point = "TOPLEFT", xy = { 208, -73 } },
            { point = "TOPLEFT", xy = { 403, -76 } },

            [80] = {
                xy = { 630, -164 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["空气\n图腾"],
                isNPC_icon = "Interface\\Icons\\spell_nature_slowingtotem",
            },
            [90] = {
                xy = { 627, -24 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["3队\n近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [91] = {
                xy = { 629, -71 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["4队\n近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [92] = {
                xy = { 631, -118 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["5队\n近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [95] = {
                xy = { 489, -86 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["小强\n坦克"],
                isNPC_icon = "Interface\\Icons\\Spell_Holy_DevotionAura",
            },
            [96] = {
                xy = { 108, -83 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["小强\n坦克"],
                isNPC_icon = "Interface\\Icons\\Spell_Holy_DevotionAura",
            },
            [97] = {
                xy = { 338, -219 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["1队\n近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [98] = {
                xy = { 270, -216 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["2队\n近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [99] = {
                xy = { 300, -291 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["坦克"],
                isNPC_icon = "Interface\\Icons\\Spell_Deathknight_BloodPresence",
            },
            [100] = { xy = { 302, -249 }, isNPC = "b" .. bossIndex },
        }

        --[[

]]

        local function AutoFuc()
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
            for _, i in ipairs({ 2, 3 }) do
                for ii, v in ipairs(tbl) do
                    TJ.SetMapIconPlayerFormNum(i, v)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN", "PRIEST", "DRUID", }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
        end
        local text = {
            L["奶骑：2、3号位。"],
            L["其他治疗：1、4、5号位。"],
            L["剩余位置：远程DPS。"],
        }

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local width = 600
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 940 * 770, nil, nil, nil, "v1.26.2")
    end

    -- 坦克
    do
        local function AutoFuc(title)
            local dk = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, "tank", true)
            for i, v in ipairs(dk) do
                TJ.SetEditTextFormNum(v, title, 1)
                tremove(dk, i)
                break
            end
            local fq = TJ.SortRaidRosterInfo({ "PALADIN" }, "tank", true)
            for i, v in ipairs(fq) do
                TJ.SetEditTextFormNum(v, title, 2)
                tremove(fq, i)
                break
            end
            local tbl = TJ.SortRaidRosterInfo({ "WARRIOR", "DRUID" }, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            for i, v in ipairs(dk) do
                TJ.SetEditText(v, title)
            end
            for i, v in ipairs(fq) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["BOSS"])
        TJ.CreateEdit(FB, bossIndex, L["左小强"])
        TJ.CreateEdit(FB, bossIndex, L["右小强"])
    end

    -- 打断小怪
    do
        local function AutoFuc(title)
            local tbl = CopyTable(TJ.SortRaidRosterInfo({ "DEATHKNIGHT", "ROGUE", "WARRIOR", "SHAMAN" }, "dps1", true))
            for i, v in ipairs(tbl) do
                if v.class == "DEATHKNIGHT" then
                    tbl[i].index = 1
                elseif v.class == "ROGUE" then
                    tbl[i].index = 2
                elseif v.class == "WARRIOR" then
                    tbl[i].index = 3
                elseif v.class == "SHAMAN" then
                    tbl[i].index = 4
                end
            end
            sort(tbl, function(a, b)
                if a.index and b.index then
                    return a.index < b.index
                end
                return false
            end)
            local done = {}
            for _, v in ipairs(tbl) do
                for _, i in ipairs({ 1, 3, 5, 2, 4, 6 }) do
                    if not done[i] then
                        TJ.SetEditTextFormNum(v, title, i)
                        done[i] = true
                        break
                    end
                end
            end
        end
        local text = L["优先安排DK/盗贼/战士/增强萨。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_frost_frostbolt02", L["打断寒冰箭"],
            text, nil, nil, nil, nil,
            true, 2)
        TJ.CreateEdit(FB, bossIndex, L["1打断"])
        TJ.CreateEdit(FB, bossIndex, L["1打断"])
        TJ.CreateEdit(FB, bossIndex, L["2打断"])
        TJ.CreateEdit(FB, bossIndex, L["2打断"])
        TJ.CreateEdit(FB, bossIndex, L["3打断"])
        TJ.CreateEdit(FB, bossIndex, L["3打断"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 冰霜冲击
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            27808,
                        },
                    },
                },
                showCount = true,
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_frost_freezingbreath", L["冰霜冲击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 自爆法力
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 27819, },
                            colorNum = 1,
                        },
                    },
                },
                title = L["点名"]
            },
            {
                damageFriend = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                27820,
                            },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["误伤队友"] }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_wispsplode", L["自爆法力"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 暗影裂隙
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                27812
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["受到%s伤害"]:format(L["暗影裂隙"]) },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_creepingplague", L["暗影裂隙"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 克尔苏加德锁链
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                28410, -- 克尔苏加德锁链
                            },
                            tooltip = "health",
                            colorNum = 2,
                        },
                    },
                },
                title = { name = L["被心控"] },
            },
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                33786,
                            },
                            colorNum = 1
                        },
                    },
                },
                title = { name = L["施放旋风"], icon = 33786 },
            },
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = ns.sp["羊"],
                            colorNum = 1
                        },
                    },
                },
                title = { name = L["施放变羊/妖术"], icon = 12826 },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_belt_18", L["心控"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 打断
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 55802, 28478, },
                        },
                    },
                },
                title = { name = L["漏打断"], color = { 1, 0, 0 } },
                canSend = "count",
            },
            {
                interrupt = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                55802, 28478,
                            },
                        },
                    },
                },
                title = { name = L["成功打断"] }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_frost_frostbolt02", L["打断寒冰箭"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    23561,
                    23562,
                    23563,
                    16427,
                    16428,
                    16429,
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warrior_cleave", L["P1小怪伤害"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    23561,
                    23562,
                    23563,
                    16427,
                    16428,
                    16429,
                },
                startTime = "P2",
                endTime = "duration",
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_blackplague", L["P2清场伤害"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("发动了攻击") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
            return
        end
        if msg:match("一个活口都不要留") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P3",
            })
            return
        end
    end
end
