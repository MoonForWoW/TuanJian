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
local FB = "SWtitan"
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

    mainFrame.saveAura = {
        [45333] = true, -- 燃烧
        [45329] = true, -- 暗影新星
        [45347] = true, -- 暗影之触
        [45348] = true, -- 烈焰之触
    }

    -- 技能提醒
    local msg1 = L["你被点名燃烧，马上远离人群。"]
    local burnWarningFrame
    if TJ.canUseTips then
        local name = "tips1" .. FB .. bossIndex
        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
            L["自动密语提醒燃烧出人群"],
            L["当有人被点名燃烧时，自动密语该团员出人群。"],
            L["需要你是团长或助理，该功能才能生效。"],
            " ",
            L["密语内容如下："],
            msg1,
        }
        local f = ns.O.CreateCheckButton(name, AddTexture(135818) .. L["自动密语提醒燃烧出人群"] .. L["（需要团长/助理）"],
            mainFrame, 40, -150, ontext)
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", TJ.spChild.title, "TOPRIGHT", 0, 15)
        f:SetHitRectInsets(0, 0, 0, 0)

        local name = "tips2" .. FB .. bossIndex
        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
            L["燃烧滚出人群"],
            L["当燃烧点名是你时，全屏提醒你出人群。"],
        }
        local f = ns.O.CreateCheckButton(name, AddTexture(135818) .. L["燃烧滚出人群"],
            mainFrame, 40, -150, ontext)
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", TJ.spChild.title, "TOPRIGHT", 0, 45)
        f:SetHitRectInsets(0, 0, 0, 0)

        burnWarningFrame = CreateFrame("Frame", nil, UIParent)
        burnWarningFrame:SetAllPoints(UIParent)
        burnWarningFrame:SetFrameStrata("HIGH")
        burnWarningFrame:Hide()

        local text = burnWarningFrame:CreateFontString(nil, "OVERLAY")
        text:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
        text:SetFont(STANDARD_TEXT_FONT, 150, "THICKOUTLINE")
        text:SetTextColor(1, 0.1, 0.1)
        text:SetText(L["燃烧！快出人群！"])
        burnWarningFrame.text = text
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
            text, TJ.tankClass, nil, nil, nil, true)
        TJ.CreateEdit(FB, bossIndex, L["萨洛拉丝(暗)"])
        TJ.CreateEdit(FB, bossIndex, L["奥蕾塞丝(火)"])
    end

    -- 偷高热
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排法师偷高热。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_fire_playingwithfire", L["偷高热"],
            text, { "MAGE", }, nil, nil)
        TJ.CreateEdit(FB, bossIndex, L["偷高热"])
        TJ.CreateEdit(FB, bossIndex, L["偷高热"])
        TJ.CreateEdit(FB, bossIndex, L["偷高热"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 混乱重击
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            45256,
                        },
                        colorNum = 1,
                    },
                },
                -- destNpcType = { "Player" },
                showCount = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_mindsteal", L["混乱重击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 暗影新星
    do
        local info = {
            {
                trigger = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                45329,
                            },
                            colorNum = 1,
                            frameLevel = 1,
                            tooltipText = TJ.AddIconBySpellID(45329) .. L["暗影新星点名"],
                            tooltip = "trigger",
                        },
                    },
                    showCount = true,
                },
                title = L["点名"],
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_shadowfury", L["暗影新星"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 燃烧
    do
        local info = {
            {
                trigger = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                45342,
                            },
                            colorNum = 1,
                            frameLevel = 1,
                            tooltipText = TJ.AddIconBySpellID(45342) .. L["燃烧点名"],
                            tooltip = "trigger",
                        },
                    },
                    showCount = true,
                },
                title = L["点名"],
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                45342, -- 燃烧
                            },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_incinerate", L["燃烧"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 高热
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                45230, -- 高热
                            },
                            colorNum = 3,
                        },
                    },
                    showCount = true,
                    destNPCID = { 25166 }
                },
                title = { name = L["高热"] },
            },
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                45230,
                            },
                            colorNum = 1,
                        },
                    },
                },
                notShowDead = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_playingwithfire", L["偷高热"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 踩地板火
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                45235,
                            },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = { name = L["受到%s伤害（踩地板火）"]:format(L["光芒"]) },
            },
            {
                castSuccess = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                45235,    
                            },
                            colorNum = 1
                        },
                    },
                },
                title = { name = L["光芒的施法目标（查远程是否OT）"] },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_fire", L["踩地板火"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    TJ.AddDispelInfo(45230, 1, FB, bossIndex) -- 高热

    local tipName = "tips1" .. FB .. bossIndex
    local tipName2 = "tips2" .. FB .. bossIndex
    mainFrame.BOSS_SAY = function(msg)
        local player = msg:match("奥蕾塞丝向(.+)施放燃烧")
        if player and not TJ.SetCD(mainFrame, 2, 45342) then
            local playerGUID = UnitGUID(player)
            if playerGUID then
                local newEvent = TJ.GetNewEvent()
                if newEvent then
                    newEvent["TRIGGER"] = newEvent["TRIGGER"] or {}
                    local tbl = {
                        TJ.GetDurTime(),
                        "TRIGGER",
                        nil,
                        playerGUID,
                        nil,
                        nil,
                        nil,
                        '',
                        nil,
                        nil,
                        nil,
                        45342,
                    }
                    tbl.i = 1
                    tinsert(newEvent["TRIGGER"], tbl)
                end
            end
            if UnitInRaid(player) and TuanJian.options[tipName] == 1 and TJ.IsLeader() then
                for i = 1, 3 do
                    SendChatMessage(msg1, "WHISPER", nil, player)
                end
            end
            if player == TJ.myName and TuanJian.options[tipName2] == 1 and burnWarningFrame then
                burnWarningFrame:Show()
                After(2, function()
                    burnWarningFrame:Hide()
                end)
                PlaySoundFile(ns.Interface .. "Media\\sound\\other\\BoxingArenaSound.ogg", "Master")
            end
            return
        end
        local player = msg:match("萨洛拉丝向(.+)施放暗影新星")
        if player and not TJ.SetCD(mainFrame, 2, 45329) then
            local playerGUID = UnitGUID(player)
            if playerGUID then
                local newEvent = TJ.GetNewEvent()
                if newEvent then
                    newEvent["TRIGGER"] = newEvent["TRIGGER"] or {}
                    local tbl = {
                        TJ.GetDurTime(),
                        "TRIGGER",
                        nil,
                        playerGUID,
                        nil,
                        nil,
                        nil,
                        '',
                        nil,
                        nil,
                        nil,
                        45329,
                    }
                    tbl.i = 1
                    tinsert(newEvent["TRIGGER"], tbl)
                end
            end
            return
        end
    end
end
-- /run TJ.frame["SWtitan"][4].BOSS_SAY("奥蕾塞丝向"..UnitName("player").."施放燃烧")
