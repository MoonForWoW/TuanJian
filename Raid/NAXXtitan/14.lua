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
local bossIndex = 14
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

    -- 驱散
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN", "DRUID" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo({ "DRUID" }, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo({ "MAGE" }, nil, true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排奶萨、奶德、鸟德、法师。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_lifedrain02", L["解诅咒"],
            text, { "SHAMAN", "DRUID", "MAGE", }, nil, nil)
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
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
                                19983
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
                                55696, 55697,
                            },
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["受到%s伤害"]:format(L["扫尾"]), icon = 55696 },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warrior_cleave", L["顺劈斩"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 驱散
    do
        local info = {
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                55665,
                            },
                            colorNum = 1
                        }
                    },
                    sourceNpcType = { "Player" },
                },
                title = { name = L["驱散生命吸取"] },
                notShowDead = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_lifedrain02", L["驱散"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)

        TJ.AddDispelInfo(55665, 2, FB, bossIndex)
    end

    -- 冰冻
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                28522,
                            },
                            colorNum = 1
                        },
                    },
                },
                notShowDead = true,
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                28524,
                            },
                            colorNum = 1,
                        }
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                    notMiss = true,
                },
                title = { name = L["受到%s伤害"]:format(L["冰霜吐息"]), icon = 28524 },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_frost_glacier", L["冰冻"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 冰霜吐息
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                28524,
                            },
                            colorNum = 1,
                        }
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                    notMiss = true,
                },
                title = { name = L["受到%s伤害"]:format(L["冰霜吐息"]) },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_frost_arcticwinds", L["冰霜吐息"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("") then
            return
        end
    end
end
