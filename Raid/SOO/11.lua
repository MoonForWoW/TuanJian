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
local FB = "SOO"
local bossIndex = 11
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
    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 坦克吐息层数
    do
        local spellTbl = {
            { 143766, L["恐惧咆哮"] },
            { 143780, L["酸息术"] },
            { 143773, L["冰冻吐息"] },
            { 143767, L["灼热吐息"] },
        }
        local info = {}
        for _, v in ipairs(spellTbl) do
            local spellID, spellName = unpack(v)
            tinsert(info, {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { spellID, },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player", },
                    showCount = true,
                },
                title = {
                    name = L["%s层数"]:format(spellName),
                    icon = spellID,
                },
            })
        end
        local f = TJ.CreateTitle(FB, bossIndex, nil, C_Spell.GetSpellTexture(143766), L["坦克层数"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- BOSS增速和血性狂乱光环
    do
        local accelerationID = 143411
        local bloodFrenzyID = 143442
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { accelerationID, },
                            colorNum = 1,
                        },
                    },
                    destNPCID = { 71529, },
                    showCount = true,
                },
                title = {
                    name = L["增速层数"],
                    icon = accelerationID,
                },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { bloodFrenzyID, },
                            colorNum = 2,
                        },
                    },
                    destNPCID = { 71529, },
                },
                title = {
                    name = L["血性狂乱光环"],
                    icon = bloodFrenzyID,
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, C_Spell.GetSpellTexture(accelerationID), L["BOSS光环"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 被震耳尖啸打断
    do
        local spellID = 143343
        local spellName = L["震耳尖啸"]
        local info = {
            {
                interrupt = {
                    type = "d",
                    spell = {
                        {},
                    },
                    sourceNPCID = { 71529, },
                    showIcon = true,
                },
                title = {
                    name = L["被%s打断"]:format(spellName),
                    icon = spellID,
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, C_Spell.GetSpellTexture(spellID), spellName,
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 锁定点名
    do
        local spellID = 143445
        local spellName = L["锁定"]
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { spellID, },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player", },
                    showCount = true,
                },
                canSend = "count",
                title = {
                    name = L["%s点名"]:format(spellName),
                    icon = spellID,
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, C_Spell.GetSpellTexture(spellID), spellName,
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    
    -- 腐蚀之血点名和驱散
    do
        local spellID = 143791
        local spellName = L["腐蚀之血"]
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { spellID, },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player", },
                    showCount = true,
                },
                title = {
                    name = L["%s点名"]:format(spellName),
                    icon = spellID,
                },
            },
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = { spellID, },
                            colorNum = 2,
                        },
                    },
                    sourceNpcType = { "Player", },
                },
                title = {
                    name = L["驱散%s"]:format(spellName),
                    icon = spellID,
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, C_Spell.GetSpellTexture(spellID), spellName,
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 冰冻之血层数和被冻结
    do
        local icyBloodID = 143800
        local frozenSolidID = 143777
        local icyBloodName = L["冰冻之血"]
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { icyBloodID, },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player", },
                    showCount = true,
                },
                title = {
                    name = L["%s层数"]:format(icyBloodName),
                    icon = icyBloodID,
                },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { frozenSolidID, },
                            colorNum = 2,
                        },
                    },
                    destNpcType = { "Player", },
                    showCount = true,
                },
                canSend = "count",
                title = {
                    name = L["被冻结"],
                    icon = frozenSolidID,
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, C_Spell.GetSpellTexture(icyBloodID), icyBloodName,
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 燃烧之血点名和地面承伤
    do
        local targetSpellID = 143783
        local groundSpellID = 143784
        local spellName = L["燃烧之血"]
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = { targetSpellID, },
                            colorNum = 2,
                        },
                    },
                    destNpcType = { "Player", },
                    showCount = true,
                },
                canSend = "count",
                title = {
                    name = L["%s点名"]:format(spellName),
                    icon = targetSpellID,
                },
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = { groundSpellID, },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player", },
                    showCount = true,
                },
                canSend = "count",
                title = {
                    name = L["%s承伤"]:format(spellName),
                    icon = groundSpellID,
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, C_Spell.GetSpellTexture(targetSpellID), spellName,
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- P1/P2阶段时间轴
    do
        local phase
        local phaseStart

        local function FinishPhase(endTime)
            if not phase or phaseStart == nil then return end
            tinsert(TJ.GetNewCombatLog().otherTime, {
                startTime = phaseStart,
                endTime = endTime,
                name = phase,
                name2 = L[phase],
            })
        end

        local function SetPhase(newPhase)
            if phase == newPhase then return end
            local time = TJ.GetDurTime()
            FinishPhase(time)
            phase = newPhase
            phaseStart = time
        end

        mainFrame.ENCOUNTER_START = function()
            phase = "P1"
            phaseStart = 0
        end

        mainFrame.SPELL_AURA_APPLIED = function(...)
            local destGUID = select(8, ...)
            local spellID = select(12, ...)
            if spellID == 143440 and TJ.GetNPCID(destGUID) == 71529 then
                SetPhase("P2")
            end
        end

        mainFrame.SPELL_AURA_REMOVED = function(...)
            local destGUID = select(8, ...)
            local spellID = select(12, ...)
            if spellID == 143440 and TJ.GetNPCID(destGUID) == 71529 then
                SetPhase("P1")
            end
        end

        mainFrame.ENCOUNTER_END = function()
            FinishPhase(TJ.GetDurTime())
            phase = nil
            phaseStart = nil
        end
    end
end
