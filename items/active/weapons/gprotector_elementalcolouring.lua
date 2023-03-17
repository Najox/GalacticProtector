gProt_baseInit = init or function() end
function init() gProt_baseInit()
  local elementalDirectives = root.assetJson("/items/active/weapons/gprotectorate_elementtodirective.config")
  animator.setGlobalTag("elementalDirectives", elementalDirectives[config.getParameter("elementalType", "physical")])
end