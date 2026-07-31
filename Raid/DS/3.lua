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
    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 打软泥
    do
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        55862, 55863, 55864, 55865, 55866, 55867,
                    },
                    phase = "P2-1",
                },
                canSend = "dps",
                title = { name = L["打软泥(第1轮)"], icon = "spell_yorsahj_bloodboil_green", }
            },
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        55862, 55863, 55864, 55865, 55866, 55867,
                    },
                    phase = "P2-2",
                },
                canSend = "dps",
                title = { name = L["打软泥(第2轮)"], icon = "spell_yorsahj_bloodboil_green", }
            },
            isMany = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_yorsahj_bloodboil_green", L["软泥1-2"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 打软泥
    do
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        55862, 55863, 55864, 55865, 55866, 55867,
                    },
                    phase = "P2-3",
                },
                canSend = "dps",
                title = { name = L["打软泥(第3轮)"], icon = "spell_yorsahj_bloodboil_green", }
            },
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        55862, 55863, 55864, 55865, 55866, 55867,
                    },
                    phase = "P2-4",
                },
                canSend = "dps",
                title = { name = L["打软泥(第4轮)"], icon = "spell_yorsahj_bloodboil_green", }
            },
            isMany = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_yorsahj_bloodboil_green", L["软泥3-4"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 打软泥
    do
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        55862, 55863, 55864, 55865, 55866, 55867,
                    },
                    phase = "P2-5",
                },
                canSend = "dps",
                title = { name = L["打软泥(第6轮)"], icon = "spell_yorsahj_bloodboil_green", }
            },
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        55862, 55863, 55864, 55865, 55866, 55867,
                    },
                    phase = "P2-6",
                },
                canSend = "dps",
                title = { name = L["打软泥(第7轮)"], icon = "spell_yorsahj_bloodboil_green", }
            },
            isMany = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_yorsahj_bloodboil_green", L["软泥5-6"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 打软泥
    do
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        55862, 55863, 55864, 55865, 55866, 55867,
                    },
                    phase = "P2-7",
                },
                canSend = "dps",
                title = { name = L["打软泥(第7轮)"], icon = "spell_yorsahj_bloodboil_green", }
            },
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        55862, 55863, 55864, 55865, 55866, 55867,
                    },
                    phase = "P2-8",
                },
                canSend = "dps",
                title = { name = L["打软泥(第8轮)"], icon = "spell_yorsahj_bloodboil_green", }
            },
            isMany = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_yorsahj_bloodboil_green", L["软泥7-8"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 打法力虚空
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    56231
                },
            },
            showRaidMember = true,
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_elemental_primal_mana", L["打法力虚空"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 深度腐蚀
    do
        local info = {
            damageFriend= {
                type = "s",
                spell = {
                    {
                        spellID = {
                            105173,
                        },
                        tooltip = "damageFriend+health_onlyHeal",
                        colorNum = 1,
                    },
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_skull", L["深度腐蚀"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    local count = 0
    TJ.frame[FB][bossIndex].ENCOUNTER_START = function(...)
        count = 0
    end
    TJ.frame[FB][bossIndex].BOSS_SAY = function(msg)
        if msg:match(L["见证我们"]) then
            local start = TJ.GetDurTime()
            count = count + 1
            tinsert(TJ.GetNewCombatLog().otherTime, {
                startTime = start,
                endTime = start + 50,
                name = "P2-" .. count,
            })
        end
    end
end
