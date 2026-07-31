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
local bossIndex = 7
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

    -- 驱散寄生
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "DRUID", "PRIEST", "SHAMAN", "MONK" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排一个治疗。"]
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                133597,
                            },
                            colorNum = 1
                        },
                        {
                            spellID = {
                                133598,
                            },
                            colorNum = 5
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["寄生"] },
            },
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                133597,
                            },
                            colorNum = 1
                        }
                    },
                    sourceNpcType = { "Player" },
                },
                title = { name = L["驱散寄生"] },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_curseofmannoroth", L["驱散寄生"],
            text, TJ.healerClass, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["驱散寄生"])
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
                            spellID = { 133767, },
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
                    destNPCID = { 69712 },
                    notShowCount = true,
                },
                title = { name = L["严重致伤"], icon = 133767 }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 133768, },
                            colorNum = 2,
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["动脉出血"], icon = 133768 }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_reincarnation", L["换嘲"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 紫水点名
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 134626, },
                        },
                    },
                    destNpcType = { "Player" },
                },
            },
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                8177
                            },
                        },
                    },
                },
                notShowDead = true,
                title = { name = L["使用根基图腾"], icon = 8177 }
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_misc_eye_03", L["紫水点名"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 意志之力
    do
        local info = {
            {
                castSuccess = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 136932 },
                            colorNum = 1,
                        },
                    },
                },
                title = L["点名"],
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                136932, 136413
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                canSend = "count",
                title = { name = L["受到%s伤害"]:format(L["意志之力"]), icon = 136932 }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_monk_forcesphere", L["意志之力"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 光谱点名
    do
        local info = {
            {
                castSuccess = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 134123 },
                            colorNum = 1,
                        },
                    },
                },
                title = { name = L["红光点名"], icon = 134123 }
            },
            {
                castSuccess = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 134124 },
                            colorNum = 1,
                        },
                    },
                },
                title = { name = L["黄光点名"], icon = 134124 }
            },
            {
                castSuccess = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 134122 },
                            colorNum = 1,
                        },
                    },
                },
                title = { name = L["蓝光点名"], icon = 134122 }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_misc_gem_variety_02", L["光谱点名"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火徘徊
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    68024
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_misc_eye_03", L["转火徘徊"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火冰墙
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    69582, 68291, 69582
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_frost_frostnova", L["转火冰墙"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 迷宫承伤
    do
        local info = {
            dps = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            134755,
                        },
                    },
                },
                destNpcType = { "Player", },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_arcane_arcane01", L["迷宫承伤"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("") then
            return
        end
    end
end
