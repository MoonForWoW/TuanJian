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
local bossIndex = 6
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

    -- 地震冲击减伤链
    local bossSpellID = 144485
    local firstRoundSpellID = 144483
    local shockPulseName = L["地震&地震冲击"]
    local shockPulseTexture = C_Spell.GetSpellTexture(bossSpellID)
    TJ.AddBoard(mainFrame, function()
        local arrange = 6
        local spellTbl = {
            {
                title = L["1/5"],
                class = nil,
                spell = TJ.Board_TJ1,
            },
            {
                title = L["2/6"],
                class = nil,
                spell = TJ.Board_TJ1,
            },
            {
                title = L["3/7"],
                class = nil,
                spell = TJ.Board_TJ1,
            },
            {
                title = L["4/8"],
                class = nil,
                spell = TJ.Board_TJ1,
            },
        }
        local function AutoFuc()
            TJ.Board_AutoAssignMitigation(#spellTbl, arrange)
        end

        local tbl = {
            {
                name = L["%s减伤链"]:format(shockPulseName),
                bossSpellID = bossSpellID,
                arrange = arrange,
                icon = shockPulseTexture,
                id = 1,
                spell = spellTbl,
                event = "SPELL_CAST_START",
                canUpdate = nil,
                autoNextSpell = nil,
                startIndex = 1,
                maxIndex = 8,
                bossTime = { 4, 16.5, 15, 15, 4, 16.5, 15, 15, },
                autoHide = nil,
            },
            AutoFuc = AutoFuc,
        }

        mainFrame.Board_test = function()
            TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
            TJ.Board_SPELL_CAST_START(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, firstRoundSpellID)
        end

        mainFrame.Board_SPELL_CAST_START = function(info, ...)
            local spellID = select(12, ...)
            if spellID == firstRoundSpellID then
                local boardInfo = info[bossSpellID]
                if not boardInfo or boardInfo.index > boardInfo.maxIndex then return end
                if TJ.startTime then
                    tinsert(TJ.GetNewCombatLog().otherTime, {
                        time = TJ.GetDurTime(),
                        name = "P2",
                    })
                end
                boardInfo.canUpdate = true
                boardInfo.updateFrame.t = 0
                After(4, function()
                    TJ.Board_NextSpell(bossSpellID)
                end)
            end
        end
        mainFrame.Board_SPELL_CAST_SUCCESS = function(info, ...)
            local spellID = select(12, ...)
            if spellID == bossSpellID then
                local boardInfo = info[bossSpellID]
                local index = boardInfo.index
                if index == 2 or index == 3 or index == 6 or index == 7 then
                    TJ.Board_NextSpell(bossSpellID)
                else
                    TJ.Board_HideBar(bossSpellID)
                    boardInfo.index = boardInfo.index + boardInfo.step
                end
            end
        end
--[=[ 
/run TJ.Board_ENCOUNTER_START("SOO",6,true) TJ.Board_SPELL_CAST_START(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,144483)
/run TJ.Board_SPELL_CAST_START(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,144483)
/run TJ.Board_SPELL_CAST_SUCCESS(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,144485)
 ]=]

        TJ.CreateBoard(FB, bossIndex, tbl)
    end)

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 燃甲叠层
    do
        local spellID = 144467
        local spellName = L["燃烧护甲"]
        local spellTexture = C_Spell.GetSpellTexture(spellID)
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
                title = { name = L["%s层数"]:format(spellName), },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, spellTexture, L["%s"]:format(spellName),
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 踩地雷
    do
        local spellID = 144791
        local info = {
            {
                beDamage = {
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
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 'inv_misc_bomb_02', L["踩地雷"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 迫击炮
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 144316, },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player", },
                    showCount = true,
                },
                canSend = "count",
                title = { name = L["受到%s伤害"]:format(L['迫击炮']), },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 'ability_vehicle_siegeenginecannon', L["迫击炮"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 切割激光
    do
        local targetSpellID = 146325
        local damageSpellID = 144918
        local spellName = L["切割激光"]
        local spellTexture = C_Spell.GetSpellTexture(targetSpellID)
        local damageSpellName = L["切割激光"]
        local info = {
            {
                aura = {
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
                title = { name = L["%s点名"]:format(spellName), },
            },
            {
                beDamage2 = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 144919, },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player", },
                },
                title = { name = L["触发%s"]:format(L["焦油爆炸"]), color = { 1, 0, 0 }, },
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = { damageSpellID, },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player", },
                    showCount = true,
                },
                canSend = "count",
                title = { name = L["受到%s伤害"]:format(damageSpellName), },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, spellTexture, L["切割激光"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 地震冲击
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { bossSpellID, firstRoundSpellID },
                            colorNum = 2,
                        },
                    },
                    showCount = true,
                },
                title = { name = L["Boss施放%s"]:format(L['地震冲击']), },
            },
        }
        tinsert(info, TJ.combatInfoMore)

        local f = TJ.CreateTitle(FB, bossIndex, nil, 'spell_nature_earthquake', L['地震冲击'],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
end
