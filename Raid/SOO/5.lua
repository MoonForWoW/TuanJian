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
local bossIndex = 5
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

    -- P2辐射烈焰减伤链
    local bossSpellID = 147042
    local radiatingFlamesName = L["辐射烈焰"]
    local radiatingFlamesTexture = C_Spell.GetSpellTexture(bossSpellID)
    local isP2
    local lastPulseTime = 0
    TJ.AddBoard(mainFrame, function()
        local arrange = 6
        local spellTbl = {
            {
                title = L["第1"],
                class = nil,
                spell = TJ.Board_TJ1,
            },
            {
                title = L["第2"],
                class = nil,
                spell = TJ.Board_TJ1,
            },
            {
                title = L["第3"],
                class = nil,
                spell = TJ.Board_TJ1,
            },
            {
                title = L["第4"],
                class = nil,
                spell = TJ.Board_TJ1,
            },
        }
        local function AutoFuc()
            TJ.Board_AutoAssignMitigation(#spellTbl, arrange)
        end

        local tbl = {
            {
                name = L["辐射烈焰减伤链"],
                bossSpellID = bossSpellID,
                arrange = arrange,
                icon = radiatingFlamesTexture,
                id = 1,
                spell = spellTbl,
                event = "SPELL_AURA_APPLIED",
                canUpdate = nil,
                autoNextSpell = nil,
                startIndex = 1,
                maxIndex = 4,
                bossTime = { 39, 27, 27, 27, },
            },
            AutoFuc = AutoFuc,
        }

        mainFrame.Board_test = function()
            TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
            isP2 = nil
            lastPulseTime = 0
            mainFrame.UNIT_SPELLCAST_SUCCEEDED(nil, 50630)
            local info = TJ.Board_info[bossSpellID]
            if info then
                info.updateFrame.t = info.bossTime[1] - 10
            end
        end

        TJ.CreateBoard(FB, bossIndex, tbl)
    end)

    mainFrame.ENCOUNTER_START = function()
        isP2 = nil
        lastPulseTime = 0
    end

    mainFrame.UNIT_SPELLCAST_SUCCEEDED = function(_, spellID)
        if spellID == 50630 and not isP2 then
            isP2 = true
            local info = TJ.Board_info[bossSpellID]
            if info then
                info.index = info.startIndex
                info.canUpdate = true
                info.updateFrame.t = 0
            end
            if TJ.startTime then
                tinsert(TJ.GetNewCombatLog().otherTime, {
                    time = TJ.GetDurTime(),
                    name = "P2",
                })
            end
        end
    end

    mainFrame.Board_SPELL_AURA_APPLIED = function(info, ...)
        local spellID = select(12, ...)
        local now = GetTime()
        if spellID == bossSpellID and now - lastPulseTime > 2 then
            lastPulseTime = now
            local boardInfo = info[bossSpellID]
            if boardInfo and boardInfo.index <= boardInfo.maxIndex then
                TJ.Board_NextSpell(bossSpellID)
            end
        end
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 打断治疗链
    do
        local spellID = 146757
        local spellName = L["治疗链"]
        local spellTexture = C_Spell.GetSpellTexture(spellID)
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { spellID, },
                        },
                    },
                },
                title = { name = L["漏打断"] .. spellName, color = { 1, 0, 0 }, },
                notShowDead = true,
            },
            {
                interrupt = {
                    type = "s",
                    spell = {
                        {
                            spellID = { spellID, },
                            colorNum = 1,
                        },
                    },
                },
                title = { name = L["成功打断"] .. spellName, },
                notShowDead = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, spellTexture, L["打断"] .. spellName,
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火治疗之潮图腾
    do
        local spellTexture = C_Spell.GetSpellTexture(143477)
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = { 73094, },
                },
                showRaidMember = true,
                title = { name = L["转火治疗之潮图腾"], },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, spellTexture, L["转火图腾"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- P2辐射烈焰与团队减伤
    do
        local info = {
            {
                aura = {
                    type = "s",
                    spell = {
                        {
                            spellID = { bossSpellID, },
                            colorNum = 2,
                        },
                    },
                    showCount = true,
                },
                title = { name = L["Boss施放%s"]:format(radiatingFlamesName), },
            },
        }
        tinsert(info, TJ.combatInfoMore)

        local f = TJ.CreateTitle(FB, bossIndex, nil, radiatingFlamesTexture, radiatingFlamesName,
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
end
