require "/scripts/util.lua"

function init()
  self.noElement = config.getParameter("noElementImage", "/assetmissing.png")
  self.randElement = config.getParameter("randElementImage", "/assetmissing.png")
  self.elementalTypes = config.getParameter("elementalTypes", {"fire", "ice", "poison", "electric"})
  self.essenceCost = config.getParameter("essenceCost", 0)
end

function update(dt)
  --Check item
  local item = widget.itemSlotItem("itemSlot")
  local itemConfig = root.itemConfig(item)
  local itemCheck = false
  local itemElementalType = nil
  
  if item then
	if root.itemHasTag(itemConfig.config.itemName, "gprotector_moduleweapon") then
	  itemCheck = true
	end
	
	if itemConfig.parameters.elementalType or itemConfig.config.elementalType then
	  widget.setImage("itemElementImage", returnElementalImagePath(itemConfig.parameters.elementalType or itemConfig.config.elementalType))
	  itemElementalType = itemConfig.parameters.elementalType or itemConfig.config.elementalType
	else
	  widget.setImage("itemElementImage", self.noElement)
	  itemElementalType = nil
	end
  else
	widget.setImage("itemElementImage", self.noElement)
	itemElementalType = nil
  end
  
  --Check module
  local module = widget.itemSlotItem("itemSlot2")
  local moduleConfig = root.itemConfig(module)
  local moduleCheck = false
  local moduleElementalType = nil
  
  if module and self.essenceCost == 0 then
	if root.itemHasTag(moduleConfig.config.itemName, "gprotectorate_module") then
	  moduleCheck = true
	end
	
	if moduleConfig.parameters.elementalType or moduleConfig.config.elementalType then
	  widget.setImage("moduleElementImage", returnElementalImagePath(moduleConfig.parameters.elementalType or moduleConfig.config.elementalType))
	  moduleElementalType = moduleConfig.parameters.elementalType or moduleConfig.config.elementalType
	else
	  widget.setImage("moduleElementImage", self.noElement)
	  moduleElementalType = nil
	end
  elseif self.essenceCost > 0 then
	moduleCheck = true
	widget.setImage("moduleElementImage", self.randElement)
	widget.setText("essenceLabel", self.essenceCost)
  else
	widget.setImage("moduleElementImage", self.noElement)
	moduleElementalType = nil
  end
  
  --Enable or disable augment button
  local enableButton = false
  
  if itemCheck and moduleCheck then
    if self.essenceCost > 0 then
	  enableButton = true
	elseif itemElementalType and moduleElementalType then
	  if moduleElementalType ~= itemElementalType then
		enableButton = true
	  end
	end
  end
  
  widget.setButtonEnabled("btnAugment", enableButton)
end

function attemptAugment()
  local item = widget.itemSlotItem("itemSlot")
  local itemConfig = root.itemConfig(item)
  local itemCheck = false
  local itemElementalType = nil
  
  if item then
	if root.itemHasTag(itemConfig.config.itemName, "gprotector_moduleweapon") and (itemConfig.parameters.elementalType or itemConfig.config.elementalType) then
	  itemCheck = true
	  itemElementalType = itemConfig.parameters.elementalType or itemConfig.config.elementalType
	end
  end
  
  local module = widget.itemSlotItem("itemSlot2")
  local moduleConfig = root.itemConfig(module)
  local moduleCheck = false
  local moduleElementalType = nil
  
  if module and self.essenceCost == 0 then
	if root.itemHasTag(moduleConfig.config.itemName, "gprotectorate_module") and (moduleConfig.parameters.elementalType or moduleConfig.config.elementalType) then
	  moduleCheck = true
	  moduleElementalType = moduleConfig.parameters.elementalType or moduleConfig.config.elementalType
	end
  elseif self.essenceCost > 0 then
	if item then
	  local elementList = {}
	  for _, element in ipairs(self.elementalTypes) do
	    if (itemConfig.parameters.elementalType or "") ~= element then
		  table.insert(elementList, element)
		end
	  end
	  moduleCheck = true
      moduleElementalType = elementList[math.random(#elementList)]
	end
  end
  
  if itemCheck and moduleCheck and player.consumeCurrency("essence", self.essenceCost) then
	if moduleElementalType ~= itemElementalType then
	  createAugmentedItem(itemConfig, moduleElementalType)
	end
  end
end

function createAugmentedItem(itemConfig, moduleElementalType)
  if itemConfig and moduleElementalType and not widget.itemSlotItem("itemSlot3") then
	local newItem = root.createItem(itemConfig.config.itemName)
	
	local addedParameters = {}
	addedParameters.elementalType = moduleElementalType
	
	newItem.parameters = util.mergeTable(itemConfig.parameters or {}, addedParameters)
	
	widget.setItemSlotItem("itemSlot3", newItem)
    widget.setItemSlotItem("itemSlot", nil)
	widget.setItemSlotItem("itemSlot2", nil)
  end
end

function swapHeldItem1()
  swapHeldItem()
end
function swapHeldItem2()
  swapHeldItem(2)
end
function swapHeldItem3()
  swapHeldItem(3)
end

function swapHeldItem(index)
  local slot = "itemSlot" .. (index or "")
  if player.swapSlotItem() then
	widget.setItemSlotItem(slot, player.swapSlotItem())
    player.setSwapSlotItem(nil)
  elseif slot then
    player.setSwapSlotItem(widget.itemSlotItem(slot))
	widget.setItemSlotItem(slot, nil)
  end
end

function returnElementalImagePath(elementalType)
  if elementalType ~= "physical" then
    return "/interface/elements/"..elementalType..".png"
  end
  return self.noElement
end

closeBase = uninit or function() end
function uninit() closeBase()
  for i = 1, 3 do
    slot =  "itemSlot" .. (i > 1 and i or "")
    player.giveItem(widget.itemSlotItem(slot))
	widget.setItemSlotItem(slot, nil)
  end  
end