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
local FB = "ZUGtitan"
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

    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 349, -263 } },
            { point = "TOPLEFT", xy = { 254, -259 } },
            { point = "TOPLEFT", xy = { 446, -260 } },
            { point = "TOPLEFT", xy = { 297, -176 } },
            { point = "TOPLEFT", xy = { 400, -177 } },
            { point = "TOPLEFT", xy = { 83, -232 } },
            { point = "TOPLEFT", xy = { 186, -234 } },
            { point = "TOPLEFT", xy = { 145, -182 } },
            { point = "TOPLEFT", xy = { 107, -121 } },
            { point = "TOPLEFT", xy = { 210, -125 } },
            { point = "TOPLEFT", xy = { 634, -228 } },
            { point = "TOPLEFT", xy = { 520, -231 } },
            { point = "TOPLEFT", xy = { 568, -168 } },
            { point = "TOPLEFT", xy = { 614, -122 } },
            { point = "TOPLEFT", xy = { 496, -126 } },
            { point = "TOPLEFT", xy = { 298, -325 } },
            { point = "TOPLEFT", xy = { 413, -326 } },

            [80] = {
                xy = { 723, -22 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["空气\n图腾"],
                isNPC_icon = "Interface\\Icons\\spell_nature_slowingtotem",
            },
            [98] = {
                xy = { 350, -29 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [99] = {
                xy = { 352, -104 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["坦克"],
                isNPC_icon = "Interface\\Icons\\Spell_Deathknight_BloodPresence",
            },
            [100] = { xy = { 352, -66 }, isNPC = "b" .. bossIndex },
        }

        --[[


]]

        local function AutoFuc()
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
            L["治疗：1-5号位。"],
            L["远程DPS：6-17号位。"],
        }

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local width = 700
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 2424 * 1500, nil, nil, nil, "v1.26.9")
        -- 原尺寸2424 * 1356
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

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 心控
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                24327,
                            },
                            colorNum = 1,
                        }
                    },
                    destNpcType = { "Player" },
                    title = { name = L["被心控"] },
                },
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
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_shadowworddominate", L["心控"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 堕落之血
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            24328,
                        },
                        colorNum = 1,
                    }
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_corpseexplode", L["堕落之血"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 血液虹吸
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                24324,
                            },
                            colorNum = 2
                        },
                    },
                },
                title = { name = L["施放血液虹吸"] },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                24323,
                            },
                            colorNum = 1,
                        }
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["酸性血液虹吸"], icon = 24323 },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                24322,
                            },
                            colorNum = 1,
                        }
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["血液虹吸（没踩绿水）"], icon = 24323, color = { 1, 0, 0 } },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_lifedrain", L["血液虹吸"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("") then
            return
        end
    end
end
