function init()
  self.floatingObjectCycle = config.getParameter("floatingObjectCycle", 1.0) / (2 * math.pi)
  self.floatingObjectMaxTransform = config.getParameter("floatingObjectMaxTransform", 1.0)
  self.timer = 0
  
  self.crafted = config.getParameter("crafted", true)
  animator.setGlobalTag("crafted", self.crafted and "player" or "world")
  
  animator.resetTransformationGroup("floatingObject")

  object.setInteractive(true)
end

function onInteraction(args)
  local interactOverrides = {}
  if not self.crafted then
    interactOverrides.itemSlot2 = {
        type = "itemslot",
        position = {67, 105},
        dimensions = {1, 1},
        spacing = {0, 0},
        backingImage = "/interface/inventory/empty.png"
      }
    interactOverrides.unavailableSlotImage = {
        type = "image",
        file = "/interface/scripted/gprotectorate_augmenter/noelement.png",
        position = {107, 105},
        zlevel = 5
 	  }
  end
  local newData = sb.jsonMerge(root.assetJson(config.getParameter("interactData")), interactOverrides)

  return { "scriptPane", newData }
end
function update(dt)
  self.timer = self.timer + dt
  local offset = math.sin(self.timer / self.floatingObjectCycle) * self.floatingObjectMaxTransform
	
  animator.resetTransformationGroup("floatingObject")
  animator.translateTransformationGroup("floatingObject", {0, offset})
end
