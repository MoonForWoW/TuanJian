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
local bossIndex = 4
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
        TJ.CreateEdit(FB, bossIndex, L["副坦克"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 仇恨打击
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                59192,28308
                            },
                            colorNum = 1,
                        }
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = { name = L["受到%s伤害"]:format(L["仇恨打击"]) },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "trade_engineering", L["仇恨打击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 道标
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = ns.sp["道标"],
                    },
                },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_paladin_beaconoflight", L["道标"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("") then
            return
        end
    end
end
