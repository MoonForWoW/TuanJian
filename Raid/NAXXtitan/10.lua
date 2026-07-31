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

    local instanceID = TJ.FBinfo[FB].ID
    TJ.autoRaidTargetInfo[instanceID] = TJ.autoRaidTargetInfo[instanceID] or {}
    TJ.autoRaidTargetInfo[instanceID][16064] = {
        [8] = true,
        np = true,
    }
    TJ.autoRaidTargetInfo[instanceID][30549] = {
        [7] = true,
        np = true,
    }
    TJ.autoRaidTargetInfo[instanceID][16065] = {
        [6] = true,
        np = true,
    }
    TJ.autoRaidTargetInfo[instanceID][16063] = {
        [5] = true,
        np = true,
    }

    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 89, -367 } },
            { point = "TOPLEFT", xy = { 536, -374 } },
            { point = "TOPLEFT", xy = { 514, -293 } },
            { point = "TOPLEFT", xy = { 215, -75 } },
            { point = "TOPLEFT", xy = { 411, -76 } },
            { point = "TOPLEFT", xy = { 157, -74 } },
            { point = "TOPLEFT", xy = { 470, -77 } },

            [99] = {
                xy = { 104, -286 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["其他人"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [100] = { xy = { 96, -326 }, isNPC = "b" .. bossIndex .. "-" .. 1 },
            [101] = { xy = { 529, -333 }, isNPC = "b" .. bossIndex .. "-" .. 2 },
            [102] = { xy = { 189, -46 }, isNPC = "b" .. bossIndex .. "-" .. 3 },
            [103] = { xy = { 442, -48 }, isNPC = "b" .. bossIndex .. "-" .. 4 },
        }

        --[[

]]

        local function AutoFuc()
            local tbl = TJ.SortRaidRosterInfo(nil, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, { min = 1, max = 2 })
            end
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST", "DRUID", "SHAMAN", "PALADIN" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, { min = 3, max = 5 })
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "dps1", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, { min = 6, max = 7 })
            end
        end
        local text = {
            L["1、2：坦克。"],
            L["3、4、5：治疗。"],
            L["6、7：近战DPS。"],
        }

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local width = 600
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 1086 * 777, nil, nil, nil, "v1.26.2")
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 库尔塔兹印记
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                28832,
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["库尔塔兹印记"], icon = 28832 },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_deathpact", L["库尔塔兹"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 瑞文戴尔印记
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                28834,
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["瑞文戴尔印记"], icon = 28834 },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_soulleech_3", L["瑞文戴尔"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 布劳缪克丝印记
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                28833,
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["布劳缪克丝印记"], icon = 28833 },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_mindtwisting", L["布劳缪克丝"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 瑟里耶克印记
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                28835,
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["瑟里耶克印记"], icon = 28835 },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_soulleech_2", L["瑟里耶克"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 神圣愤怒
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                57466, 28883
                            },
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["受到%s伤害（连线）"]:format(L["神圣愤怒"]) },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_siphonmana", L["神圣愤怒"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    local ids = {
        [16065] = L["女公爵布劳缪克丝"],
        [16064] = L["库尔塔兹领主"],
        [30549] = L["瑞文戴尔男爵"],
        [16063] = L["瑟里耶克爵士"],
    }
    local count = 4
    mainFrame.UNIT_DIED = function(...)
        local tbl = { ... }
        if ids[TJ.GetNPCID(tbl[8])] then
            count = count - 1
            if count > 0 then
                tinsert(TJ.GetNewCombatLog().otherTime, {
                    time = TJ.GetDurTime(),
                    name = count .. "/4",
                })
            end
        end
    end

    mainFrame.ENCOUNTER_START = function()
        count = 4
    end
end
