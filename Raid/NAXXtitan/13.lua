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
local FB = "NAXXtitan"
local bossIndex = 13
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

    -- 技能提醒
    if TJ.canUseTips then
        local name = "tips1" .. FB .. bossIndex

        local count = 1

        local function Start(time)
            if count > 5 then
                count = 1
            end
            local text = mainFrame.all[2].edits[count].edit:GetText()
            if text ~= "" then
                SendChatMessage(L["%s现在吃孢子！！！"]:format(text), "RAID_WARNING")
            end

            count = count + 1
            if count > 5 then
                count = 1
            end
            local text = mainFrame.all[2].edits[count].edit:GetText()
            if text ~= "" then
                TJ.AddTimer(time - 3, function()
                    SendChatMessage(L["%s准备吃孢子！"]:format(text), "RAID_WARNING")
                end)
            end
        end
        mainFrame.ENCOUNTER_START = function(...)
            count = 1
            if TuanJian.options[name] == 1 and TJ.IsLeader() then
                local text = mainFrame.all[2].edits[count].edit:GetText()
                if text ~= "" then
                    local time = 10
                    TJ.AddTimer(time - 3, function()
                        SendChatMessage(L["%s准备吃孢子！"]:format(text), "RAID_WARNING")
                    end)
                end
            end
        end
        mainFrame.SPELL_CAST_SUCCESS = function(...)
            local tbl = { ... }
            local spellID = tbl[12]
            if spellID == 29234 and TuanJian.options[name] == 1 and TJ.IsLeader() then
                Start(15)
            end
        end

        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {}
        local f = ns.O.CreateCheckButton(name, AddTexture(136079) .. L["吃孢子团队提醒"] .. L["（需要团长/助理）"],
            mainFrame, 40, -150, ontext)
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", TJ.spChild.title, "TOPRIGHT", 0, 15)
        f:SetHitRectInsets(0, 0, 0, 0)
        f:SetScript("OnEnter", function(self)
            local ontext = {
                L["吃孢子团队提醒"],
                L["根据你安排的吃孢子顺序，每一轮孢子来临时，在RW频道提醒这轮到几队吃。"],
                L["需要你是团长或助理，该功能才生效。"],
                " ",
                L["顺序安排如下："],
            }
            local hasTeam
            for i = 1, 10 do
                local ii
                if i > 5 then
                    ii = i - 5
                else
                    ii = i
                end
                local text = mainFrame.all[2].edits[ii].edit:GetText()
                if text ~= "" then
                    hasTeam = true
                    tinsert(ontext, L["第%s轮：%s吃"]:format(i, text))
                end
            end
            if hasTeam then
                tinsert(ontext, L["以此类推一直循环..."])
            end
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            for i, text in ipairs(ontext) do
                if i == 1 then
                    GameTooltip:AddLine(text, 1, 1, 1, true)
                else
                    GameTooltip:AddLine(text, 1, 0.82, 0, true)
                end
            end
            if not hasTeam then
                GameTooltip:AddLine(L["你当前没有分配吃孢子顺序，该功能无法生效。"], 1, 0, 0, true)
            end
            GameTooltip:Show()
        end)
        --[[
/run TJ.frame["NAXXtitan"][13].ENCOUNTER_START()
/run TJ.frame["NAXXtitan"][13].SPELL_CAST_SUCCESS(nil,nil,nil,nil,nil,nil,nil,nil,"苍穹小号哈",nil,nil,29234)
 ]]
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

    -- 吃孢子
    do
        local function AutoFuc(title)
            TJ.SetEditTextFormNum(title.list[4], title, 1)
            TJ.SetEditTextFormNum(title.list[3], title, 2)
            TJ.SetEditTextFormNum(title.list[2], title, 3)
            TJ.SetEditTextFormNum(title.list[1], title, 4)
            TJ.SetEditTextFormNum(title.list[5], title, 5)
        end
        local text = L["安排4队1吃，3队2吃，2队3吃，1队4吃。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_regeneration_02", L["吃孢子"],
            text, TJ.tankClass, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["1吃"], nil, TJ.teamList)
        TJ.CreateEdit(FB, bossIndex, L["2吃"], nil, TJ.teamList)
        TJ.CreateEdit(FB, bossIndex, L["3吃"], nil, TJ.teamList)
        TJ.CreateEdit(FB, bossIndex, L["4吃"], nil, TJ.teamList)
        TJ.CreateEdit(FB, bossIndex, L["5吃"], nil, TJ.teamList)
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 孢子增益
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                29232,
                            },
                            colorNum = 1
                        },
                    },
                },
                notShowDead = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_regeneration_02", L["孢子增益"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("") then
            return
        end
    end
end
