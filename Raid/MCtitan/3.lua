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
local FB = "MCtitan"
local bossIndex = 3
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
    local instanceID = TJ.FBinfo[FB].ID
    TJ.autoRaidTargetInfo[instanceID][12259] = { [6] = true }              -- BOSS
    TJ.autoRaidTargetInfo[instanceID][11661] = { [8] = true, [7] = true, } -- 小怪

    -- 坦克
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
                if v.class == "PALADIN" then
                    TJ.SetEditTextFormNum(v, title, 2)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["BOSS优先安排DKT，小怪优先安排防骑。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil, nil)
        TJ.CreateEdit(FB, bossIndex, L["BOSS坦"])
        TJ.CreateEdit(FB, bossIndex, L["小怪坦"])
    end

    -- 驱散诅咒
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "MAGE" }, nil, true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo({ "DRUID" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo({ "DRUID" }, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local info = {
            dispel = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            19716,
                        },
                        colorNum = 1,
                        frameLevel = 1,
                    },

                },
                sourceNpcType = { "Player" },
            }
        }
        local text = L["安排法师、奶德和鸟德。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_gathershadows", L["解诅咒"],
            text, { "DRUID", "MAGE" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])

        TJ.AddDispelInfo(19716, 2, FB, bossIndex)
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 火焰之雨
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            19717,
                        },
                        colorNum = 1,
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_rainoffire", L["火焰之雨"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 拉格纳罗斯之拳
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                6615,
                            },
                            colorNum = 6,
                        },
                        {
                            spellID = {
                                20277,
                            },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                6615,
                            },
                            colorNum = 6,
                        },
                    },
                    showCount = true,
                },
                canSend = "count",
                title = { name = L["自由行动药水"], icon = 6615 },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_holy_sealofwrath", L["拉格纳罗斯之拳"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 自由行动药水
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            6615,
                        },
                        colorNum = 6,
                    },
                },
                showCount = true,
            },
            canSend = "count",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_potion_04", L["自由行动药水"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
end
