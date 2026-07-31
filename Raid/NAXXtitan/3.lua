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
            local tbl = TJ.SortRaidRosterInfo({ "DRUID" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排奶德。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "ability_creature_poison_03", L["驱散死灵毒药"],
            text, { "DRUID", "SHAMAN", "PALADIN" }, nil, nil, nil,
            nil)
        TJ.CreateEdit(FB, bossIndex, L["驱散死灵毒药"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 死灵毒药
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                54121, 28776
                            },
                            colorNum = 1,
                        }
                    },
                    destNpcType = { "Player" },
                }
            },
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                54121, 28776,
                            },
                            colorNum = 1
                        }
                    },
                },
                title = { name = L["驱散死灵毒药"] },
                notShowDead = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_creature_poison_03", L["死灵毒药"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
        TJ.AddDispelInfo(28776, 4, FB, bossIndex)
        TJ.AddDispelInfo(54121, 4, FB, bossIndex)
    end

    -- 蛛网裹体
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            28622,
                        },
                        colorNum = 1,
                    }
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_web", L["蛛网裹体"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    16486,
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_web", L["转火蛛网"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("") then
            return
        end
    end
end
