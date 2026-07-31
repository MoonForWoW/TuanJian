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
local bossIndex = 9
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
        TJ.CreateEdit(FB, bossIndex, L["主坦克"])
        TJ.CreateEdit(FB, bossIndex, L["副坦克"])
    end

    -- 驱散妖术
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, 'healer', true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排奶牧/奶骑。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_polymorph", L["驱散妖术"],
            text, { "PRIEST", "PALADIN" }, nil, nil)
        TJ.CreateEdit(FB, bossIndex, L["驱散妖术"])
        TJ.CreateEdit(FB, bossIndex, L["驱散妖术"])
        TJ.CreateEdit(FB, bossIndex, L["驱散妖术"])
    end

    -- 驱散诅咒
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
        local text = L["安排奶萨/奶德/鸟德/法师。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_unholyfrenzy", L["解诅咒"],
            text, { "SHAMAN", "DRUID", "MAGE" }, nil, nil)
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
        TJ.CreateEdit(FB, bossIndex, L["解诅咒"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 放逐
    do
        local info = {
            {
                castSuccess = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                24466,
                            },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = L["点名"],
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_magic_lesserinvisibilty", L["放逐"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 驱散恢复
    do
        local info = {
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                17172,
                            },
                            colorNum = 1,
                        },
                    },
                    sourceNpcType = { "Player" },
                },
                title = { name = L['驱散妖术'], icon = 17172 }
            },
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                24306,
                            },
                            colorNum = 1,
                        },
                    },
                    sourceNpcType = { "Player" },
                },
                title = { name = L['驱散金度的欺骗'], icon = 24306 }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_polymorph", L["驱散"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火图腾
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    15112, 14987
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_totem_wardofdraining", L["转火图腾"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    TJ.AddDispelInfo(24306, 2, FB, bossIndex) -- 24306/金度的欺骗
    TJ.AddDispelInfo(17172, 1, FB, bossIndex) -- 17172/妖术


    mainFrame.BOSS_SAY = function(msg)
        if msg:match("") then
            return
        end
    end
end
