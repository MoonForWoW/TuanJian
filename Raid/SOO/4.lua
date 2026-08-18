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
local bossIndex = 4
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

    -- 傲气冲天减伤链
    local bossSpellID = 144400
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
        }
        local function AutoFuc()
            TJ.Board_AutoAssignMitigation(#spellTbl, arrange)
        end

        local tbl = {
            {
                name = L["P1傲气冲天减伤链"],
                bossSpellID = bossSpellID,
                arrange = arrange,
                icon = 895888,
                id = 1,
                spell = spellTbl,
                event = "SPELL_CAST_SUCCESS",
                canUpdate = true,
                autoNextSpell = true,
                startIndex = 1,
                maxIndex = 6,
                bossTime = { 76.5, 76.5 },
            },
            AutoFuc = AutoFuc,
        }

        mainFrame.Board_test = function()
            TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
            local info = TJ.Board_info[bossSpellID]
            if info then
                info.updateFrame.t = info.bossTime[1] - 10
            end
        end

        mainFrame.Board_SPELL_CAST_START = function(info, ...)
            local spellID = select(12, ...)
            if spellID == 144832 then
                local boardInfo = info[bossSpellID]
                if boardInfo then
                    TJ.Board_HideBar(bossSpellID)
                    boardInfo.canUpdate = nil
                    boardInfo.index = boardInfo.maxIndex + 1
                    boardInfo.updateFrame.t = 0
                end
                tinsert(TJ.GetNewCombatLog().otherTime, {
                    time = TJ.GetDurTime(),
                    name = "P2",
                })
            end
        end

        TJ.CreateBoard(FB, bossIndex, tbl)
    end)

    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 181, -139 } },
            { point = "TOPLEFT", xy = { 137, -174 } },
            { point = "TOPLEFT", xy = { 66, -149 } },
            { point = "TOPLEFT", xy = { 51, -95 } },
            { point = "TOPLEFT", xy = { 110, -43 } },
            { point = "TOPLEFT", xy = { 167, -58 } },
            { point = "TOPLEFT", xy = { 421, -446 } },
            { point = "TOPLEFT", xy = { 462, -403 } },
            { point = "TOPLEFT", xy = { 545, -426 } },
            { point = "TOPLEFT", xy = { 559, -490 } },
            { point = "TOPLEFT", xy = { 501, -543 } },
            { point = "TOPLEFT", xy = { 441, -523 } },
            { point = "TOPLEFT", xy = { 149, -408 } },
            { point = "TOPLEFT", xy = { 185, -443 } },
            { point = "TOPLEFT", xy = { 165, -528 } },
            { point = "TOPLEFT", xy = { 103, -543 } },
            { point = "TOPLEFT", xy = { 45, -487 } },
            { point = "TOPLEFT", xy = { 63, -427 } },
            { point = "TOPLEFT", xy = { 416, -134 } },
            { point = "TOPLEFT", xy = { 457, -173 } },
            { point = "TOPLEFT", xy = { 539, -150 } },
            { point = "TOPLEFT", xy = { 549, -94 } },
            { point = "TOPLEFT", xy = { 489, -39 } },
            { point = "TOPLEFT", xy = { 431, -54 } },
            [100] = { xy = { 302, -287 }, isNPC = "b" .. bossIndex },
        }

        --[[

]]
        local xy = {
            { 115, -111 }, -- 星星
            { 480, -111 }, -- 大饼
            { 116, -469 }, -- 紫菱
            { 486, -470 }, -- 三角
            { 623, -177 },
            { 623, -128 },
            { 624, -75 },
            { 623, -23 },
        }
        for index = 1, 8 do
            local left = mod((index - 1) / 4, 1);
            local right = left + 0.25;
            local top = floor((index - 1) / 4) * 0.25;
            local bottom = top + 0.25;
            tbl[index + 80] = {
                xy = xy[index],
                isNPC = true,
                isNPC_help = true,
                isNPC_icon = [[Interface\TargetingFrame\UI-RaidTargetingIcons]],
                coord = { left, right, top, bottom },
                notMask = true,
            }
        end

        local function AutoFuc()
            local tbl = TJ.SortRaidRosterInfo(nil, "healer", true)
            for _, i in ipairs({ 6, 12, 18, 24 }) do
                for ii, v in ipairs(tbl) do
                    TJ.SetMapIconPlayerFormNum(i, v)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "tank", true)
            for _, i in ipairs({ 1, 7, }) do
                for ii, v in ipairs(tbl) do
                    TJ.SetMapIconPlayerFormNum(i, v)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "dps1", true)
            for _, i in ipairs({ 13, 19, 2, 8, 14, 20, 3, 9, 15, 21, }) do
                for ii, v in ipairs(tbl) do
                    TJ.SetMapIconPlayerFormNum(i, v)
                    tremove(tbl, ii)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
        end
        local text = L["每个方位尽量保持1治疗2近战3远程。"]


        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local width = 600
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 848 * 840, nil, nil, nil, "v2.2.5")
    end

    -- 转火傲慢具象
    do
        local function AutoFuc(title)
            local ranged = TJ.SortRaidRosterInfo(nil, "dps2", true)
            local slots = { 1, 6, 2, 7, 3, 8, 4, 9, 5, 10, }
            for i, v in ipairs(ranged) do
                if not slots[i] then break end
                TJ.SetEditTextFormNum(v, title, slots[i])
            end
        end
        local text = L["远程DPS平均分配到左右两侧。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, 627685, L["转火傲慢具象"],
            text, nil, nil, nil, nil,
            true)
        for i = 1, 5 do
            TJ.CreateEdit(FB, bossIndex, L["左侧"])
        end
        for i = 1, 5 do
            TJ.CreateEdit(FB, bossIndex, L["右侧"])
        end
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 全团傲气值
    do
        local prideEventID = 144400
        local prideTextureID = 895888
        local lastPride = {}
        local prideTicker
        local activeCombatLog

        local function StopPrideTicker()
            if prideTicker then
                prideTicker:Cancel()
                prideTicker = nil
            end
            activeCombatLog = nil
            wipe(lastPride)
        end

        local function SaveRaidPride()
            local combatLog = TJ.GetNewCombatLog()
            if not activeCombatLog or combatLog ~= activeCombatLog or not TJ.startTime then
                StopPrideTicker()
                return
            end

            local newEvent = TJ.GetNewEvent()
            if not newEvent then return end
            newEvent.TRIGGER = newEvent.TRIGGER or {}

            for i = 1, GetNumGroupMembers(1) do
                local unit = "raid" .. i
                local guid = UnitGUID(unit)
                local maxPower = UnitPowerMax(unit, ALTERNATE_POWER_INDEX)
                if guid and maxPower ~= 0 then
                    local pride = UnitPower(unit, ALTERNATE_POWER_INDEX)
                    if lastPride[guid] ~= pride then
                        lastPride[guid] = pride
                        local tbl = {
                            TJ.GetDurTime(),
                            "TRIGGER",
                            nil,
                            nil,
                            nil,
                            nil,
                            nil,
                            guid,
                            nil,
                            nil,
                            nil,
                            prideEventID,
                            nil,
                            nil,
                            pride,
                        }
                        tbl.i = 1
                        tinsert(newEvent.TRIGGER, tbl)
                    end
                end
            end
        end

        local info = {
            trigger = {
                type = "d",
                spell = {
                    {
                        spellID = { prideEventID },
                        colorNum = 1,
                        tooltipText = AddTexture(prideTextureID) .. L["傲气值"],
                    },
                },
            },
            notShowDead = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, prideTextureID, L["傲气值"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)

        mainFrame.ENCOUNTER_START = function()
            StopPrideTicker()
            activeCombatLog = TJ.GetNewCombatLog()
            prideTicker = C_Timer.NewTicker(1, SaveRaidPride)
        end

        mainFrame.ENCOUNTER_END = function()
            StopPrideTicker()
        end
    end

    -- 腐化囚笼
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 144574, 144684, 144683, 144636 },
                            colorNum = 1,
                        },
                    },
                    showCount = true,
                },
                notShowDead = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 'sha_ability_rogue_sturdyrecuperate', L["腐化囚笼"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 团减
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { bossSpellID, },
                            colorNum = 2,
                        },
                    },
                },
                title = { name = L["Boss施放%s"]:format(L["傲气冲天"]) }
            },
        }
        tinsert(info, TJ.combatInfoMore)

        local f = TJ.CreateTitle(FB, bossIndex, nil, 895888, L["傲气冲天"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 打断嘲弄冲击
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 144379, },
                        },
                    },
                },
                title = { name = L["漏打断嘲弄冲击"], color = { 1, 0, 0 } },
                notShowDead = true,
            },
            {
                interrupt = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 144379, },
                            colorNum = 1,
                        },
                    },
                },
                title = { name = L["成功打断嘲弄冲击"] },
                notShowDead = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 'sha_spell_fire_fireball02', L["打断具象"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火傲慢具象
    do
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = { 71946, },
                },
                showRaidMember = true,
                title = { name = L['转火傲慢具象'] }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 627685, L["转火具象"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
end
