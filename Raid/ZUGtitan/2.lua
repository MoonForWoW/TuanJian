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
local bossIndex = 2
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
        TJ.Once('map', 260600, function()
            TuanJian[FB][bossIndex].map = {}
        end)

        local tbl = {
            [80] = {
                xy = { 724, -109 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["空气\n图腾"],
                isNPC_icon = "Interface\\Icons\\spell_nature_slowingtotem",
            },
            [90] = {
                xy = { 724, -22 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["全部\n奶骑"],
                isNPC_icon = "Interface\\Icons\\spell_holy_holybolt",
            },
            [91] = {
                xy = { 724, -65 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["其他\n治疗"],
                isNPC_icon = "Interface\\Icons\\spell_holy_wordfortitude",
            },

            [94] = {
                xy = { 359, -318 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["5队\n治疗"],
                isNPC_icon = "Interface\\Icons\\spell_holy_holybolt",
            },
            [95] = {
                xy = { 496, -313 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["4队\n远程"],
                isNPC_icon = "Interface\\Icons\\ability_marksmanship",
            },
            [96] = {
                xy = { 355, -194 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["3队\n远程"],
                isNPC_icon = "Interface\\Icons\\ability_marksmanship",
            },
            [97] = {
                xy = { 515, -219 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["2队\n近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [98] = {
                xy = { 471, -163 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["1队\n近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [99] = {
                xy = { 548, -146 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["坦克"],
                isNPC_icon = "Interface\\Icons\\Spell_Deathknight_BloodPresence",
            },
            [100] = { xy = { 515, -174 }, isNPC = "b" .. bossIndex },
        }
        --[[

]]
        local function AutoFuc()
        end
        local text = {
        }

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local width = 700
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 2103 * 1394, nil, nil, nil, "v1.26.9")
        -- 原尺寸2103 * 1394
        local t = map:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 25, "OUTLINE")
        t:SetPoint("TOPLEFT", 20, -20)
        t:SetText(L["每个小队重叠站位"])
    end

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

    -- 驱散恢复
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST", 'SHAMAN', 'MAGE' }, '', true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排奶牧/奶萨。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_holy_renew", L["进攻驱散恢复"],
            text, { "PRIEST", 'SHAMAN', 'MAGE' }, nil, nil)
        TJ.CreateEdit(FB, bossIndex, L["驱散恢复"])
        TJ.CreateEdit(FB, bossIndex, L["驱散恢复"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 神圣怒火
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            23979
                        },
                    },
                },
                destNpcType = { "Player" },
            },
            castSuccess = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            23979,
                        },
                        colorNum = 2,
                        frameLevel = 2,
                    },
                },
                destNpcType = { "Player" },
            },
            title = { name = L["受到%s伤害"]:format(L["神圣怒火"]) },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_siphonmana", L["神圣怒火"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 驱散恢复
    do
        local info = {
            dispel = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            23895,
                        },
                        colorNum = 1,
                        frameLevel = 1,
                    },
                },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_holy_renew", L["驱散恢复"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    TJ.AddDispelInfo(23895, 1, FB, bossIndex) -- 恢复
    TJ.AddDispelInfo(22412, 4, FB, bossIndex) -- 恶性毒药
    TJ.AddDispelInfo(24097, 4, FB, bossIndex) -- 中毒

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("") then
            return
        end
    end
end
