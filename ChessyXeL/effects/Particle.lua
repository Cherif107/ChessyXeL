local Sprite = require 'ChessyXeL.display.Sprite'
local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Point = require 'ChessyXeL.math.Point'
local Color = require 'ChessyXeL.util.Color'
local Range = require 'ChessyXeL.util.Range'

---@class effects.Particle : display.Sprite
local Particle = Sprite.extend 'Particle'

Particle.isEmmitted = FieldStatus.PUBLIC('default', 'default', false)
Particle.lifespan = FieldStatus.PUBLIC('default', 'default', 0)
Particle.age = FieldStatus.PUBLIC('default', 'default', 0)
Particle.percent = FieldStatus.PUBLIC('default', 'default', 0)
Particle.autoUpdateHitbox = FieldStatus.PUBLIC('default', 'default', false)
Particle._delta = FieldStatus.PUBLIC('default', 'default', 0)

Particle.reduceLag = FieldStatus.PUBLIC('default', 'default', true)

Particle.velocityRange = FieldStatus.PUBLIC('default', 'default')
Particle.angularVelocityRange = FieldStatus.PUBLIC('default', 'default')
Particle.scaleRange = FieldStatus.PUBLIC('default', 'default')
Particle.alphaRange = FieldStatus.PUBLIC('default', 'default')
Particle.dragRange = FieldStatus.PUBLIC('default', 'default')
Particle.colorRange = FieldStatus.PUBLIC('default', 'default')
Particle.accelerationRange = FieldStatus.PUBLIC('default', 'default')
Particle.elasticityRange = FieldStatus.PUBLIC('default', 'default')

Particle.new = function ()
    local particle = Particle.create()
    particle.velocityRange = Range(Point.get(), Point.get())
    particle.angularVelocityRange = Range(0)
    particle.scaleRange = Range(Point.get(1, 1), Point.get(1, 1))
    particle.alphaRange = Range(1, 1)
    particle.colorRange = Range(Color.WHITE)
    particle.dragRange = Range(Point.get(), Point.get())
    particle.accelerationRange = Range(Point.get(), Point.get())
    particle.elasticityRange = Range(0)
    

    particle.update = function (elapsed)
        if particle.isEmmitted then
            if (particle.age < particle.lifespan) then
			    particle.age = particle.age + elapsed
            end

            particle._delta = elapsed / particle.lifespan
            particle.percent = particle.age / particle.lifespan

            if particle.velocityRange.active then
                particle.velocity.x = particle.velocity.x + (particle.velocityRange.stop.x - particle.velocityRange.start.x) * particle._delta
                particle.velocity.y = particle.velocity.y + (particle.velocityRange.stop.y - particle.velocityRange.start.y) * particle._delta
            end
        
            if particle.angularVelocityRange.active then
                particle.angularVelocity = particle.angularVelocity + (particle.angularVelocityRange.stop - particle.angularVelocityRange.start) * particle._delta
            end
        
            if particle.scaleRange.active then
                particle.scale.x = particle.scale.x + (particle.scaleRange.stop.x - particle.scaleRange.start.x) * particle._delta
                particle.scale.y = particle.scale.y + (particle.scaleRange.stop.y - particle.scaleRange.start.y) * particle._delta
                if particle.autoUpdateHitbox then
                    particle.updateHitbox()
                end
            end
        
            if particle.alphaRange.active then
                particle.alpha = particle.alpha + (particle.alphaRange.stop - particle.alphaRange.start) * particle._delta
            end
        
            if particle.colorRange.active then
                particle.color = Color.interpolate(particle.colorRange.start, particle.colorRange.stop, particle.percent)
            end
        
            if not particle.reduceLag then
                if particle.dragRange.active then
                    particle.drag.x = particle.drag.x + (particle.dragRange.stop.x - particle.dragRange.start.x) * particle._delta
                    particle.drag.y = particle.drag.y + (particle.dragRange.stop.y - particle.dragRange.start.y) * particle._delta
                end
            
                if particle.accelerationRange.active then
                    particle.acceleration.x = particle.acceleration.x + (particle.accelerationRange.stop.x - particle.accelerationRange.start.x) * particle._delta
                    particle.acceleration.y = particle.acceleration.y + (particle.accelerationRange.stop.y - particle.accelerationRange.start.y) * particle._delta
                end
            
                if particle.elasticityRange.active then
                    particle.elasticity = particle.elasticity + (particle.elasticityRange.stop - particle.elasticityRange.start) * particle._delta
                end
            end
        end
        if particle.age >= particle.lifespan and particle.lifespan ~= 0 then
            particle.kill()
            particle.active = false
        end
    end

    return particle
end

return Particle