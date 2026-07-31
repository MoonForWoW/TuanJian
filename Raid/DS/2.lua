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
local FB = "DS"
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
    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 末日黑洞
    do
        local info = {
            {
                beDamage2 = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                103527,
                            },
                            colorNum = 1
                        },
                    },
                },
                title = { name = L["撞球"], icon = "inv_misc_volatileshadow", },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                106836,
                            },
                            colorNum = 1,
                        },
                    },
                },
                title = { name = L["增伤层数"], icon = "inv_misc_volatileshadow", }
            },
            isMany = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_misc_volatileshadow", L["末日黑洞"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 干扰之影
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                103434,
                            },
                            colorNum = 2,
                        },
                    },
                },
                dispel = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                103434,
                            },
                            colorNum = 1,
                            frameLevel = 3,
                        }
                    },
                },
                notShowDead=true,
                title = { name = L["干扰之影"], icon = "spell_shadow_shadowfury", },
            },
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                103434,
                            },
                            colorNum = 1,
                            frameLevel = 2,
                        }
                    },
                },
                title = { name = L["驱散干扰之影"], icon = "spell_shadow_shadowfury", },
                notShowDead = true,
            },
            isMany=true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_shadowfury", L["干扰之影"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 灵魂汲取
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            104322,
                        },
                        colorNum = 1
                    },
                },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_rogue_shadowstep", L["灵魂汲取"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    55418, 55417, 55416
                },
            },
            showRaidMember = true,
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_vehicle_oiljets", L["打小怪"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
end
