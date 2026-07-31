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
local FB = "TES"
local bossIndex = 1
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
            true)
        TJ.CreateEdit(FB, bossIndex, L["考兰"])
        TJ.CreateEdit(FB, bossIndex, L["睿盖尔"])
        TJ.CreateEdit(FB, bossIndex, L["阿萨尼"])
    end
    -- 吃层
    do
        local function AutoFuc(title)
            TJ.SetEditTextFormNum(title.list[4], title, 1)
            TJ.SetEditTextFormNum(title.list[3], title, 2)
            TJ.SetEditTextFormNum(title.list[2], title, 3)
        end
        local text = L["安排4队1吃，3队2吃，2队3吃。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "sha_ability_rogue_envelopingshadows", L["吃层"],
            text, TJ.tankClass, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["1吃"], nil, TJ.teamList)
        TJ.CreateEdit(FB, bossIndex, L["2吃"], nil, TJ.teamList)
        TJ.CreateEdit(FB, bossIndex, L["3吃"], nil, TJ.teamList)
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
                                117283,
                            },
                            colorNum = 1
                        }
                    },
                    sourceNpcType = { "Player" },
                },
                title = { name = L["驱散净化之水"], icon = 117283 },
                notShowDead = true,
            },
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                117436,
                            },
                            colorNum = 1
                        }
                    },
                    sourceNpcType = { "Player" },
                },
                title = { name = L["驱散闪电牢笼"], icon = 117436 },
                notShowDead = true,
            },
            isMany = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 538567, L["驱散"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 打断
    do
        local info = {
            interrupt = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            118312,
                        },
                        colorNum = 1
                    },
                },
                sourceNpcType = { "Player" }
            },
            notShowDead = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 237006, L["打断水箭"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 吃层
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                118191,
                            },
                            colorNum = 1
                        },
                    },
                },
                notShowDead = true,
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                118198,
                            },
                            colorNum = 1,
                        }
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = { name = L["受到%s伤害"]:format(L["10层炸团"]) },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "sha_ability_rogue_envelopingshadows", L["堕落精华层数"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转火小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    60885,
                },
            },
            showRaidMember = true,
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "sha_ability_rogue_envelopingshadows", L["转火小怪"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    local cd
    TJ.frame[FB][bossIndex].SPELL_AURA_APPLIED = function(...)
        if cd then return end
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == 117052 then -- 煞能腐蚀
            cd = true
            After(1, function()
                cd = nil
            end)
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
        end
    end
    TJ.frame[FB][bossIndex].SPELL_AURA_APPLIED_DOSE = function(...)
        if cd then return end
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == 117052 then -- 煞能腐蚀
            cd = true
            After(1, function()
                cd = nil
            end)
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P3",
            })
        end
    end
end
