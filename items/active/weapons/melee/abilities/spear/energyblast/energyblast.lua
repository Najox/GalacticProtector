require "/scripts/util.lua"
require "/items/active/weapons/weapon.lua"

EnergyBlast = WeaponAbility:new()

function EnergyBlast:init()
  self.cooldownTimer = self.cooldownTime
end

function EnergyBlast:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - dt)

  if self.weapon.currentAbility == nil and self.fireMode == "alt" and self.cooldownTimer == 0 and status.overConsumeResource("energy", self.energyUsage) then
    self:setState(self.windup)
  end
end

function EnergyBlast:windup()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()

  util.wait(self.stances.windup.duration)

  self:setState(self.fire)
end

function EnergyBlast:fire()
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()

  local position = vec2.add(mcontroller.position(), activeItem.handPosition(animator.partPoint("blade", "projectileSource")))
  --local position = vec2.add(mcontroller.position(), {self.projectileOffset[1] * mcontroller.facingDirection(), self.projectileOffset[2]})
  local params = {
    powerMultiplier = activeItem.ownerPowerMultiplier(),
    power = self:damageAmount()
  }
  
  world.spawnProjectile(self.projectileType, position, activeItem.ownerEntityId(), {mcontroller.facingDirection() * math.cos(self.weapon.aimAngle), math.sin(self.weapon.aimAngle)}, false, params)
  --world.spawnProjectile(self.projectileType, position, activeItem.ownerEntityId(), self:aimVector(), false, params)

  animator.playSound(self:slashSound())

  util.wait(self.stances.fire.duration)
  self.cooldownTimer = self.cooldownTime
end

function EnergyBlast:slashSound()
  return self.weapon.elementalType.."EnergyBlast"
end

function EnergyBlast:aimVector()
  return {mcontroller.facingDirection(), 0}
end

function EnergyBlast:damageAmount()
  return self.baseDamage * config.getParameter("damageLevelMultiplier")
end

function EnergyBlast:uninit()
end
