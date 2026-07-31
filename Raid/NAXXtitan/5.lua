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

    -- 自动标记
    local name = "rt" .. FB .. bossIndex
    do
        mainFrame.SPELL_AURA_APPLIED = function(...)
            local tbl = { ... }
            if TuanJian.options[name] == 1 and TJ.IsLeader() and tbl[12] == 28169 then
                SetRaidTarget(tbl[9], 7)
            end
        end

        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local icon = TJ.SetRaidTargetingIcons(nil, "chacha")
        local ontext = {
        }
        local f = ns.O.CreateCheckButton(name, format(L["%s把变异注射标记为%s（需要团长/助理）"], AddTexture(136127), icon),
            mainFrame, 40, -150, ontext)
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", TJ.spChild.title, "TOPRIGHT", 0, 15)
        f:SetHitRectInsets(0, 0, 0, 0)
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

    -- 驱散
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST", "SHAMAN", }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排奶牧、奶萨。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_callofbone", L["驱散变异注射"],
            text, { "PRIEST", "SHAMAN", "PALADIN" }, nil, nil, nil,
            nil)
        TJ.CreateEdit(FB, bossIndex, L["驱散变异注射"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 软泥喷射
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                54364, 28157
                            },
                            colorNum = 1,
                        }
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = { name = L["受到%s伤害"]:format(L["软泥喷射"]) },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_corrosivebreath", L["软泥喷射"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 中毒
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                54363, 28241
                            },
                            colorNum = 1,
                        }
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = { name = L["受到%s伤害"]:format(L["中毒"]) },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_corpseexplode", L["踩毒圈"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 变异注射
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                28169
                            },
                            colorNum = 1,
                        }
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["点名"] },
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                28169,
                            },
                            colorNum = 1,
                        }
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = { name = L["受到%s伤害"]:format(L["变异爆炸"]) },
            },
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                28169,
                            },
                            colorNum = 1
                        }
                    },
                },
                title = { name = L["驱散变异注射"] },
                notShowDead = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_callofbone", L["变异注射"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("") then
            return
        end
    end
end
