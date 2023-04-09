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
    local gui = {}
    gui.itemSlot2 = {
      type = "image",
      file = "/interface/scripted/gprotectorate_augmenter/unavailble.png",
      position = {107, 105},
      zlevel = 5
 	}
	gui.essenceIcon = {
      type = "image",
      file = "/interface/inventory/essenceicon.png",
      position = {88, 114},
      zlevel = 5
    }
	gui.windowtitle = { title = " Ancient Augmenter" }
	gui.infoLabel = { value = "Use essence to augment Protector weapons" }
    interactOverrides.gui = gui
	interactOverrides.essenceCost = 2500
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
