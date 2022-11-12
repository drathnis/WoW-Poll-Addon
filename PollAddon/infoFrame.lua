local AceGUI = LibStub("AceGUI-3.0")
local rootInfoFrame = nil
local inputBoxFrame = nil
local inputBoxFrame2 = nil

local partyMembers = {}
local labelList = {}

function ShowInfoFrame()
    rootInfoFrame:Show()
end

function UpdateInfoFrame(partyInfo)

    if inputBoxFrame then
        inputBoxFrame:ReleaseChildren()
    else
        inputBoxFrame = AceGUI:Create("SimpleGroup")
        inputBoxFrame:SetFullWidth(true)
        inputBoxFrame:SetFullHeight(true)
        inputBoxFrame:SetLayout("flow")
       -- inputBoxFrame:SetColor(1,0,1,1)
    end


    local i = 0
    for index, value in pairs(partyInfo) do
        i = i + 1

        local testFrame = AceGUI:Create("PlayerInfo")
        testFrame:SetLayout("flow")
        testFrame:SetText(partyInfo[index].name)
    
        testFrame:SetAddonState(partyInfo[index].hasAddon)
        testFrame:SetVoted(partyInfo[index].hasVoted)
        inputBoxFrame:AddChild(testFrame)

    end

    rootInfoFrame:AddChild(inputBoxFrame)

end



function CreateInfoFrame(partyInfo)
    
    rootInfoFrame = AceGUI:Create("Frame")
    rootInfoFrame:SetTitle("Info Frame")
    rootInfoFrame:SetStatusText("Info")
    rootInfoFrame:SetWidth(400)
    rootInfoFrame:SetLayout("flow")
    rootInfoFrame:Hide()
    rootInfoFrame:SetPoint("RIGHT", -100, 0)

    UpdateInfoFrame(partyInfo)

end