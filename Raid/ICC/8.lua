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
    local tbl = {
        { point = "TOPLEFT", xy = { 176, -321 } },
        { point = "TOPLEFT", xy = { 417, -318 } },
        { point = "TOPLEFT", xy = { 186, -402 } },
        { point = "TOPLEFT", xy = { 405, -400 } },
        { point = "TOPLEFT", xy = { 245, -455 } },
        { point = "TOPLEFT", xy = { 343, -456 } },
        { point = "TOPLEFT", xy = { 98, -269 } },
        { point = "TOPLEFT", xy = { 495, -270 } },
        { point = "TOPLEFT", xy = { 96, -363 } },
        { point = "TOPLEFT", xy = { 489, -371 } }, -- 10
        { point = "TOPLEFT", xy = { 125, -451 } },
        { point = "TOPLEFT", xy = { 470, -460 } },
        { point = "TOPLEFT", xy = { 192, -520 } },
        { point = "TOPLEFT", xy = { 389, -521 } },
        { point = "TOPLEFT", xy = { 295, -539 } },
        { point = "TOPLEFT", xy = { 238, -228 } }, -- 16
        { point = "TOPLEFT", xy = { 351, -227 } },
        { point = "TOPLEFT", xy = { 144, -188 } },
        { point = "TOPLEFT", xy = { 441, -182 } },
        { point = "TOPLEFT", xy = { 92, -126 } },
        { point = "TOPLEFT", xy = { 495, -111 } },
        { point = "TOPLEFT", xy = { 225, -124 } },
        { point = "TOPLEFT", xy = { 354, -120 } },
        { point = "TOPLEFT", xy = { 182, -48 } },
        { point = "TOPLEFT", xy = { 387, -37 } },
        [100] = { xy = { 292, -340 }, isNPC = "b" .. bossIndex },
    }
    local function AutoFuc()
        -- N
        do
            local tbl = TJ.SortRaidRosterInfo(TJ.healerClass, "healer", true)
            for i, v in ipairs(tbl) do
                if v.class == "PALADIN" then
                    TJ.SetMapIconPlayerFormNum(2, v)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                if v.class == "PALADIN" then
                    TJ.SetMapIconPlayerFormNum(5, v)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, { min = 1, max = 6 })
            end
        end
        -- 远程DPS
        do
            local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
            for i, v in ipairs(tbl) do
                if v.class == "HUNTER" then
                    TJ.SetMapIconPlayerFormNum(7, v)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                if v.class == "HUNTER" then
                    TJ.SetMapIconPlayerFormNum(8, v)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                if v.class == "HUNTER" then
                    TJ.SetMapIconPlayerFormNum(15, v)
                    tremove(tbl, i)
                    break
                end
            end
            local f = TJ.frame[FB][bossIndex].map.icons[8]
            if f:NoPlayer() then
                for i, v in ipairs(tbl) do
                    if v.class == "DRUID" then
                        TJ.SetMapIconPlayerFormNum(8, v)
                        tremove(tbl, i)
                        break
                    end
                end
            end
            local f = TJ.frame[FB][bossIndex].map.icons[15]
            if f:NoPlayer() then
                for i, v in ipairs(tbl) do
                    if v.class == "DRUID" then
                        TJ.SetMapIconPlayerFormNum(15, v)
                        tremove(tbl, i)
                        break
                    end
                end
            end

            local f = TJ.frame[FB][bossIndex].map.icons[1]
            if f:NoPlayer() then
                for i, v in ipairs(tbl) do
                    if v.class == "WARLOCK" then
                        TJ.SetMapIconPlayerFormNum(1, v)
                        tremove(tbl, i)
                        break
                    end
                end
            end
            for i, v in ipairs(tbl) do
                if v.class == "WARLOCK" then
                    TJ.SetMapIconPlayerFormNum(10, v)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                if v.class == "WARLOCK" then
                    TJ.SetMapIconPlayerFormNum(9, v)
                    tremove(tbl, i)
                    break
                end
            end

            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, { min = 1, max = 17 })
            end
        end
        -- 近战DPS
        do
            local tbl = TJ.SortRaidRosterInfo(nil, "dps1", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, { min = 16, max = 23 })
            end
        end
    end
    local text = {
        L["2/5奶骑，3/4/6其他治疗。"],
        L["7/8/15猎人/鸟德。"],
        L["剩余空缺的台下位置1-15安排其他远程DPS。"],
        L["如果还有远程未安排到位置，则安排在16/17。"],
        L["台上16-25安排近战（躲风）。"],
    }
    TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
        text)
    TJ.CreateMap(FB, bossIndex, tbl, 590, 650)

    -- 打球
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "HUNTER", "DRUID" }, "dps2", true)
            for i, v in ipairs(tbl) do
                if v.class == "HUNTER" then
                    TJ.SetEditTextFormNum(v, title, 1)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                if v.class == "HUNTER" then
                    TJ.SetEditTextFormNum(v, title, 2)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                if v.class == "HUNTER" then
                    TJ.SetEditTextFormNum(v, title, 3)
                    tremove(tbl, i)
                    break
                end
            end
            local edit = title.edits[2].edit
            if edit:GetText() == "" then
                for i, v in ipairs(tbl) do
                    if v.class == "DRUID" then
                        TJ.SetEditTextFormNum(v, title, 2)
                        tremove(tbl, i)
                        break
                    end
                end
            end
            local edit = title.edits[3].edit
            if edit:GetText() == "" then
                for i, v in ipairs(tbl) do
                    if v.class == "DRUID" then
                        TJ.SetEditTextFormNum(v, title, 3)
                        tremove(tbl, i)
                        break
                    end
                end
            end
        end
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            72052, -- 动力炸弹
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local text = L["安排猎人/鸟德在左上/右上/正下一共3个点位。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, 135887, L["打球"],
            text, nil, nil, info)
        TJ.CreateEdit(FB, bossIndex, "左上方" .. L["打球"])
        TJ.CreateEdit(FB, bossIndex, "右上方" .. L["打球"])
        TJ.CreateEdit(FB, bossIndex, "正下方" .. L["打球"])
        TJ.CreateEdit(FB, bossIndex, "台上" .. L["打球"])
        TJ.CreateEdit(FB, bossIndex, "正左方" .. L["打球"])
        TJ.CreateEdit(FB, bossIndex, "正右方" .. L["打球"])
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
    -- 震荡涡流误伤
    do
        local info = {
            damageFriend = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            72038, -- 震荡涡流
                        },
                        colorNum = 1
                    },
                },
            },
            title = { name = L["震荡涡流误伤"], icon = 72038 }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 136022, L["震荡涡流"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 炼狱火球
    do
        local info = {
            castSuccess = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            72040, -- 塑造强能烈焰
                        },
                        colorNum = 2,
                        frameLevel = 2,
                    },
                },
                destNpcType = { "Player" }
            },
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            71393, -- 烈焰（火球爆炸伤害）
                        },
                        colorNum = 1,
                        frameLevel = 1,
                    },
                },
                destNpcType = { "Player" },
                sourceNPCID = { 38451, },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 135824, L["炼狱火球"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 毛黑球
    do
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        38369,
                    },
                    phase = "aw",
                },
                canSend = "dps",
                title = { name = L["毛黑球(暗王强化期间)"], icon = 71943, }
            },
            {
                damageHarm = {
                    type = "s",
                    destNPCID = {
                        38369,
                    },
                    phase = "aw",
                    attack = true,
                },
                title = { name = L["毛黑球(暗王强化期间)"], icon = 71943, },
                showPhase = true,
            },
            isMany = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 252272, L["毛黑球"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 暗影牢笼
    do
        local info = {
            dps = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            72999,
                        },
                    },
                },
                destNpcType = { "Player", },
            },
            canSend = "dps",
            title = { name = L["暗影牢笼承伤"], icon = 72999 }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 236170, L["暗影牢笼"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    TJ.frame[FB][bossIndex].BOSS_SAY = function(msg, sender, _, _, _, _, _, _, _, _, _, GUID)
        local player = msg:match("飞快地冲向(.+)！")
        if player then
            local playerGUID = UnitGUID(player)
            if playerGUID then
                local bossGUID = GUID or ""
                for guid, v in pairs(TJ.GetNewCombatLog().guid) do
                    if not v.class and v.name == sender then
                        bossGUID = guid
                        break
                    end
                end
                TJ.GetNewEvent()["SPELL_CAST_SUCCESS"] =
                    TJ.GetNewEvent()["SPELL_CAST_SUCCESS"] or {}
                local tbl = {
                    TJ.GetDurTime(),
                    "SPELL_CAST_SUCCESS",
                    nil,
                    bossGUID,
                    sender,
                    nil,
                    nil,
                    playerGUID,
                    player,
                    nil,
                    nil,
                    72040,
                    L["塑造强能烈焰"],
                    4,
                }
                tbl.i = 1
                tinsert(TJ.GetNewEvent()["SPELL_CAST_SUCCESS"], tbl)
            end
        end
    end

    local start
    TJ.frame[FB][bossIndex].SPELL_AURA_APPLIED = function(...)
        local tbl = { ... }
        local destGUID = tbl[8]
        local spellID = tbl[12]
        local targetSpellID = 70981 -- 鲜血唤醒
        local targetNpcID = 37972   -- 暗王
        if spellID == targetSpellID then
            local npcType, _, _, _, _, npcID = strsplit("-", destGUID)
            if (npcType == "Creature" or npcType == "Vehicle") and tonumber(npcID) == targetNpcID then
                start = TJ.GetDurTime() + 1
            end
        end
    end
    TJ.frame[FB][bossIndex].SPELL_AURA_REMOVED = function(...)
        local tbl = { ... }
        local destGUID = tbl[8]
        local spellID = tbl[12]
        local targetSpellID = 70981 -- 鲜血唤醒
        local targetNpcID = 37972   -- 暗王
        if spellID == targetSpellID then
            local npcType, _, _, _, _, npcID = strsplit("-", destGUID)
            if (npcType == "Creature" or npcType == "Vehicle") and tonumber(npcID) == targetNpcID then
                if start then
                    tinsert(TJ.GetNewCombatLog().otherTime, {
                        startTime = start,
                        endTime = TJ.GetDurTime(),
                        name = "aw",
                        name2 = L["暗王强化"]
                    })
                    start = nil
                end
            end
        end
    end
    TJ.frame[FB][bossIndex].ENCOUNTER_START = function(...)
        start = nil
    end
    TJ.frame[FB][bossIndex].ENCOUNTER_END = function(...)
        if start then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                startTime = start,
                endTime = TJ.GetDurTime(),
                name = "aw",
                name2 = L["暗王强化"]
            })
            start = nil
        end
    end
end
