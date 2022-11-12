local AceGUI = LibStub("AceGUI-3.0")
local rootResultsFrame = nil
local options = {}
local resultValues = {}
local resultSliders = {}

local countLable

local function setOptions(opts)
    local qLable
    local rSlider
    
    for index, value in ipairs(opts) do
        --print(value)
        qLable = AceGUI:Create("Label")
        qLable:SetText(value)
        qLable:SetFont("AceGUI30LabelFont", 50)
        qLable:SetFullWidth(true)
        rootResultsFrame:AddChild(qLable)
        
        rSlider = AceGUI:Create("MySlider")
        rSlider:SetDisabled(true)
        resultSliders[index] = rSlider
        rootResultsFrame:AddChild(rSlider)
        resultValues[index]=0
        
    end
end




function UpdateRemainingVotes(current, partSize)

    local countTxt = current .. " of " .. partSize .. " votes"
    countLable:SetText(countTxt)

end


function SetResult(index, value)
    resultSliders[index]:SetValue(value)
end


function CreateResultsFrame(opts, partSize)
    rootResultsFrame = AceGUI:Create("Frame")
    rootResultsFrame:SetTitle("Results")
    rootResultsFrame:SetStatusText("ResultsPage")
    rootResultsFrame:SetWidth(500)
    rootResultsFrame:SetLayout("flow")

    local countTxt = "0 of " .. partSize .. " votes"
    countLable = AceGUI:Create("Label")
    countLable:SetText(countTxt)
    countLable:SetFont("AceGUI30LabelFont", 50)
    countLable:SetFullWidth(true)
    rootResultsFrame:AddChild(countLable)


    _G["MyGlobalFrameName"] = rootResultsFrame.frame
    tinsert(UISpecialFrames, "MyGlobalFrameName")

    
    setOptions(opts)
    UpdateRemainingVotes(0, partSize)



end