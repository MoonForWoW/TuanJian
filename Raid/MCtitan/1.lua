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
    local instanceID = TJ.FBinfo[FB].ID
    TJ.autoRaidTargetInfo[instanceID] = TJ.autoRaidTargetInfo[instanceID] or {}
    TJ.autoRaidTargetInfo[instanceID][11666] = { [8] = true }              -- 火焰行者
    TJ.autoRaidTargetInfo[instanceID][11667] = { [7] = true }              -- 烈焰守卫
    TJ.autoRaidTargetInfo[instanceID][12076] = { [6] = true, [5] = true, } -- 熔岩元素

    TJ.autoRaidTargetInfo[instanceID][12118] = { [6] = true }              -- BOSS
    TJ.autoRaidTargetInfo[instanceID][12119] = { [8] = true, [7] = true, } -- 小怪

    -- DEBUG
    -- TJ.autoRaidTargetInfo[530] = {
    --     [18799] = { [8] = true },
    --     [18336] = { [7] = true },
    --     [16222] = {
    --         [1] = true,                -- 星星
    --         [2] = true,                -- 大饼
    --         [3] = true,                -- 紫菱
    --         [4] = true,                -- 三角
    --         [5] = true,                -- 月亮
    --         [6] = true,                -- 方块
    --         [7] = true,                -- 叉叉
    --         [8] = true,                -- 骷髅
    --         np=true,
    --     },
    --     [19169] = TJ.autoRaidTargetIcon1,

    --     [23988] = TJ.autoRaidTargetIcon1,
    --     [25207] = TJ.autoRaidTargetIcon1,
    --     [25200] = TJ.autoRaidTargetIcon1,
    --     [25202] = TJ.autoRaidTargetIcon1,
    -- }
    -- TJ.autoRaidTargetInfo[1] = {
    --     [3100] = TJ.autoRaidTargetIcon1,
    -- }

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

    -- 驱散末日降临
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, nil, true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "dps", true)
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
                            19702,
                        },
                        colorNum = 1,
                        frameLevel = 1,
                    },
                },
                sourceNpcType = { "Player" },
            }
        }
        local text = L["安排所有牧师、惩戒骑。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_nightofthedead", L["驱散末日降临"],
            text, { "PRIEST", "PALADIN" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])

        TJ.AddDispelInfo(19702, 1, FB, bossIndex)
    end

    -- 驱散心控
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, nil, true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, nil, true)
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
                            20604,
                        },
                        colorNum = 1,
                        frameLevel = 1,
                    },
                },
                sourceNpcType = { "Player" },
            }
        }
        local text = L["安排所有牧师、萨满。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_shadowworddominate", L["驱散心控"],
            text, { "PRIEST", "SHAMAN" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["驱散心控"])
        TJ.CreateEdit(FB, bossIndex, L["驱散心控"])
        TJ.CreateEdit(FB, bossIndex, L["驱散心控"])
        TJ.CreateEdit(FB, bossIndex, L["驱散心控"])
        TJ.CreateEdit(FB, bossIndex, L["驱散心控"])
        TJ.CreateEdit(FB, bossIndex, L["驱散心控"])

        TJ.AddDispelInfo(20604, 1, FB, bossIndex)
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
                            19703,
                        },
                        colorNum = 1,
                        frameLevel = 1,
                    },

                },
                sourceNpcType = { "Player" },
            }
        }
        local text = L["安排法师、奶德和鸟德。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_blackplague", L["解诅咒"],
            text, { "DRUID", "MAGE" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])

        TJ.AddDispelInfo(19703, 2, FB, bossIndex)
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 顺劈斩
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            20605,
                        },
                        colorNum = 1,
                        combatRole = { "Isdps", "Ishealer" },
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warrior_cleave", L["顺劈斩"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 滋补药剂
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            11359,
                        },
                        colorNum = 1,
                    },
                },
                showCount = true,
            },
            canSend = "count",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_potion_01", L["滋补药剂"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
end
