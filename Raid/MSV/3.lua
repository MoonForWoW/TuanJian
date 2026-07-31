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
local FB = "MSV"
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
    -- 进内场
    do
        local function AutoFuc(title)
            TJ.SetEditTextFormNum(title.list[3], title, 1)
            TJ.SetEditTextFormNum(title.list[4], title, 2)
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 116161, },
                    },
                },
                destNpcType = { "Player" },
                showCount = true,
            }
        }
        local text = L["安排3队1进，4队2进。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "inv_enchant_voidsphere", L["进内场"],
            text, TJ.tankClass, nil, info, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["1进"], nil, TJ.teamList)
        TJ.CreateEdit(FB, bossIndex, L["2进"], nil, TJ.teamList)
        TJ.CreateEdit(FB, bossIndex, L["3进"], nil, TJ.teamList)
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 巫毒娃娃
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 116161, },
                        colorNum = 1,
                    },
                    {
                        spellID = { 122151, },
                        colorNum = 2,
                    },
                },
                destNpcType = { "Player" },
                showCount = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "trade_archaeology_troll_voodoodoll", L["巫毒娃娃/内场"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 坦克放逐
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 116278, },
                    },
                },
                destNpcType = { "Player" },
                showCount = true,
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_priest_voidshift", L["坦克放逐"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转火小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    60184, 60940, 60277
                },
            },
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_shadowbolt", L["转火小怪"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end


    TJ.frame[FB][bossIndex].SPELL_AURA_APPLIED = function(...)
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == 117752 then -- 狂暴
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = L["20%"],
            })
        end
    end
end
