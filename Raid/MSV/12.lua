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
local FB = "HOF"
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
            local s61 = ns.s61
            local spellTbl = {
                {
                    title = L["第1"],
                    class = { "SHAMAN" },
                    spell = TJ.Board_TJ6
                },
                {
                    title = L["第2"],
                    class = { "SHAMAN" },
                    spell = TJ.Board_TJ6
                },
                {
                    title = L["第3"],
                    class = { "SHAMAN" },
                    spell = TJ.Board_TJ6
                },
                {
                    title = L["第4"],
                    class = { "SHAMAN" },
                    spell = TJ.Board_TJ6
                },
                {
                    title = L["第5"],
                    class = { "SHAMAN" },
                    spell = TJ.Board_TJ6
                },
                {
                    title = L["第6"],
                    class = { "SHAMAN" },
                    spell = TJ.Board_TJ6
                },
                {
                    title = L["第7"],
                    class = { "SHAMAN" },
                    spell = TJ.Board_TJ6
                },
                {
                    title = L["第8"],
                    class = { "SHAMAN" },
                    spell = TJ.Board_TJ6
                },
            }
            local function AutoFuc()
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer+dps", true)
                for i, v in ipairs(tbl) do
                    if not done[1] then
                        TJ.SetBoardEditFormNum(v, 1, nil, s61)
                        TJ.SetBoardEditFormNum(v, 2, nil, s61)
                        TJ.SetBoardEditFormNum(v, 7, nil, s61)
                        done[1] = true
                    elseif not done[3] then
                        TJ.SetBoardEditFormNum(v, 3, nil, s61)
                        TJ.SetBoardEditFormNum(v, 4, nil, s61)
                        TJ.SetBoardEditFormNum(v, 8, nil, s61)
                        done[3] = true
                    elseif not done[5] then
                        TJ.SetBoardEditFormNum(v, 5, nil, s61)
                        TJ.SetBoardEditFormNum(v, 6, nil, s61)
                        done[5] = true
                    end
                end
            end

            local tbl = {
                {
                    name = L["战栗链"],
                    bossSpellID = 124862,
                    arrange = 1,
                    icon = "spell_nature_tremortotem",
                    id = 1,
                    spell = spellTbl,
                    event = "SPELL_CAST_SUCCESS",
                    canUpdate = nil,
                    autoNextSpell = nil,
                    startIndex = 1,
                    maxIndex = 8,
                    bossTime = { 3.5, 3.5, },
                },
                AutoFuc = AutoFuc,
            }

            local bossSpellID = 124862
            mainFrame.Board_test = function()
                TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
                TJ.Board_info[bossSpellID].canUpdate = true
                TJ.Board_info[bossSpellID].updateFrame.t = 0
            end

            TJ.CreateBoard(FB, bossIndex, tbl)

            mainFrame.Board_SPELL_CAST_SUCCESS = function(info, ...)
                local tbl = { ... }
                local spellID = tbl[12]
                if spellID == bossSpellID then
                    info[bossSpellID].canUpdate = true
                    info[bossSpellID].updateFrame.t = 0
                    After(4, function()
                        TJ.Board_HideBar(bossSpellID)
                        info[bossSpellID].index = info[bossSpellID].index + info[bossSpellID].step
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
            { point = "TOPLEFT", xy = { 170, -210 } },
            { point = "TOPLEFT", xy = { 115, -248 } },
            { point = "TOPLEFT", xy = { 135, -315 } },
            { point = "TOPLEFT", xy = { 205, -315 } },
            { point = "TOPLEFT", xy = { 225, -248 } },

            { point = "TOPLEFT", xy = { 375, -210 } },
            { point = "TOPLEFT", xy = { 320, -248 } },
            { point = "TOPLEFT", xy = { 340, -315 } },
            { point = "TOPLEFT", xy = { 410, -315 } },
            { point = "TOPLEFT", xy = { 430, -248 } },

            { point = "TOPLEFT", xy = { 170, -266 } },
            { point = "TOPLEFT", xy = { 375, -266 } },
            { point = "TOPLEFT", xy = { 242, -372 } },
            { point = "TOPLEFT", xy = { 308, -372 } },

            [97] = {
                xy = { 298, -185 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["奶骑\n奶僧"],
                isNPC_icon = "Interface\\Icons\\Spell_Holy_AuraOfLight",
            },
            [98] = {
                xy = { 259, -185 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [99] = {
                xy = { 275, -100 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["坦克"],
                isNPC_icon = "Interface\\Icons\\Spell_Deathknight_BloodPresence",
            },
            [100] = { xy = { 275, -143 }, isNPC = "b" .. bossIndex },
        }

        --[[

]]
        local xy = {
            { 575, -376 }, -- 星星
            { 575, -324 }, -- 大饼
            { 575, -273 }, -- 紫菱
            { 575, -226 }, -- 三角
            { 575, -175 },
            { 575, -123 },
            { 575, -70 },
            { 575, -18 },
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
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN", }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, { min = 11, max = 14 })
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST", "DRUID" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
        end
        local text = {
            L["1-10：远程DPS。"],
            L["11-12：奶萨。"],
            L["13-14：奶德/奶牧。"],
        }
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local map = TJ.CreateMap(FB, bossIndex, tbl, 550, 430)
        local t = map:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 30, "OUTLINE")
        t:SetPoint("TOPLEFT", 20, -20)
        t:SetText(L["P1站位"])
    end

    -- P1/P3坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["P1/P3坦克"],
            text, TJ.tankClass, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["主坦克"])
        TJ.CreateEdit(FB, bossIndex, L["副坦克"])
    end
    -- P1进不谐力场
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "MAGE" }, nil, true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排法师。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_holy_persecution", L["进入不谐力场"],
            text, nil, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L[""])
        TJ.CreateEdit(FB, bossIndex, L[""])
    end
    -- P2坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                if v.class == "DEATHKNIGHT" then
                    TJ.SetEditTextFormNum(v, title, 1)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["大怪优先安排DKT，小怪其他坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["P2坦克"],
            text, TJ.tankClass, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["大怪"])
        TJ.CreateEdit(FB, bossIndex, L["左侧小怪"])
        TJ.CreateEdit(FB, bossIndex, L["右侧小怪"])
    end
    -- P2误导/嫁祸
    do
        local function AutoFuc(title)
            local tbl = CopyTable(TJ.SortRaidRosterInfo(title.classTbl, nil, true))
            for i, v in ipairs(tbl) do
                if v.class == "HUNTER" then
                    tbl[i].index = 1
                elseif v.class == "ROGUE" then
                    tbl[i].index = 2
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
                for _, i in ipairs({ 1, 4, 2, 5, 3, 6 }) do
                    if not done[i] then
                        TJ.SetEditTextFormNum(v, title, i)
                        done[i] = true
                        break
                    end
                end
            end
        end
        local text = L["安排猎人和盗贼。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "ability_hunter_misdirection", L["P2误导/嫁祸"],
            text, { "HUNTER", "ROGUE" }, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["左侧小怪"])
        TJ.CreateEdit(FB, bossIndex, L["左侧小怪"])
        TJ.CreateEdit(FB, bossIndex, L["左侧小怪"])
        TJ.CreateEdit(FB, bossIndex, L["右侧小怪"])
        TJ.CreateEdit(FB, bossIndex, L["右侧小怪"])
        TJ.CreateEdit(FB, bossIndex, L["右侧小怪"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 换嘲
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 123707 },
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
                destNPCID = { 62837 },
                notShowCount = true,
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_gizmo_hardenedadamantitetube", L["换嘲"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 不谐力场
    do
        local info = {
            {
                castSuccess = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 123255 },
                        },
                    },
                },
                title = { name = L["召唤不谐力场"] }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 123788, },
                            colorNum = 5,
                        },
                        {
                            spellID = { 123184, },
                            colorNum = 1,
                        }
                    },
                    durTimeMin = 2,
                },
                title = { name = L["进入不谐力场"] }
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
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_holy_persecution", L["不谐力场"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 音速倾泻
    do
        local info = {
            {
                castSuccess = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 123504, },
                            colorNum = 2,
                        },
                    },
                },
            },
            isMany = true,
        }
        tinsert(info, TJ.combatInfoMore)
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_holy_persecution", L["音速倾泻"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 凝视
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 125390, },
                            colorNum = 2,
                        },
                    },
                },
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                125886
                            },
                            colorNum = 1,
                            tooltip = "beDamage2+castAll",
                            combatRole = { "Isdps", "Ishealer" },
                        },
                    },
                },
                canSend = "count",
                title = { name = L["音速之刃"], icon = 125886 }
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_unholyfrenzy", L["小怪凝视"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 浸毒
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 124821, },
                        },
                    },
                },
                notShowDead = true,
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 124827 },
                        },
                    },
                },
                notShowDead = true,
                title = { name = L["毒雾"] }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_creature_poison_06", L["浸毒"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 死亡幻象
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 124862 },
                            colorNum = 2,
                        },
                    },
                },
                title = { name = L["死亡幻象"], icon = 124862 }
            },
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = ns.sp["战栗"],
                            colorNum = 1,
                        },
                    },
                },
                title = { name = L["战栗图腾"], icon = 8143 }
            },
            {
                damageFriend = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                124868
                            },
                            colorNum = 1
                        },
                    },
                },
                title = { name = L["死亡幻象误伤"], icon = "inv_misc_eye_03" }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_hunter_markedfordeath", L["死亡幻象"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 恐惧吞噬
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            124849
                        },
                        colorNum = 1
                    },
                },
            },
            canSend = "count",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_shadowpower", L["恐惧吞噬"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 恐惧之心
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            123845
                        },
                        colorNum = 2
                    },
                },
            },
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            125638
                        },
                        colorNum = 1
                    },
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "sha_inv_elemental_primal_shadow", L["恐惧之心"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    TJ.frame[FB][bossIndex].BOSS_SAY = function(msg)
        if msg:match("我必须有更大的力量") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
            return
        end
        if msg:match("我要处决") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P1",
            })
            return
        end
        if msg:match("别找借口了") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P3",
            })
            return
        end
    end
end
