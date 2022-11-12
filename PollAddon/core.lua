local PollAddon = LibStub("AceAddon-3.0"):NewAddon("PollAddon", "AceConsole-3.0", "AceEvent-3.0") --"AceGUI-3.0" "AceComm-3.0"
local AceGUI = LibStub("AceGUI-3.0")
local LibAceSerializer = LibStub:GetLibrary("AceSerializer-3.0")

--local AceComm = LibStub("AceComm-3.0")
local AceComm = LibStub("AceComm-3.0"):Embed(PollAddon)


--TODO
-- Current Question Check! (Test)
-- Post Results
-- Timer
-- Ask Guild
-- Group Suggest Polls 


local addonVersion = tostring(GetAddOnMetadata("PollAddon", "Version"))
local playerName = UnitName("player");
local appIsOpen = true
local PollRootFrame = nil

local inputBoxFrame = nil

local editBoxes = {}
local poleQuestions = {}
local MAX_QUESTIONS = 7

local prefix_PA = "PollAddonComms"

local PollResultsVotes = {}
local PollResultPercentage = {}


local playerInfoList = {}

local numVotes = 0

function PollAddon:registerVote(sender, option, id)

    if playerInfoList[sender].hasVoted == false then

        numVotes = numVotes + 1
        if  option and option < 9 then
            PollResultsVotes[option] = PollResultsVotes[option] + 1
        end
        print("VOTED : " .. playerInfoList[sender].name)
        playerInfoList[sender].hasVoted = true
        UpdateInfoFrame(playerInfoList)

        --calcResults()
        print("TODO calcResults")
        
    else
        print("already voted!")
    end



end

function PollAddon:OnCommReceived(prefix, message, distribution, sender)
    local s , decoded = LibAceSerializer:Deserialize(message)
    
   -- print("MSG from " .. tostring(sender) )
    
    print("TODO mainComs")
    
    if s then
        print("Received: " .. decoded[1])
        if decoded[1] == "Announce" then
            PollAddon:addPlayer(sender)
             playerInfoList[sender].hasAddon = true
             
             UpdateInfoFrame(playerInfoList)

        elseif decoded[1] == "QuestionPost" then
            --print(decoded[2][1])
            CreateVoteFrame(decoded[2], AceComm)

        elseif decoded[1] == "voteSend" then
            --print(sender .. " Has Voted " .. decoded[2])     
            PollAddon:registerVote(sender, decoded[2], decoded[3])

        -- elseif decoded[1] == "RequestAddonVersion" then

        --     if decoded[2] ~= addonVersion then
        --         print(sender .. " Addon not up to date " .. decoded[2])
        --     end

        end

    end
end

function PollAddon:GROUP_ROSTER_UPDATE(...)
    
    PollAddon:resetPartyInfo()
    PollAddon:sendComms("Announce")

end


function PollAddon:resetPartyInfo()

    local nameStr = nil
    playerInfoList = {}

    for i = 1, GetNumGroupMembers() do
        nameStr = GetRaidRosterInfo(i);
        PollAddon:addPlayer(nameStr)
    end


end

function PollAddon:OnInitialize()
    
    print("Poll Addon  Version #" .. addonVersion .." Welcomes " .. playerName)
    
    PollAddon:addPlayer(playerName)
    playerInfoList[playerName].hasAddon = true

    PollAddon:RegisterEvent("GROUP_ROSTER_UPDATE")
    PollAddon:RegisterEvent("CHAT_MSG_WHISPER")

    PollAddon:RegisterComm(prefix_PA)

    PollAddon:initFrames()


end


function PollAddon:CHAT_MSG_WHISPER(...)
    
    local arg_1 = {...}
    local sender = arg_1[6]
    local msg = arg_1[2]

    msg = msg:gsub('Q', '')
    msg = msg:gsub('q', '')
    local num = tonumber(msg)

    if  num and num < 9 then

        PollAddon:registerVote(sender, num, 0)
        PollAddon:calcResults()

    end

end

function PollAddon:resetVotes()
    
    numVotes = 0
    for key, value in pairs(playerInfoList) do
        value.hasVoted = false
    end
    UpdateInfoFrame(playerInfoList)
end

function PollAddon:addPlayer(name)
    local playerInfo = {name = "Name", hasAddon = false, hasVoted = false}

    if name == nil then
        return
    end

    if playerInfoList[name] then
      -- print(playerInfoList[name].name .. " already in list")
    else
       -- print(name .. " adding to list")
        playerInfo["name"] = name
        playerInfoList[name] = playerInfo --Erron here when somone joins 

    end

end



function PollAddon:postQuestions()

    for i = 1, MAX_QUESTIONS do
        poleQuestions[i]= nil
        PollResultsVotes[i]=0
        PollResultPercentage[i]=0
    end

    local index = 0

    local hasQuestions = false

    for i, box in ipairs(editBoxes) do
        local temp = box:GetText()
       -- print(temp)
        if temp ~= "" then
            print("temp")
            index = index + 1
            poleQuestions[index] = box:GetText()
            hasQuestions = true
        end
    end

    if hasQuestions then
        PollAddon:resetVotes()
        PollAddon:sendComms("QuestionPost")
        PollAddon:sendNoAddon()
        PollAddon:showResults()
        
    end



end

function PollAddon:sendNoAddon()
    
    local questionStr = ""

    for key, value in pairs(poleQuestions) do
        questionStr = questionStr .. " or Q" .. key.. ": " .. value .. " "
    end

    for index, value in pairs(playerInfoList) do
        --print(value.name .. " Has addon = " .. tostring(value.hasAddon))

        if  value.hasAddon == false then
            SendChatMessage("To Vote, reply with Q1 or Q2..." , "WHISPER", nil, value.name)
            SendChatMessage(questionStr , "WHISPER", nil, value.name)
        end

    end

end

function PollAddon:sendComms(msg)
    local data = {}
    local encoded = nil

    if msg == "Announce" then
        data[1] = "Announce"
        encoded = LibAceSerializer:Serialize(data)
        AceComm:SendCommMessage(prefix_PA, encoded, "RAID");
    
    elseif msg == "QuestionPost" then
        data[1] = "QuestionPost"
        data[2] = poleQuestions
        encoded = LibAceSerializer:Serialize(data)
        AceComm:SendCommMessage(prefix_PA, encoded, "RAID");

        PollAddon:sendNoAddon()
    end

end

function PollAddon:showResults()
    --print("TODO showResults")

    CreateResultsFrame(poleQuestions,GetNumGroupMembers())
    PollAddon:calcResults()


end

function PollAddon:calcResults()
    local numQs = table.getn(poleQuestions)
    
    local results = 0  --=  PollResultsVotes[2]
    --local numVotes = numVotes
    --local C = V/T * 100
    
    for i = 1, numQs do
        results =  PollResultsVotes[i]
        PollResultPercentage[i]= results/numVotes * 100
        local mils = tonumber(string.format("%.2f",  PollResultPercentage[i]))

        --print("Q" .. i .. " = " .. mils)
        SetResult(i, mils)
    end

    UpdateRemainingVotes(numVotes, GetNumGroupMembers())

end 

function PollAddon:groupInfoHandle()
   --print("TODO groupInfoHandle")
   ShowInfoFrame()
end


function PollAddon:RefreshGroup()
    
    print("Refresh Group")

    for i = 1, GetNumGroupMembers() do
        local nameStr = GetRaidRosterInfo(i);
        PollAddon:addPlayer(nameStr)
    end

    UpdateInfoFrame(playerInfoList)


end

function PollAddon:mainFrame()

    appIsOpen = true
    PollRootFrame = AceGUI:Create("Frame")
    PollRootFrame:SetTitle("Create Poll")
    PollRootFrame:SetStatusText("Poll Creator")
    PollRootFrame:SetWidth(500)
    PollRootFrame:SetLayout("flow")
    PollRootFrame:EnableResize(false)



    PollRootFrame:SetCallback("OnClose",function() 
        appIsOpen = false
    end)

    local drop = AceGUI:Create("Dropdown")
    drop.frame:SetPoint("CENTER", UIParent)
    drop.frame:SetWidth(120)
    drop:SetLabel("Number Of Poll Options")
    
    drop:SetList({ ["2"] = "2", ["3"] = "3", ["4"] = "4", ["5"] = "5", ["6"] = "6", ["7"] = "7"})
    
    drop:SetValue("2")
    
    drop:SetCallback("OnValueChanged", function (widget, event, value)
        PollAddon:createInputBoxes(value)
    end)


    PollRootFrame:AddChild(drop)


    local postButton = AceGUI:Create("Button")
    postButton:SetText("Post Questions")
    postButton:SetWidth(130)
    postButton:SetCallback("OnClick", PollAddon.postQuestions)
    PollRootFrame:AddChild(postButton)

    local resultsButton = AceGUI:Create("Button")
    resultsButton:SetText("Show Results")
    resultsButton:SetWidth(130)
    resultsButton:SetCallback("OnClick", PollAddon.showResults)
    PollRootFrame:AddChild(resultsButton)

    local groupInfoButton = AceGUI:Create("Button")
    groupInfoButton:SetText("Show Group Info")
    groupInfoButton:SetWidth(150)
    groupInfoButton:SetCallback("OnClick",  PollAddon.groupInfoHandle)
    PollRootFrame:AddChild(groupInfoButton)

    local testBtn = AceGUI:Create("Button")
    testBtn:SetText("Refresh Group")
    testBtn:SetWidth(150)
    testBtn:SetCallback("OnClick",  PollAddon.RefreshGroup)
    PollRootFrame:AddChild(testBtn)

    
    PollAddon:createInputBoxes(2)

    PollRootFrame:Hide()

end

function PollAddon:createInputBoxes(number)
    poleQuestions = {}
    if inputBoxFrame then
        inputBoxFrame:ReleaseChildren()
    else
        inputBoxFrame = AceGUI:Create("SimpleGroup")
        inputBoxFrame:SetFullWidth(true)
        inputBoxFrame:SetFullHeight(true)
        inputBoxFrame:SetLayout("List")
    end
    editBoxes = {}
    for i = 1, number do
        --print(i)
        local editbox = AceGUI:Create("MyEditBox")
        --JS
        editbox:SetWidth(460)
        --editbox:SetCallback("OnEnterPressed", function(widget, event, text) updateQuestions(i ,text) end)
        inputBoxFrame:AddChild(editbox)
        editBoxes[i] = editbox;
    end

    PollRootFrame:AddChild(inputBoxFrame)

end

function PollAddon:initFrames()

    PollAddon:mainFrame()
    PollRootFrame:Show()
    
    CreateInfoFrame(playerInfoList)
    ShowInfoFrame()

end


SLASH_PHRASE1 = "/pa";
--SLASH_PHRASE2 = "/pa2";
SlashCmdList["PHRASE"] = function(msg)
    
    if msg == "" then
        print("RUN APP! ")
        if appIsOpen == true then
            print("Poll Addon already open")
        else
            PollRootFrame:Show()
        end
    else
        if msg == "show" then
            --print("other! ".. msg)
            if table.getn(questions) > 0 then
                showResults()
            else
                print("No Questions yet")
            end
        end
    end
end
