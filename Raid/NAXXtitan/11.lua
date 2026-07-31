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
local bossIndex = 11
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
        TJ.CreateEdit(FB, bossIndex, L["小怪"])
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
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_animatedead", L["解诅咒"],
            text, { "SHAMAN", "DRUID", "MAGE", }, nil, nil)
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
    end

    -- 驱散
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排奶牧、奶骑。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_cripple", L["驱散残废"],
            text, { "PRIEST", "PALADIN" }, nil, nil)
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 驱散
    do
        local info = {
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                54835,
                            },
                            colorNum = 1
                        }
                    },
                    sourceNpcType = { "Player" },
                },
                title = { name = L["驱散药剂师诅咒"], icon = 54835 },
                notShowDead = true,
            },
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                54814,
                            },
                            colorNum = 1
                        }
                    },
                    sourceNpcType = { "Player" },
                },
                title = { name = L["驱散残废"], icon = 54814 },
                notShowDead = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_animatedead", L["驱散"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)

        TJ.AddDispelInfo(54835, 2, FB, bossIndex)
        TJ.AddDispelInfo(54814, 1, FB, bossIndex)
    end

    -- 转火小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    16983, 16984
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warrior_cleave", L["转火小怪"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("传送到了上层平台") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
            return
        end
        if msg:match("再次投入") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P1",
            })
            return
        end
    end
end
