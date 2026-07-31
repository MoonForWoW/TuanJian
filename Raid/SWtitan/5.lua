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
local bossIndex = 5
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
            for _, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排坦克。虚空哨兵坦克在P2接熵魔。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil, true)
        TJ.CreateEdit(FB, bossIndex, L["入口小怪"])
        TJ.CreateEdit(FB, bossIndex, L["出口小怪"])
    end

    -- 群驱黑暗魔
    do
        local function AutoFuc(title)
            local priest = TJ.SortRaidRosterInfo({ "PRIEST" }, 'healer', true)
            for _, v in ipairs(priest) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排奶牧。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_arcane_massdispel", L["群驱黑暗魔"],
            text, { "PRIEST", "SHAMAN" }, nil, nil, nil, nil)
        TJ.CreateEdit(FB, bossIndex, L["群驱黑暗魔"])
        TJ.CreateEdit(FB, bossIndex, L["群驱黑暗魔"])
    end

    TJ.CreateSPTitle(FB, bossIndex, { 25741, 25840, 25772 }, nil)

    -- 驱散暗魔
    do
        local info = {
            dispel = {
                type = "s",
                destNPCID = {
                    25744, -- 暗魔
                },
                showCount = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_arcane_massdispel", L["驱散黑暗魔"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 黑暗魔爆炸
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                45944,
                            },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                    notPeriodicDamage = true,
                },
                title = { name = L["受到%s伤害"]:format(L["黑暗魔爆炸"]) },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_shadowfiend", L["黑暗魔爆炸"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 偷法术之怒
    do
        local info = {
            dispel = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            46102, -- 法术之怒
                        },
                        colorNum = 1,
                    },
                },
                showCount = true,
            },
            title = { name = L["偷法术之怒"] }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_felfirenova", L["偷法术"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 踩黑水
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            45996, 45998, -- P1黑暗
                            46264,        -- P2黑暗
                        },
                        colorNum = 1,
                    },
                },
                destNpcType = { "Player" },
                showCount = true,
            },
            title = { name = L["受到%s伤害（踩黑水）"]:format(L["黑暗"]) },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_shadesofdarkness", L["踩黑水"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 奇点
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            46238,
                        },
                        colorNum = 1,
                    },
                },
                destNpcType = { "Player" },
                showCount = true,
            },
            title = { name = L["受到%s伤害"]:format(L["奇点"]) },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_seedofdestruction", L["奇点"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    25798, -- 暗誓狂暴者
                    25799, -- 暗誓怒火法师
                    25772, -- 虚空戒卫
                    25824, -- 虚空爪牙
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warrior_cleave", L["转火小怪"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- P2清场小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    25798, 25799, 25772, 25824,
                },
                startTime = "P2",
                endTime = "duration",
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warrior_cleave", L["P2清场"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- P2熵魔伤害
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    25840,
                },
                startTime = "P2",
                endTime = "duration",
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_shadowfury", L["P2熵魔"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.SPELL_CAST_SUCCESS = function(...)
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == 46177 and not TJ.SetCD(mainFrame, 5, spellID) then
            local combatLog = TJ.GetNewCombatLog()
            TJ.AddTimer(10, function()
                if TJ.GetNewCombatLog() == combatLog then
                    tinsert(combatLog.otherTime, {
                        time = TJ.GetDurTime(),
                        name = "P2",
                    })
                end
            end)
        end
    end
end
