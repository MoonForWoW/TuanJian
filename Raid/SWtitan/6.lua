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

    mainFrame.saveAura = {
        [45839] = true, -- 蓝龙的复仇
    }

    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 429, -271 } },
            { point = "TOPLEFT", xy = { 391, -169 } },
            { point = "TOPLEFT", xy = { 294, -130 } },
            { point = "TOPLEFT", xy = { 448, -130 } },
            { point = "TOPLEFT", xy = { 348, -19 } },
            { point = "TOPLEFT", xy = { 549, -214 } },
            { point = "TOPLEFT", xy = { 497, -334 } },
            { point = "TOPLEFT", xy = { 215, -77 } },
            { point = "TOPLEFT", xy = { 424, -217 } },
            { point = "TOPLEFT", xy = { 349, -140 } },
            { point = "TOPLEFT", xy = { 506, -263 } },
            { point = "TOPLEFT", xy = { 483, -194 } },
            { point = "TOPLEFT", xy = { 376, -78 } },
            { point = "TOPLEFT", xy = { 297, -65 } },
            { point = "TOPLEFT", xy = { 516, -140 } },
            { point = "TOPLEFT", xy = { 467, -75 } },
            { point = "TOPLEFT", xy = { 413, -36 } },

            [80] = {
                xy = { 620, -23 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["空气\n图腾"],
                isNPC_icon = "Interface\\Icons\\spell_nature_slowingtotem",
            },
            [90] = {
                xy = { 524, -82 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["宝珠"],
                isNPC_icon = "Interface\\Icons\\inv_misc_orb_01",
                size = 32,
            },
            [91] = {
                xy = { 73, -91 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["宝珠"],
                isNPC_icon = "Interface\\Icons\\inv_misc_orb_01",
                size = 32,
            },
            [92] = {
                xy = { 532, -438 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["宝珠"],
                isNPC_icon = "Interface\\Icons\\inv_misc_orb_01",
                size = 32,
            },
            [93] = {
                xy = { 72, -455 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["宝珠"],
                isNPC_icon = "Interface\\Icons\\inv_misc_orb_01",
                size = 32,
            },
            [98] = {
                xy = { 261, -192 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [99] = {
                xy = { 370, -320 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["坦克"],
                isNPC_icon = "Interface\\Icons\\Spell_Deathknight_BloodPresence",
            },
            [100] = { xy = { 301, -271 }, isNPC = "b" .. bossIndex, size = 70, },
        }

        --[[




]]

        local function AutoFuc()
            local tbl = TJ.SortRaidRosterInfo({ 'MAGE' }, "", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, { min = 7, max = 8 })
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
        end
        local text = {
            L["1-6：治疗。"],
            L["7-8：法师。"],
            L["8-17：远程DPS。"],
        }

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local width = 600
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 879 * 779, nil, nil, nil, "v2.0.3")
    end

    -- 坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                if v.class == 'DEATHKNIGHT' then
                    TJ.SetEditText(v, title)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
                break
            end
        end
        local text = L["主坦克承受BOSS，副坦克接邪恶镜像。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass)
        TJ.CreateEdit(FB, bossIndex, L["BOSS"])
        TJ.CreateEdit(FB, bossIndex, L["邪恶镜像"])
    end

    -- 蓝龙宝珠
    do
        local function AutoFuc(title)
            for _, v in ipairs(TJ.SortRaidRosterInfo({ 'MAGE' }, "", true)) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排法师。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "inv_misc_orb_01", L["控龙"],
            text)
        TJ.CreateEdit(FB, bossIndex, L["控龙"])
        TJ.CreateEdit(FB, bossIndex, L["控龙"])
    end

    TJ.CreateSPTitle(FB, bossIndex, { 25315 }, nil)

    -- 火焰之花
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 45641 },
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = L["点名"],
            },
            {
                damageFriend = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 45642 },
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = { name = L["误伤队友"] },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_burnout", L["火焰之花"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 暗影之刺
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = { 45885 },
                        colorNum = 1,
                    },
                },
                destNpcType = { "Player" },
                showCount = true,
            },
            title = { name = L["受到%s伤害"]:format(L["暗影之刺"]) },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_painspike", L["暗影之刺"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 末日决战
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = { 45915 },
                        colorNum = 1,
                    },
                },
                destNpcType = { "Player" },
                showCount = true,
            },
            title = { name = L["受到%s伤害"]:format(L["末日决战"]) },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_meteorstorm", L["末日决战"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 千魂之暗
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 46605 },
                            colorNum = 2,
                        },
                    },
                },
                title = { name = L["Boss开始读条千魂之暗"], },
                canSend = "count",
            },
            -- {
            --     beDamage = {
            --         type = "d",
            --         spell = {
            --             {
            --                 spellID = { 45657 },
            --                 colorNum = 1,
            --             },
            --         },
            --         destNpcType = { "Player" },
            --         showCount = true,
            --     },
            --     title = { name = L["受到%s伤害"]:format(L["千魂之暗"]) },
            -- },
            {
                aura = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 45839 },
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = { name = L["控龙"], icon = 45839 },
            },
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 45848 },
                            colorNum = 1,
                        },
                    },
                    showCount = true,
                },
                title = { name = L["施放%s"]:format(L["蓝龙护盾"]), icon = 45848 },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 45848 },
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = { name = L["获得BUFF：蓝龙护盾"], icon = 45848 },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_twilight", L["千魂之暗"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 龙息增益
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 45856 },
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = { name = L["龙息：急速"], icon = 45856 },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 45860 },
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = { name = L["龙息：恢复"], icon = 45860 },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_blueflamebreath", L["龙息增益"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火宝珠
    do
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = { 25502 },
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_misc_orb_04", L["转火宝珠"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火镜像
    do
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = { 25708 },
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_magic_lesserinvisibilty", L["转火镜像"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    local phase = 2
    local bossStarted
    mainFrame.ENCOUNTER_START = function()
        phase = 2
        bossStarted = nil
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("这个消耗品已经没用了") and not bossStarted then
            bossStarted = true
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
        end
    end

    mainFrame.SPELL_CAST_SUCCESS = function(...)
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == 45892 and phase < 5 and not TJ.SetCD(mainFrame, 2, spellID) then
            phase = phase + 1
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P" .. phase,
            })
        end
    end
end
