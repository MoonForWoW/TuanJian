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
local bossIndex = 12
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
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST", "SHAMAN",}, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排奶牧、奶萨。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "ability_creature_disease_03", L["驱散疾病"],
            text, { "PRIEST", "SHAMAN","PALADIN" }, nil, nil)
        TJ.CreateEdit(FB, bossIndex, L["驱散疾病"])
        TJ.CreateEdit(FB, bossIndex, L["驱散疾病"])
        TJ.CreateEdit(FB, bossIndex, L["驱散疾病"])
        TJ.CreateEdit(FB, bossIndex, L["驱散疾病"])
        TJ.CreateEdit(FB, bossIndex, L["驱散疾病"])
        TJ.CreateEdit(FB, bossIndex, L["驱散疾病"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 驱散
    do
        local info = {
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                55011,
                            },
                            colorNum = 1
                        }
                    },
                },
                title = { name = L["驱散衰老热疫"] },
                notShowDead = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_creature_disease_03", L["驱散"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)

        TJ.AddDispelInfo(55011, 3, FB, bossIndex)
    end

    -- 法术瓦解
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                29310,
                            },
                            colorNum = 1
                        },
                    },
                },
                notShowDead = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_painfulafflictions", L["法术瓦解"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 跳舞
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                29371
                            },
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["受到%s伤害"]:format(L["跳舞"]) },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_fire", L["跳舞"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("引导法术") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
            return
        end
        if msg:match("发动进攻") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P1",
            })
            return
        end
    end
end
