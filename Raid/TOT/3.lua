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
    local mainFrame = TJ.frame[FB][bossIndex]

    -- 坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            if tbl[1] then
                TJ.SetEditTextFormNum(tbl[1], title, 1)
                TJ.SetEditTextFormNum(tbl[1], title, 2)
            end
            if tbl[2] then
                TJ.SetEditTextFormNum(tbl[2], title, 3)
            end
        end
        local text = L["安排坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["沙王"])
        TJ.CreateEdit(FB, bossIndex, L["霜王"])
        TJ.CreateEdit(FB, bossIndex, L["暗王"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 换嘲
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 136903 },
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
                notShowCount = true,
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_reincarnation", L["换嘲"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 附身
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 136442 },
                        },
                    },
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "achievement_moguraid_03", L["附身"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 暗影之魂
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 137650, },
                        },
                    },
                    destNpcType = { "Player" },
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warlock_soulsiphon", L["暗影之魂"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 霜寒刺骨
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 136922, 136990 },
                        },
                    },
                    destNpcType = { "Player" },
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_mage_frostbomb", L["霜寒刺骨"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火小神灵
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    69480, 69491,
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_priest_divinestar", L["转火小神灵"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("") then
            return
        end
    end
end
