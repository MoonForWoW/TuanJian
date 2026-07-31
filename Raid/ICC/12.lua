local AddonName, ns = ...

local LibBG = ns.LibBG
local L = ns.L

local AddTexture = ns.AddTexture
local Round = ns.Round

local pt = print
local After = C_Timer.After
local BG = TJ

local realmID = GetRealmID()
local player = UnitName("player")


local T = {}
local FB = "ICC"
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
    -- 战术板
    local s1, s2, s3, s4, s5, s6, s7, s8
    local i1
    local spellTbl = {
        {
            title = L["第1"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第2"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第3"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第4"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第5"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第6"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
    }
    local spellTbl2 = {
        {
            title = L["第1"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第2"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第3"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第4"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第5"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第6"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第7"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第8"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第9"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第10"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第11"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第12"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
    }
    local spellTbl3 = {
        {
            title = L["第1"],
            class = nil,
            spell = TJ.Board_TJ2
        },
        {
            title = L["第2"],
            class = nil,
            spell = TJ.Board_TJ2
        },
        {
            title = L["第3"],
            class = nil,
            spell = TJ.Board_TJ2
        },
        {
            title = L["第4"],
            class = nil,
            spell = TJ.Board_TJ2
        },
        {
            title = L["第5"],
            class = nil,
            spell = TJ.Board_TJ2
        },
        {
            title = L["第6"],
            class = nil,
            spell = TJ.Board_TJ2
        },
        {
            title = L["第7"],
            class = nil,
            spell = TJ.Board_TJ2
        },
    }
    local spellTbl4 = {
        {
            title = L["第1"],
            class = nil,
            spell = TJ.Board_TJ2
        },
        {
            title = L["第2"],
            class = nil,
            spell = TJ.Board_TJ2
        },
        {
            title = L["第3"],
            class = nil,
            spell = TJ.Board_TJ2
        },
        {
            title = L["第4"],
            class = nil,
            spell = TJ.Board_TJ2
        },
        {
            title = L["第5"],
            class = nil,
            spell = TJ.Board_TJ2
        },
        {
            title = L["第6"],
            class = nil,
            spell = TJ.Board_TJ2
        },
    }
    local spellTbl5 = {
        {
            title = L["第1"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第2"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第3"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第4"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
    }
    local function AutoFuc()
        -- 寄生和进剑
        local done = {}
        local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
        for i, v in ipairs(tbl) do
            if not done[1] then
                TJ.SetBoardEditFormNum(v, 1, 1, s1)
                TJ.SetBoardEditFormNum(v, 2, 1, s2)
                TJ.SetBoardEditFormNum(v, 1, 1, s1, 2)
                TJ.SetBoardEditFormNum(v, 1, 2, s2, 2)
                TJ.SetBoardEditFormNum(v, 7, 1, s1, 2)
                TJ.SetBoardEditFormNum(v, 1, 1, s1, 5)
                TJ.SetBoardEditFormNum(v, 1, 2, s2, 5)
                TJ.SetBoardEditFormNum(v, 3, 1, s1, 5)
                TJ.SetBoardEditFormNum(v, 3, 2, s2, 5)
                done[1] = true
                done[2] = true
            elseif not done[3] then
                TJ.SetBoardEditFormNum(v, 3, 1, s1)
                TJ.SetBoardEditFormNum(v, 4, 1, s2)
                TJ.SetBoardEditFormNum(v, 3, 1, s1, 2)
                TJ.SetBoardEditFormNum(v, 4, 1, s2, 2)
                TJ.SetBoardEditFormNum(v, 9, 1, s1, 2)
                TJ.SetBoardEditFormNum(v, 10, 1, s2, 2)
                TJ.SetBoardEditFormNum(v, 2, 1, s1, 5)
                TJ.SetBoardEditFormNum(v, 2, 2, s2, 5)
                TJ.SetBoardEditFormNum(v, 4, 1, s1, 5)
                TJ.SetBoardEditFormNum(v, 4, 2, s2, 5)
                done[3] = true
                done[4] = true
            end
        end
        local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "dps", true)
        for i, v in ipairs(tbl) do
            local spell
            if TuanJian.talentInfo[v.name] == 4 then
                spell = s1
            else
                spell = s2
            end
            if not done[5] then
                TJ.SetBoardEditFormNum(v, 5, 1, spell)
                TJ.SetBoardEditFormNum(v, 5, 1, spell, 2)
                TJ.SetBoardEditFormNum(v, 11, 1, spell, 2)
                done[5] = true
            elseif not done[6] then
                TJ.SetBoardEditFormNum(v, 6, 1, spell)
                TJ.SetBoardEditFormNum(v, 6, 1, spell, 2)
                TJ.SetBoardEditFormNum(v, 12, 1, spell, 2)
                done[6] = true
            end
        end
        local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "tank", true)
        for i, v in ipairs(tbl) do
            TJ.SetBoardEditFormNum(v, 2, 1, s1, 2)
            TJ.SetBoardEditFormNum(v, 8, 1, s1, 2)
            break
        end
        -- 收割
        local tbl = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, "tank", true)
        local v = tbl[1]
        if v then
            TJ.SetBoardEditFormNum(v, 1, 1, s3, 3)
            TJ.SetBoardEditFormNum(v, 1, 2, s4, 3)
            TJ.SetBoardEditFormNum(v, 1, 3, i1, 3)
            TJ.SetBoardEditFormNum(v, 2, 1, s5, 3)
            TJ.SetBoardEditFormNum(v, 3, 1, s3, 3)
            TJ.SetBoardEditFormNum(v, 3, 2, s4, 3)
            TJ.SetBoardEditFormNum(v, 3, 3, i1, 3)
            TJ.SetBoardEditFormNum(v, 5, 1, s3, 3)
            TJ.SetBoardEditFormNum(v, 5, 2, s4, 3)
            TJ.SetBoardEditFormNum(v, 5, 3, i1, 3)
            TJ.SetBoardEditFormNum(v, 6, 1, s5, 3)
            TJ.SetBoardEditFormNum(v, 7, 1, s3, 3)
            TJ.SetBoardEditFormNum(v, 7, 2, s4, 3)
            TJ.SetBoardEditFormNum(v, 7, 3, i1, 3)

            TJ.SetBoardEditFormNum(v, 1, 1, s3, 4)
            TJ.SetBoardEditFormNum(v, 1, 2, s4, 4)
            TJ.SetBoardEditFormNum(v, 1, 3, i1, 4)
            TJ.SetBoardEditFormNum(v, 2, 1, s5, 4)
            TJ.SetBoardEditFormNum(v, 3, 1, s3, 4)
            TJ.SetBoardEditFormNum(v, 3, 2, s4, 4)
            TJ.SetBoardEditFormNum(v, 3, 3, i1, 4)
            TJ.SetBoardEditFormNum(v, 5, 1, s3, 4)
            TJ.SetBoardEditFormNum(v, 5, 2, s4, 4)
            TJ.SetBoardEditFormNum(v, 5, 3, i1, 4)
            TJ.SetBoardEditFormNum(v, 6, 1, s5, 4)
        end
        local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "tank", true)
        local v = tbl[1]
        if v then
            TJ.SetBoardEditFormNum(v, 1, 4, s6, 3)
            TJ.SetBoardEditFormNum(v, 5, 4, s6, 3)
            TJ.SetBoardEditFormNum(v, 3, 4, s6, 4)
        end
        local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "dps", true)
        local v = tbl[1]
        if v then
            TJ.SetBoardEditFormNum(v, 3, 4, s6, 3)
            TJ.SetBoardEditFormNum(v, 7, 4, s6, 3)
            TJ.SetBoardEditFormNum(v, 1, 4, s6, 4)
            TJ.SetBoardEditFormNum(v, 5, 4, s6, 4)
        end
        local v = tbl[2]
        if v then
            TJ.SetBoardEditFormNum(v, 4, 2, s6, 3)
            TJ.SetBoardEditFormNum(v, 4, 2, s6, 4)
        end
        local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
        for k, v in pairs(tbl) do
            if TuanJian.talentInfo[v.name] == 1 then
                TJ.SetBoardEditFormNum(v, 4, 1, s7, 3)
                TJ.SetBoardEditFormNum(v, 4, 1, s7, 4)
                break
            end
        end
    end
    local cd = 22.5
    local cd2 = 30.5
    local cd5 = 48.5 + 55 -- 内场+外场
    local tbl = {
        {
            name = L["P1寄生"],
            bossSpellID = 70541,
            arrange = 2,
            icon = 132291,
            id = 1,
            spell = spellTbl,
            sound = L["即将寄生"],
            event = "SPELL_CAST_START",
            canUpdate = true,
            autoNextSpell = true,
            startIndex = 1,
            maxIndex = 6,
            bossTime = { 7, cd, cd, 26, cd, cd, },
        },
        {
            name = L["P3寄生"],
            bossSpellID = 70541,
            arrange = 2,
            icon = 132291,
            id = 2,
            spell = spellTbl2,
            sound = L["即将寄生"],
            event = "SPELL_CAST_START",
            canUpdate = true,
            autoNextSpell = true,
            notSetInfo = true,
            startIndex = 1,
            maxIndex = 12,
            bossTime = { 14, cd, cd, cd, cd, cd, cd, cd, cd, cd, cd, cd, cd, cd, cd, },
        },
        {
            name = L["P3收割"],
            bossSpellID = 69409,
            arrange = 4,
            icon = 236279,
            id = 3,
            spell = spellTbl3,
            sound = L["即将收割"],
            event = "SPELL_CAST_SUCCESS",
            canUpdate = false,
            autoNextSpell = true,
            startIndex = 1,
            maxIndex = 7,
            bossTime = { 42.7, cd2, cd2, cd2, cd2, cd2, cd2, },
        },
        {
            name = L["P5收割"],
            bossSpellID = 69409,
            arrange = 4,
            icon = 236279,
            id = 4,
            spell = spellTbl4,
            sound = L["即将收割"],
            event = "SPELL_CAST_SUCCESS",
            canUpdate = false,
            autoNextSpell = false,
            notSetInfo = true,
            startIndex = 1,
            maxIndex = 6,
            bossTime = { 48.5 + 6, cd2, 48.5 + 6, cd2, 48.5 + 6, cd2, },
        },
        {
            name = L["P5进剑"],
            bossSpellID = 73654,
            arrange = 2,
            icon = 237532,
            id = 5,
            spell = spellTbl5,
            sound = L["即将进剑"],
            event = "SPELL_CAST_SUCCESS",
            canUpdate = false,
            autoNextSpell = true,
            startIndex = 1,
            maxIndex = 4,
            bossTime = { 13, cd5, cd5, cd5, },
        },
        AutoFuc = AutoFuc,
    }
    TJ.CreateBoard(FB, bossIndex, tbl)

    local function IsH25()
        local diff = GetRaidDifficultyID()
        if diff == 6 or diff == 194 then
            return true
        end
    end

    local P3, P5, H25
    local SG = 0
    TJ.frame[FB][bossIndex].Board_ENCOUNTER_START = function(info)
        P3 = nil
        P5 = nil
        SG = 0
        H25 = IsH25()
    end
    TJ.frame[FB][bossIndex].Board_SPELL_CAST_START = function(info, ...)
        local tbl = { ... }
        local spellID = tbl[12]
        local bossSpellID = 70541  -- 寄生
        local bossSpellID2 = 69409 -- 收割
        local bossSpellID3 = 73654 -- 进剑
        if spellID == 72262 then   -- 地震
            if P3 then
                P5 = true
            else
                P3 = true
            end
        end
        -- 寄生
        if info[bossSpellID] then
            if spellID == 68981 or spellID == 72259 then
                -- BOSS施放冷酷严冬时（转阶段），隐藏进度条
                TJ.Board_HideBar(bossSpellID)
                info[bossSpellID].canUpdate = false
                info[bossSpellID].updateFrame.t = 0
            elseif spellID == 72262 and not P5 then
                -- BOSS施放地震，开始P3寄生计时
                local board = TJ.frame[FB][bossIndex].board
                local child = board.child[2]
                info[bossSpellID].child = child
                info[bossSpellID].index = child.startIndex
                info[bossSpellID].maxIndex = child.maxIndex
                info[bossSpellID].canUpdate = child.canUpdate
                info[bossSpellID].autoNextSpell = child.autoNextSpell
                info[bossSpellID].event = child.event
                info[bossSpellID].late = child.late
                info[bossSpellID].bossTime = child.bossTime
                info[bossSpellID].updateFrame.t = 0
            end
        end
        -- 收割
        if info[bossSpellID2] then
            if spellID == 68981 or spellID == 72259 then
                -- BOSS施放冷酷严冬时（转阶段），隐藏进度条
                TJ.Board_HideBar(bossSpellID2)
                info[bossSpellID2].canUpdate = false
                info[bossSpellID2].updateFrame.t = 0
            elseif spellID == 72262 then
                -- BOSS施放地震，开始收割计时
                if P5 then
                    -- P5
                    local board = TJ.frame[FB][bossIndex].board
                    local child = board.child[4]
                    info[bossSpellID2].child = child
                    info[bossSpellID2].index = child.startIndex
                    info[bossSpellID2].maxIndex = child.maxIndex
                    info[bossSpellID2].canUpdate = child.canUpdate
                    info[bossSpellID2].autoNextSpell = child.autoNextSpell
                    info[bossSpellID2].event = child.event
                    info[bossSpellID2].late = child.late
                    info[bossSpellID2].bossTime = child.bossTime
                    info[bossSpellID2].updateFrame.t = 0
                else
                    -- P3
                    info[bossSpellID2].canUpdate = true
                    info[bossSpellID2].updateFrame.t = 0
                end
            end
        end
        -- 进剑
        if info[bossSpellID3] and spellID == 72262 and P5 then
            -- BOSS施放地震，开始进剑计时
            info[bossSpellID3].canUpdate = true
            info[bossSpellID3].updateFrame.t = 0
        end
        -- 霜之哀伤
        if spellID == 72350 then
            TJ.Board_HideAllBar()
        end
    end
    TJ.frame[FB][bossIndex].Board_SPELL_CAST_SUCCESS = function(info, ...)
        if not H25 then return end
        local tbl = { ... }
        local spellID = tbl[12]
        local bossSpellID2 = 69409 -- 收割
        if spellID == 73654 then   -- 进剑
            info[bossSpellID2].canUpdate = true
            info[bossSpellID2].updateFrame.t = 0
        elseif spellID == bossSpellID2 and P5 then
            SG = SG + 1
            if SG % 2 == 1 then
                -- 出剑后第一次收割
                TJ.Board_NextSpell(bossSpellID2)
            else
                -- 出剑后第二次收割
                TJ.Board_HideNextSpell(bossSpellID2)
            end
        end
    end

    -- 站位图
    TJ.Once("map", 250525, function()
        local index = 1
        while TuanJian[FB][bossIndex]["map"][index] do
            TuanJian[FB][bossIndex]["map"][index].point = nil
            index = index + 1
        end
    end)
    local function Sort(team)
        local team = TJ.Copy(team)
        local new = {}
        for i = 1, #team do
            for i, v in ipairs(team) do
                if v.class == "WARLOCK" then
                    tinsert(new, v)
                    tremove(team, i)
                end
            end
        end
        for i, v in ipairs(team) do
            tinsert(new, v)
        end
        return new
    end
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 279, -441 } },
            { point = "TOPLEFT", xy = { 275, -488 } },
            { point = "TOPLEFT", xy = { 328, -484 } },
            { point = "TOPLEFT", xy = { 379, -489 } },
            { point = "TOPLEFT", xy = { 373, -439 } },
            { point = "TOPLEFT", xy = { 431, -423 } },
            { point = "TOPLEFT", xy = { 463, -396 } },
            { point = "TOPLEFT", xy = { 456, -458 } },
            { point = "TOPLEFT", xy = { 489, -438 } },
            { point = "TOPLEFT", xy = { 502, -407 } },
            { point = "TOPLEFT", xy = { 230, -430 } },
            { point = "TOPLEFT", xy = { 194, -405 } },
            { point = "TOPLEFT", xy = { 208, -464 } },
            { point = "TOPLEFT", xy = { 173, -442 } },
            { point = "TOPLEFT", xy = { 154, -412 } },
            { point = "TOPLEFT", xy = { 499, -369 } },
            { point = "TOPLEFT", xy = { 149, -369 } },
            [100] = { xy = { 324, -238 }, isNPC = "b" .. bossIndex },
            [101] = { xy = { 328, -442 }, isNPC = true, isNPC_icon = "Interface\\Icons\\ability_warrior_endlessrage" },
        }
        local function AutoFuc()
            local mapIndex = ""
            local team = TJ.GetRaidPointByTeam(5)
            if team then
                for i, v in ipairs(Sort(team)) do
                    if TJ.Isdps2(v) or TJ.Ishealer(v) then
                        TJ.SetMapIconPlayer(v, { min = 1, max = 5 }, mapIndex)
                    end
                end
            end
            local team = TJ.GetRaidPointByTeam(3)
            if team then
                for i, v in ipairs(Sort(team)) do
                    if TJ.Isdps2(v) or TJ.Ishealer(v) then
                        TJ.SetMapIconPlayer(v, { min = 6, max = 10 }, mapIndex)
                    end
                end
            end
            local team = TJ.GetRaidPointByTeam(4)
            if team then
                for i, v in ipairs(team) do
                    if TJ.Isdps2(v) or TJ.Ishealer(v) then
                        TJ.SetMapIconPlayer(v, { min = 11, max = 15 }, mapIndex)
                    end
                end
            end
            local team = TJ.GetRaidPointByTeam(2)
            if team then
                for i, v in ipairs(team) do
                    if TJ.Isdps2(v) or TJ.Ishealer(v) then
                        TJ.SetMapIconPlayer(v, { min = 1, max = 17 }, mapIndex)
                    end
                end
            end
            local team = TJ.GetRaidPointByTeam(1)
            if team then
                for i, v in ipairs(team) do
                    if TJ.Isdps2(v) or TJ.Ishealer(v) then
                        TJ.SetMapIconPlayer(v, { min = 1, max = 17 }, mapIndex)
                    end
                end
            end
        end
        local text = {
            L["1-5：5队。"],
            L["6-10：3队。"],
            L["11-15：4队。"],
            L["16-17：1队/2队剩余的远程DPS。"],
        }
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["P2/P4站位"],
            text)
        local scale = 1.4
        local map = TJ.CreateMap(FB, bossIndex, tbl, 650, 540, nil, scale)
        local t = map:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 30, "OUTLINE")
        t:SetPoint("TOPLEFT", 20, -20)
        t:SetText(L["P2/P4站位"])
        t:SetScale(1 / scale)
    end

    -- 驱散死疽
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
                return
            end
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
                return
            end
        end
        local info = {
            dispel = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            70337, 70338,
                        },
                        colorNum = 1,
                        frameLevel = 2,
                    }
                },
            }
        }
        local text = L["优先安排奶萨，其次防骑。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, 132099, L["驱散死疽"],
            text, { "PALADIN", "PRIEST", "SHAMAN" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["驱散死疽"])
    end
    -- 宁神
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "dps", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            72143
                        },
                        colorNum = 2,
                        frameLevel = 1,
                    }
                },
            },
            dispel = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            72143,
                        },
                        colorNum = 1,
                        frameLevel = 2,
                    }
                },
            },
        }
        local text = L["安排猎人。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_drowsy", L["宁神"],
            text, { "HUNTER", }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["1宁神"])
        TJ.CreateEdit(FB, bossIndex, L["2宁神"])
    end
    -- 制裁瓦格里
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "dps", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = ns.sp["制裁"],
                            colorNum = 1,
                            frameLevel = 1,
                        },
                        {
                            spellID = ns.sp["神圣愤怒"],
                            colorNum = 2,
                            frameLevel = 2,
                        },
                        {
                            spellID = ns.sp["地狱火眩晕"],
                            colorNum = 4,
                            frameLevel = 3,
                        },
                    },
                    destNPCID = { 36609 },
                }
            },
            {
                castSuccess = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                74352,
                            },
                            colorNum = 1,
                            frameLevel = 1,
                        },
                    },
                    startTime = "P3",
                    endTime = "P4",
                    endTime2 = "duration",
                },
                title = { name = L["瓦格里抓人"], icon = 74352, }
            },
            isMany = true,
        }
        local text = L["优先安排惩戒骑，其次防骑/奶骑。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_holy_sealofmight", L["制裁瓦格里"],
            text, { "PALADIN" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["1号制裁"])
        TJ.CreateEdit(FB, bossIndex, L["2号制裁"])
        TJ.CreateEdit(FB, bossIndex, L["3号制裁"])
    end
    -- 招大军
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "dps", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local info = {
            castSuccess = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            70498,
                        },
                        colorNum = 2,
                        frameLevel = 1,
                    },
                    {
                        spellID = {
                            42650,
                        },
                        colorNum = 1,
                        frameLevel = 2,
                    },
                },
            },
        }
        local text = L["优先安排输出DK，其次DKT。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_deathknight_armyofthedead", L["招大军"],
            text, { "DEATHKNIGHT" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["1大军"])
        TJ.CreateEdit(FB, bossIndex, L["2大军"])
        TJ.CreateEdit(FB, bossIndex, L["3大军"])
        TJ.CreateEdit(FB, bossIndex, L["4大军"])
        TJ.CreateEdit(FB, bossIndex, L["5大军"])
        TJ.CreateEdit(FB, bossIndex, L["6大军"])
    end
    -- 撞灵魂
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "dps", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "dps", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            70503,
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local text = L["优先安排防骑/惩戒骑，其次暗牧。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, 237244, L["撞灵魂"],
            text, nil, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["1撞魂"])
        TJ.CreateEdit(FB, bossIndex, L["2撞魂"])
        TJ.CreateEdit(FB, bossIndex, L["3撞魂"])
        TJ.CreateEdit(FB, bossIndex, L["4撞魂"])
        TJ.CreateEdit(FB, bossIndex, L["5撞魂"])
        TJ.CreateEdit(FB, bossIndex, L["6撞魂"])
    end
    -- 灵魂石
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local function updateFuc(index)
            local count = 0
            for i, v in ipairs(TJ.raidRosterInfo) do
                if count >= 3 then break end
                if v.role ~= "MAINASSIST" and v.class == "WARLOCK" then
                    count = count + 1
                    local name = "|c" .. select(4, GetClassColor(v.class)) .. TJ.GetIconAndName(v) .. "|r"
                    TJ.CreateEdit(FB, bossIndex, name, index)
                end
            end
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = ns.sp["灵魂石"],
                    },
                },
            }
        }
        local text = L["绑定坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_soulgem", L["灵魂石"],
            text, nil, updateFuc, info)
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 寄生
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                70541,
                            },
                            colorNum = 2,
                            frameLevel = 1,
                        },
                    },
                }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                31821, -- 光掌
                            },
                            colorNum = 4
                        },
                        {
                            spellID = {
                                70940, -- 大牺牲
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                    onlyShowMe = { 70940, 31821, 64843, 48447, 48446, 26983, },
                },
                title = { name = L["神圣牺牲/光环掌握"], icon = "spell_holy_powerwordbarrier" }
            },
            isMany = true
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 132291, L["寄生"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 毛食尸鬼
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    37695,
                },
                sourceNpcType = { "Player" }
            },
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_raisedead", L["毛食尸鬼"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 震荡波
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            72149,
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 236312, L["震荡波"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 灵魂尖啸
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            69242,
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 236300, L["灵魂尖啸"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转火灵魂
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    36701,
                },
            },
            showRaidMember = true,
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warrior_endlessrage", L["转火灵魂"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 打冰球
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    36633,
                },
            },
            showRaidMember = true,
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_frost_frostshock", L["打冰球"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转火瓦格里
    do
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        36609,
                    },
                },
                showRaidMember = true,
                canSend = "dps",
                title = { name = L["转火瓦格里(全程)"], icon = 74352, }
            },
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        36609,
                    },
                    phase = "pickUpMan",
                },
                showRaidMember = true,
                canSend = "dps",
                title = { name = L["转火瓦格里(最后一轮)"], icon = 74352, }
            },
            isMany = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 132128, L["转火瓦格里"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 瓦格里抓人
    do
        local info = {
            {
                castSuccess = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                74352,
                            },
                            colorNum = 1,
                            frameLevel = 1,
                        },
                    },
                    startTime = "P3",
                    endTime = "P4",
                    endTime2 = "duration",
                    showCount = true,
                },
                title = { name = L["瓦格里抓人"], icon = 74352, },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = ns.sp["制裁"],
                            colorNum = 1,
                            frameLevel = 1,
                        },
                        {
                            spellID = ns.sp["神圣愤怒"],
                            colorNum = 2,
                            frameLevel = 2,
                        },
                        {
                            spellID = ns.sp["地狱火眩晕"],
                            colorNum = 4,
                            frameLevel = 3,
                        },
                    },
                    destNPCID = { 36609 },
                },
                title = { name = L["制裁瓦格里"], icon = 10308, }

            },
            isMany = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 132128, L["抓人"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 污染
    do
        local info = {
            castSuccess = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            72762,
                        },
                        colorNum = 2,
                        frameLevel = 2,
                        tooltip = "castSuccess+HLKwuran",
                    },
                },
            },
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            72754,
                        },
                        colorNum = 1,
                        frameLevel = 1,
                    },
                },
                destNpcType = { "Player" },
            },
            showTextLog = true,
            canSend = "HLKwuran",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 132291, L["污染"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 灵魂收割
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                69409
                            },
                            colorNum = 2,
                            frameLevel = 1,
                            tooltip = "aura+health",
                        },
                    },
                },
            },
            isMany = true,
        }
        for i, v in ipairs(TJ.combatInfoTank) do
            tinsert(info, v)
        end

        local f = TJ.CreateTitle(FB, bossIndex, nil, 236279, L["灵魂收割"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 进剑
    do
        -- local info = {
        --     aura = {
        --         type = "d",
        --         spell = {
        --             {
        --                 spellID = { 68980 },
        --                 colorNum = 1,
        --             },
        --             {
        --                 spellID = { 72546 },
        --                 colorNum = 2,
        --                 tooltip = "castAll+aura",
        --             },
        --         },
        --     },
        -- }
        -- local f = TJ.CreateTitle(FB, bossIndex, nil, 237532, L["进剑"],
        --     nil, nil, nil, info)
        -- TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 饱受折磨承伤
    do
        local info = {
            dps = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            72133,
                        },
                    },
                },
                destNpcType = { "Player", },
            },
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 236302, L["饱受折磨承伤"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    TJ.frame[FB][bossIndex].BOSS_SAY = function(msg)
        if msg:match(L["我会让你的血脉"]) then
            local isP2 = true
            for k, v in pairs(TJ.GetNewCombatLog().otherTime) do
                if v.name == "P2" then
                    isP2 = nil
                    break
                end
            end
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = isP2 and "P2" or "P4",
            })
        elseif msg:match(L["你周围的世界"]) then
            local isP3 = true
            for k, v in pairs(TJ.GetNewCombatLog().otherTime) do
                if v.name == "P3" then
                    isP3 = nil
                    break
                end
            end
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = isP3 and "P3" or "P5",
            })
        end
    end

    -- 以霜之哀伤的怒火为结束时间
    if TJ.GetNewCombatLog() and TJ.GetNewCombatLog().otherTime then
        TJ.GetNewCombatLog().otherTime.END = nil
    end
    TJ.frame[FB][bossIndex].SPELL_CAST_SUCCESS = function(...)
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == 72350 then -- 霜之哀伤的怒火
            TJ.ENCOUNTER_END(nil, nil, 856, nil, nil, nil, true)
        end
    end

    -- 污染
    TJ.frame[FB][bossIndex].SPELL_CAST_START = function(...)
        local tbl = { ... }
        local spellID = tbl[12]
        local targetSpellID = 72762 -- 污染
        local targetNpcID = 36597   -- 巫妖王
        if spellID == targetSpellID then
            After(1.85, function()
                local unitTbl = { "target", "focus" }
                for i in ipairs(C_NamePlate.GetNamePlates()) do
                    tinsert(unitTbl, "nameplate" .. i)
                end
                for _, unit in ipairs(unitTbl) do
                    local guid = UnitGUID(unit)
                    if guid then
                        local npcType, _, _, _, _, npcID = strsplit("-", guid)
                        if (npcType == "Creature" or npcType == "Vehicle") and tonumber(npcID) == targetNpcID then
                            local LKTargetGUID = UnitGUID(unit .. "target")
                            if LKTargetGUID then
                                After(0.5, function()
                                    local event = TJ.GetNewEvent()["SPELL_CAST_SUCCESS"]
                                    if event and TJ.startTime then
                                        local count = #event
                                        for i = count, max(count - 100, 1), -1 do
                                            local v = event[i]
                                            if v and v[12] == targetSpellID and math.abs((TJ.GetDurTime()) - v[1]) <= 5 then
                                                event[i][8] = LKTargetGUID
                                                return
                                            end
                                        end
                                    end
                                end)
                            end
                            return
                        end
                    end
                end
            end)
        end
    end

    -- 瓦格里抓人
    local needSavedTime = true
    local num = 0
    local cd = {}
    local f = CreateFrame("Frame")
    f:SetScript("OnEvent", function(self, event, unitTarget, showVehicleFrame, isControlSeat,
                                    vehicleUIIndicatorID, vehicleGUID, mayChooseExit, hasPitch)
        local npcID = TJ.GetNPCID(vehicleGUID)
        if npcID ~= 36609 then return end

        if needSavedTime then -- 记录每一波瓦格里抓人的时间
            needSavedTime = false
            After(40, function()
                needSavedTime = true
            end)
            num = num + 1
            local time = TJ.GetDurTime()
            TJ.GetNewCombatLog().otherTime["pickUpMan"] = {
                startTime = time,
                endTime = time + 45,
            }
        end
        local destGUID = UnitGUID(unitTarget)
        local destName = UnitName(unitTarget)
        if cd[destGUID] then return end
        cd[destGUID] = true
        After(40, function()
            cd[destGUID] = nil
        end)
        TJ.GetNewEvent()["SPELL_CAST_SUCCESS"] =
            TJ.GetNewEvent()["SPELL_CAST_SUCCESS"] or {}
        local tbl = {
            TJ.GetDurTime(),
            "SPELL_CAST_SUCCESS",
            nil,
            vehicleGUID,
            nil,
            nil,
            nil,
            destGUID,
            destName,
            nil,
            nil,
            74352,
        }
        tbl.spellName = L["瓦格里抓人"]
        tbl.i = 1
        tinsert(TJ.GetNewEvent()["SPELL_CAST_SUCCESS"], tbl)
    end)
    TJ.frame[FB][bossIndex].ENCOUNTER_START = function(...)
        f:RegisterEvent("UNIT_ENTERED_VEHICLE")
        wipe(cd)
        needSavedTime = true
        num = 0
    end
    TJ.frame[FB][bossIndex].ENCOUNTER_END = function(...)
        f:UnregisterEvent("UNIT_ENTERED_VEHICLE")
    end
end
