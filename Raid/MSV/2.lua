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

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 特殊技能
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 116364 },
                            colorNum = 1,
                        },
                        {
                            spellID = { 117203 },
                            colorNum = 9,
                        },
                        {
                            spellID = { 116295 },
                            colorNum = 6,
                        },
                        {
                            spellID = { 116018, },
                            colorNum = 5,
                        },
                        {
                            spellID = { 116711 },
                            colorNum = 4,
                        },
                    },
                },
            },
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 115817 },
                            colorNum = 1,
                        },
                    },
                },
                title = { name = L["废灵壁垒"], icon = "spell_nature_wispsplode" }
            },
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 115911 },
                            colorNum = 1,
                        },
                    },
                },
                title = { name = L["反射罩"], icon = "spell_arcane_arcaneresilience" }
            },
        }
        tinsert(info, TJ.combatInfoMore)
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_earthquake", L["特殊技能"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 换嘲
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 131790, 131792, 131788, 116942, },
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
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_spear_03", L["换嘲"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    TJ.frame[FB][bossIndex].BOSS_SAY = function(msg)
        if msg:match("赐予我魔法的智慧") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = L["仗"],
            })
            return
        end
        if msg:match("用你的盾保护我") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = L["盾"],
            })
            return
        end
        if msg:match("赐予我大地的力量") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = L["拳"],
            })
            return
        end
        if msg:match("借我之手") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = L["矛"],
            })
            return
        end
    end
end
