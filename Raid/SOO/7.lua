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
local bossIndex = 7
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

    -- 坠落灰烬减伤链
    local bossSpellID = 143973
    local fallingAshName = L["坠落灰烬"]
    local fallingAshTexture = C_Spell.GetSpellTexture(bossSpellID)
    TJ.AddBoard(mainFrame, function()
        local arrange = 6
        local spellTbl = {
            {
                title = L["1/7"],
                class = nil,
                spell = TJ.Board_TJ1,
            },
            {
                title = L["2/8"],
                class = nil,
                spell = TJ.Board_TJ1,
            },
            {
                title = L["3/9"],
                class = nil,
                spell = TJ.Board_TJ1,
            },
            {
                title = L["4/10"],
                class = nil,
                spell = TJ.Board_TJ1,
            },
            {
                title = L["5/11"],
                class = nil,
                spell = TJ.Board_TJ1,
            },
            {
                title = L["6/12"],
                class = nil,
                spell = TJ.Board_TJ1,
            },
        }
        local function AutoFuc()
            TJ.Board_AutoAssignMitigation(#spellTbl, arrange)
        end

        local tbl = {
            {
                name = L["%s减伤链"]:format(fallingAshName),
                bossSpellID = bossSpellID,
                arrange = arrange,
                icon = fallingAshTexture,
                id = 1,
                spell = spellTbl,
                event = "SPELL_CAST_SUCCESS",
                canUpdate = nil,
                autoNextSpell = nil,
                startIndex = 0,
                maxIndex = nil,
                bossTime = { 14, 14, 14, 14, 14, 14, },
                autoHide = true,
            },
            AutoFuc = AutoFuc,
        }

        mainFrame.Board_test = function()
            TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
            TJ.Board_SPELL_CAST_SUCCESS(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, bossSpellID)
        end

        mainFrame.Board_SPELL_CAST_SUCCESS = function(info, ...)
            local spellID = select(12, ...)
            if spellID ~= bossSpellID then return end
            local boardInfo = info[bossSpellID]
            if not boardInfo then return end
            boardInfo.index = boardInfo.index + boardInfo.step
            boardInfo.canUpdate = true
            boardInfo.updateFrame.t = 0
        end
        --[=[
/run TJ.Board_ENCOUNTER_START("SOO",7,true) TJ.Board_SPELL_CAST_SUCCESS(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,143973)
/run TJ.Board_SPELL_CAST_SUCCESS(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,143973)
]=]
        TJ.CreateBoard(FB, bossIndex, tbl)
    end)

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 坦克层数
    do
        local frostName = L["冰霜风暴打击"]
        local frostTexture = C_Spell.GetSpellTexture(144215)
        local rendName = L["撕裂"]
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 144215, },
                            colorNum = 2,
                        },
                    },
                    destNpcType = { "Player", },
                    showCount = true,
                },
                title = { name = L["%s层数"]:format(frostName), },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 144304, },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player", },
                    showCount = true,
                },
                title = { name = L["%s层数"]:format(rendName), },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, frostTexture, L["风暴打击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 污秽水流点名和承伤
    do
        local spellID = 144090
        local spellName = L["污秽水流"]
        local spellTexture = C_Spell.GetSpellTexture(spellID)
        local info = {
            {
                castSuccess = {
                    type = "d",
                    spell = {
                        {
                            spellID = { spellID, },
                            colorNum = 2,
                        },
                    },
                    showCount = true,
                },
                notShowDead = true,
                title = { name = L["%s点名"]:format(spellName), },
            },
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
                title = { name = L["%s承伤"]:format(spellName), },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, spellTexture, spellName,
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 钢铁囚笼点名（英雄难度）
    do
        local spellID = 144330
        local spellName = L["钢铁囚笼"]
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
                canSend = "count",
                title = { name = L["%s点名"]:format(spellName), },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, spellTexture, spellName,
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 坠落灰烬与团队减伤
    do
        local spellID = 143973
        local spellName = L["坠落灰烬"]
        local spellTexture = C_Spell.GetSpellTexture(spellID)
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { spellID, },
                            colorNum = 2,
                        },
                    },
                },
                title = { name = L["Boss施放%s"]:format(spellName), },
            },
        }
        tinsert(info, TJ.combatInfoMore)

        local f = TJ.CreateTitle(FB, bossIndex, nil, spellTexture, spellName,
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火污秽软泥怪
    do
        local spellTexture = C_Spell.GetSpellTexture(144064)
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = { 71825, },
                },
                showRaidMember = true,
                canSend = "dps",
                title = { name = L["转火污秽软泥怪"], },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, spellTexture, L["转火软泥怪"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
end
