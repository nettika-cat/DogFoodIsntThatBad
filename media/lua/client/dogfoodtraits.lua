local function initMyTraits()
    local UnpickyEater = TraitFactory.addTrait("unpickyeater", getText("UI_trait_UnpickyEater"), -1, getText("UI_trait_UnpickyEater_description"), false, false)
end

local function onKeyPressed(key)
	if player:HasTrait("unpickyeater") then
        getPlayer():Say("Hello world")
    end
end

Events.OnGameBoot.Add(initMyTraits);
Events.OnKeyPressed.Add(onKeyPressed);
