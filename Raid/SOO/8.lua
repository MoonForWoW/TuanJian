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
local bossIndex = 8
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

    -- 自动标记
    local name = "rt" .. FB .. bossIndex
    do
        mainFrame.autoRT = name
        local instanceID = TJ.FBinfo[FB].ID
        TJ.autoRaidTargetInfo[instanceID] = TJ.autoRaidTargetInfo[instanceID] or {}
        TJ.autoRaidTargetInfo[instanceID][71626] = { -- 库卡隆军旗
            [8] = true,
            [7] = true,
            [6] = true,
            [5] = true,
            np = true,
        }
        TJ.autoRaidTargetInfo[instanceID][71519] = { -- 库卡隆战争萨满
            [8] = true,
            [7] = true,
            [6] = true,
            [5] = true,
            np = true,
        }
        TJ.autoRaidTargetInfo[instanceID][71610] = { -- 治疗之潮图腾
            [8] = true,
            [7] = true,
            [6] = true,
            [5] = true,
            np = true,
        }

        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local icon = TJ.SetRaidTargetingTex(8, 7, 6, 5)
        local ontext = {}
        local f = ns.O.CreateCheckButton(name,
            format(L["战斗中把重点小怪标记为%s（需要团长/助理）"], icon),
            mainFrame, 40, -150, ontext)
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", TJ.spChild.title, "TOPRIGHT", 0, 15)
        f:SetHitRectInsets(0, 0, 0, 0)
    end

    -- 战歌减伤链
    local warSongSpellID = 143503
    local warSongName = L["战歌"]
    local executeSpellID = 143502
    local executeName = L["斩杀"]
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
        local executeSpellTbl = {}
        for i = 1, 11 do
            tinsert(executeSpellTbl, {
                title = L[format("%d/%d", i, i + 11)],
                class = nil,
                spell = TJ.Board_TJ2,
            })
        end
        local function AutoFuc()
            TJ.Board_AutoAssignPhysicalMitigation(#spellTbl, arrange)
            TJ.Board_AutoAssignSingleTargetMitigation(#executeSpellTbl, 2)
        end

        local tbl = {
            {
                name = L["%s减伤链"]:format(warSongName),
                bossSpellID = warSongSpellID,
                arrange = arrange,
                icon = C_Spell.GetSpellTexture(warSongSpellID),
                id = 1,
                spell = spellTbl,
                event = "SPELL_CAST_START",
                canUpdate = nil,
                autoNextSpell = nil,
                startIndex = 0,
                maxIndex = nil,
                bossTime = { 2 },
                autoHide = true,
                now = true,
            },
            {
                name = L["%s减伤链（H模式）"]:format(executeName),
                bossSpellID = executeSpellID,
                arrange = 2,
                icon = C_Spell.GetSpellTexture(executeSpellID),
                id = 2,
                spell = executeSpellTbl,
                event = "SPELL_CAST_SUCCESS",
                canUpdate = true,
                autoNextSpell = true,
                startIndex = 1,
                maxIndex = nil,
                bossTime = { 21, 17, },
                H = true,
                target = L["当前坦克"],
            },
            AutoFuc = AutoFuc,
        }

        mainFrame.Board_test = function()
            TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
            TJ.Board_SPELL_CAST_START(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, warSongSpellID)
        end

        mainFrame.Board_SPELL_CAST_START = function(info, ...)
            local spellID = select(12, ...)
            if spellID ~= warSongSpellID then return end
            local boardInfo = info[spellID]
            if not boardInfo then return end
            -- TJ.Board_HideBar(spellID)
            boardInfo.index = boardInfo.index + boardInfo.step
            boardInfo.updateFrame.t = 0
            boardInfo.canUpdate = true
        end
        --[=[
/run TJ.Board_ENCOUNTER_START("SOO",8,true) TJ.Board_SPELL_CAST_START(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,143503)
/run TJ.Board_SPELL_CAST_START(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,143503)
/run TJ.Board_ENCOUNTER_START("SOO",8,true) TJ.Board_SPELL_CAST_START(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,143502)
/run TJ.Board_SPELL_CAST_START(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,143502)
]=]
        TJ.CreateBoard(FB, bossIndex, tbl)
    end)

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 碎甲重击层数
    do
        local spellID = 143494
        local spellName = L["碎甲重击"]
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
        local f = TJ.CreateTitle(FB, bossIndex, nil, C_Spell.GetSpellTexture(spellID), L["碎甲重击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 打断强化治疗链
    do
        local spellID = 143473
        local casterNPCID = 71519
        local spellName = L["强化治疗链"]
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
                    sourceNPCID = { casterNPCID, },
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
                    destNPCID = { casterNPCID, },
                },
                title = { name = L["成功打断"] .. spellName, },
                notShowDead = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, C_Spell.GetSpellTexture(spellID), L["打断治疗链"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 驱散大地之盾
    do
        local spellID = 143475
        local spellName = L["大地之盾"]
        local info = {
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = { spellID, },
                            colorNum = 1,
                        },
                    },
                },
                title = { name = L["驱散"] .. spellName, },
            },
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 143431, },
                            colorNum = 1,
                        },
                    },
                },
                title = { name = L["驱散魔法打击"], icon = 143431 },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, C_Spell.GetSpellTexture(spellID), L["驱散"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 刺客印记和猎人印记点名
    do
        local assassinMarkID = 143480
        local hunterMarkID = 143882
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { assassinMarkID, },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player", },
                    showCount = true,
                },
                notShowDead = true,
                title = {
                    name = L["刺客印记点名"],
                    icon = assassinMarkID,
                },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { hunterMarkID, },
                            colorNum = 2,
                        },
                    },
                    destNpcType = { "Player", },
                    showCount = true,
                },
                notShowDead = true,
                title = {
                    name = L["猎人印记点名"],
                    icon = hunterMarkID,
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, C_Spell.GetSpellTexture(assassinMarkID), L["小怪点名"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火库卡隆军旗
    do
        local spellID = 143536
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = { 71626, },
                },
                showRaidMember = true,
                title = {
                    name = L["转火库卡隆军旗"],
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, C_Spell.GetSpellTexture(spellID), L["转火军旗"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火治疗之潮图腾
    do
        local spellID = 143474
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = { 71610, },
                },
                showRaidMember = true,
                title = {
                    name = L["转火治疗之潮图腾"],
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, C_Spell.GetSpellTexture(spellID), L["转火图腾"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火库卡隆战争萨满
    do
        local spellID = 143473
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = { 71519, },
                },
                showRaidMember = true,
                title = {
                    name = L["转火库卡隆战争萨满"],
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, C_Spell.GetSpellTexture(spellID), L["转火萨满"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

end
