LightingStrike = WeaponAbility:new()

function LightingStrike:init()
  self.cooldownTimer = self.cooldownTime
  
  self.active = true
end

function LightingStrike:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

  if fireMode == "alt"
      and not self.weapon.currentAbility
      and self.cooldownTimer == 0
      and not status.resourceLocked("energy") then

    if self.active then
      self:setState(self.windup)
    else
      self:setState(self.empower)
    end
  end
end

function LightingStrike:windup()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()

  util.wait(self.stances.windup.duration)

  self:setState(self.fire)
end

function LightingStrike:fire()
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()

  local position = vec2.add(mcontroller.position(), {self.projectileOffset[1] * mcontroller.facingDirection(), self.projectileOffset[2]})
  local params = {
    powerMultiplier = activeItem.ownerPowerMultiplier(),
    power = self:damageAmount()
  }
  world.spawnProjectile(self.projectileType, position, activeItem.ownerEntityId(), self:aimVector(), false, params)

  animator.playSound("slash")
  status.overConsumeResource("energy", self.energyUsage)
  

  util.wait(self.stances.fire.duration)

  self.cooldownTimer = self.cooldownTime
end

function LightingStrike:uninit()

end

function LightingStrike:aimVector()
  return {mcontroller.facingDirection(), 0}
end

function LightingStrike:damageAmount()
  return self.baseDamage * config.getParameter("damageLevelMultiplier")
end