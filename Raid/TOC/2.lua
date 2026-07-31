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
local FB = "TOC"
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
    -- 主坦克
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
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["主坦克"],
            text, TJ.tankClass, nil, nil, nil, true)
        TJ.CreateEdit(FB, bossIndex, L["BOSS"])
        TJ.CreateEdit(FB, bossIndex, L["小怪"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 虚空之能
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                66228,
                            },
                            colorNum = 1,
                        }
                    },
                    -- destNpcType = { "Player" },
                }
            },
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                66228,
                            },
                            colorNum = 1
                        }
                    },
                    notStolen=true,
                },
                title = { name = L["驱散虚空之能"] },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_mage_netherwindpresence", L["虚空之能"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 军团烈焰
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            66197,
                        },
                        colorNum = 1,
                    }
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_felimmolation", L["军团烈焰"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 女王之吻
    if TJ.IsWLK_80 then
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            66334,
                        },
                        colorNum = 1,
                    }
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_soothingkiss", L["女王之吻"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    34813,
                    34815,
                    34825,
                    34826,
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_summoninfernal", L["转火小怪"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    local spellTbl = {
        [66258] = L["火山"],
        [66269] = L["传送门"],
    }
    mainFrame.SPELL_CAST_SUCCESS = function(...)
        local argTbl = { ... }
        local spellID = argTbl[12]
        if spellID and spellTbl[spellID] then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = spellTbl[spellID],
            })
        end
    end
end
