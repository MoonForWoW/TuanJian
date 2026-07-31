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
local FB = "MSV"
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
    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 279, -414 } },
            { point = "TOPLEFT", xy = { 135, -355 } },
            { point = "TOPLEFT", xy = { 96, -241 } },
            { point = "TOPLEFT", xy = { 138, -136 } },
            { point = "TOPLEFT", xy = { 277, -74 } },
            { point = "TOPLEFT", xy = { 421, -138 } },
            { point = "TOPLEFT", xy = { 455, -240 } },
            { point = "TOPLEFT", xy = { 420, -360 } },

            [100] = { xy = { 278, -243 }, isNPC = "b" .. bossIndex },
        }
        local xy = {
            { 575, -376 }, -- 星星
            { 575, -324 }, -- 大饼
            { 575, -273 }, -- 紫菱
            { 575, -226 }, -- 三角
            { 575, -175 },
            { 575, -123 },
            { 575, -70 },
            { 575, -18 },
        }
        for index = 1, 8 do
            local left = mod((index - 1) / 4, 1);
            local right = left + 0.25;
            local top = floor((index - 1) / 4) * 0.25;
            local bottom = top + 0.25;
            tbl[index + 90] = {
                xy = xy[index],
                isNPC = true,
                isNPC_help = true,
                isNPC_icon = [[Interface\TargetingFrame\UI-RaidTargetingIcons]],
                coord = { left, right, top, bottom },
                notMask = true,
            }
        end

        local function AutoFuc()
            local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST", "SHAMAN", "DRUID" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
        end
        local text = L["安排远程DPS在1-8号位置，如果人员不够则安排治疗。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local map = TJ.CreateMap(FB, bossIndex, tbl, 550, 593)
        local t = map:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 30, "OUTLINE")
        t:SetPoint("TOPLEFT", 20, -20)
        t:SetText(L["弓王站位"])
    end

    -- 坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil,
            nil)
        TJ.CreateEdit(FB, bossIndex, L["主坦克"])
        TJ.CreateEdit(FB, bossIndex, L["副坦克"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 密封之盾
    do
        local info = {
            trigger = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            117961,
                        },
                        colorNum = 1,
                        frameLevel = 1,
                        tooltipText = TJ.AddIconBySpellID(117961) .. L["触发反击风暴"],
                        tooltip = "trigger+health",
                    },
                },
                getDestGUID = 60709,
                showCount = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 132360, L["密封之盾"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 侧援
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            117918,
                        },
                        colorNum = 1
                    },
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 236313, L["侧援"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 掠夺
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 118048, },
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 236272, L["掠夺"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 巧取豪夺
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 118163, },
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 132305, L["巧取豪夺"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 箭矢点名
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 118135, },
                            colorNum = 2,
                        },
                        {
                            spellID = ns.sp["保护"],
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                }
            },
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = ns.sp["保护"],
                        },
                    },
                },
                title = { name = L["给保护"], icon = 1022 }
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 132218, L["箭矢点名"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转火箭矢
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    60958,
                },
            },
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 132218, L["转火箭矢"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 黑暗之盾
    do
        local info = {
            trigger = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            117697,
                        },
                        colorNum = 1,
                        frameLevel = 1,
                        tooltipText = TJ.AddIconBySpellID(117697) .. L["触发黑暗"],
                        tooltip = "trigger+health",
                    },
                },
                getDestGUID = 60701,
                showCount = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 136190, L["黑暗之盾"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转火不灭之影
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    60731,
                },
            },
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 132291, L["转火不灭"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    local function GetBossGUID(Guid)
        if TJ.GetNewCombatLog().guid then
            for guid in pairs(TJ.GetNewCombatLog().guid) do
                if TJ.GetNPCID(guid) == Guid then
                    return guid
                end
            end
        end
    end

    TJ.frame[FB][bossIndex].BOSS_SAY = function(msg)
        local player = msg:match("(.+)引发了反击风暴。")
        if player then
            local playerGUID = UnitGUID(player)
            if playerGUID then
                TJ.GetNewEvent()["TRIGGER"] =
                    TJ.GetNewEvent()["TRIGGER"] or {}
                local tbl = {
                    TJ.GetDurTime(),
                    "TRIGGER",
                    nil,
                    playerGUID,
                    player,
                    nil,
                    nil,
                    GetBossGUID(60709),
                    nil,
                    nil,
                    nil,
                    117961,
                    L["密封之盾"],
                }
                tbl.i = 1
                tinsert(TJ.GetNewEvent()["TRIGGER"], tbl)
            end
            return
        end
        local player = msg:match("(.+)引发了黑暗。")
        if player then
            local playerGUID = UnitGUID(player)
            if playerGUID then
                TJ.GetNewEvent()["TRIGGER"] =
                    TJ.GetNewEvent()["TRIGGER"] or {}
                local tbl = {
                    TJ.GetDurTime(),
                    "TRIGGER",
                    nil,
                    playerGUID,
                    player,
                    nil,
                    nil,
                    GetBossGUID(60701),
                    nil,
                    nil,
                    nil,
                    117697,
                    L["黑暗之盾"],
                }
                tbl.i = 1
                tinsert(TJ.GetNewEvent()["TRIGGER"], tbl)
            end
            return
        end
        if msg:match("你很快就能看清自己的错误！") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = L["弓王"],
            })
            return
        end
        if msg:match("你很快就会明白，为什么我的臣民惧怕暗影！") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = L["暗王"],
            })
            return
        end
        if msg:match("你犯下了欺君之罪") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = L["疯王"],
            })
            return
        end
    end

    -- TJ.GetNewEvent()["TRIGGER"] =
    --     TJ.GetNewEvent()["TRIGGER"] or {}
    -- local tbl = {
    --     43.551,
    --     "TRIGGER",
    --     nil,
    --     "Player-4487-00ABFF3D",
    --     "风丨行",
    --     nil,
    --     nil,
    --     nil,
    --     nil,
    --     nil,
    --     nil,
    --     117697,
    --     L["黑暗之盾"],
    -- }
    -- tbl.i = 1
    -- tinsert(TJ.GetNewEvent()["TRIGGER"], tbl)
    -- tremove(TJ.GetNewEvent()["TRIGGER"],2)
    --[[
local FB = "MSV"
for i = 11, 15 do
    TuanJian[FB][i] = TuanJian[FB][5]
end
/dump  TuanJian["MSV"][11]
 ]]
end
