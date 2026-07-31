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
local bossIndex = 6
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
                TJ.SetEditTextFormNum(v, title, 3)
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
            nil)
        TJ.CreateEdit(FB, bossIndex, L["BOSS主坦"])
        TJ.CreateEdit(FB, bossIndex, L["BOSS副坦"])
        TJ.CreateEdit(FB, bossIndex, L["小怪坦"])
    end

    -- 冰霜陷阱
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排猎人。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_frost_freezingbreath", L["冰霜陷阱"],
            text, { "HUNTER", }, nil, nil)
        TJ.CreateEdit(FB, bossIndex, L["冰霜陷阱"])
        TJ.CreateEdit(FB, bossIndex, L["冰霜陷阱"])
        TJ.CreateEdit(FB, bossIndex, L["冰霜陷阱"])
    end

    -- 宁神
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排猎人。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_drowsy", L["宁神"],
            text, { "HUNTER", }, nil, nil)
        TJ.CreateEdit(FB, bossIndex, L["宁神"])
        TJ.CreateEdit(FB, bossIndex, L["宁神"])
        TJ.CreateEdit(FB, bossIndex, L["宁神"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 致命伤
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                54378,
                            },
                            colorNum = 1
                        },
                    },
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_criticalstrike", L["致命伤"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 感染之伤
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                29306,
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_nullifydisease", L["感染之伤"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 激怒
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                54427, 28371
                            },
                            colorNum = 1
                        },
                    },
                },
            },
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                54427, 28371
                            },
                            colorNum = 1
                        }
                    },
                },
                title = { name = L["宁神"], icon = 19801, },
                notShowDead = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_druid_challangingroar", L["激怒"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 冰霜陷阱
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                13809,
                            },
                            colorNum = 2
                        },
                    },
                },
                title = { name = L["施放冰霜陷阱"] },
            },
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                2484,
                            },
                            colorNum = 2
                        },
                    },
                },
                title = { name = L["施放地缚图腾"], icon = 2484 },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_frost_freezingbreath", L["陷阱/地缚"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 招大军
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                42650,
                            },
                            colorNum = 2
                        },
                    },
                },
                title = { name = L["施放大军"] },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_deathknight_armyofthedead", L["招大军"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火小怪
    do
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        16360
                    },
                    phase = "cs1",
                },
                title = { name = L["第1次残杀"] },
            },
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        16360
                    },
                    phase = "cs2",
                },
                title = { name = L["第2次残杀"] },
            },
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        16360
                    },
                    phase = "cs3",
                },
                title = { name = L["第3次残杀"] },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_purge", L["转火小怪(残杀阶段)"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    local count = 0
    mainFrame.ENCOUNTER_START = function(...)
        count = 0
    end
    mainFrame.BOSS_SAY = function(msg)
        if msg:match("发动了残杀") and not TJ.SetCD(mainFrame, 1) then
            count = count + 1
            local t = TJ.GetDurTime()
            tinsert(TJ.GetNewCombatLog().otherTime, {
                startTime = t,
                endTime = t + 20,
                name = "cs" .. count,
            })
            return
        end
    end
end
--[[
local count = 2
local t = 50
tinsert(TJ.GetCombatLog().otherTime, {
    startTime = t,
    endTime = t + 20,
    name = "cs"..count,
})

]]
