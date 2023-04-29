local base_perform = ISEatFoodAction.perform

function ISEatFoodAction:perform()
    if getPlayer():getTraits():contains("NotAPickyEater") then
        self.item:setUnhappyChange(math.min(self.item:getUnhappyChange(), 0))
        self.item:setBoredomChange(math.min(self.item:getBoredomChange(), 0))
        print("NotAPickyEater trait active, removing negative effects from food") -- DEBUG
    end
    base_perform(self)
end

local base_tooltip_render = ISToolTipInv.render

function ISToolTipInv:render()
    local unhappyChange = self.item:getUnhappyChange()
    local boredomChange = self.item:getBoredomChange()
    if getPlayer():getTraits():contains("NotAPickyEater") then
        self.item:setUnhappyChange(math.min(unhappyChange, 0))
        self.item:setBoredomChange(math.min(boredomChange, 0))
    end
    base_tooltip_render(self)
    if getPlayer():getTraits():contains("NotAPickyEater") then
        self.item:setUnhappyChange(unhappyChange)
        self.item:setBoredomChange(boredomChange)
    end
end

local function initTraits()
    TraitFactory.addTrait(
        "NotAPickyEater",
        getText("UI_trait_NotAPickyEater"),
        -1,
        getText("UI_trait_NotAPickyEater_description"),
        false,
        false
    )
end

Events.OnGameBoot.Add(initTraits)
