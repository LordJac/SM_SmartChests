dofile( "$SURVIVAL_DATA/Scripts/game/survival_shapes.lua" )

ContainerUuids = {
	obj_container_gas,
	obj_container_battery,
	obj_container_water,
	obj_container_seed,
	obj_container_fertilizer,
	obj_container_ammo,
	obj_container_chest,
	obj_container_chemical,
	obj_craftbot_refinery,
}

PipeUuids = {
	obj_pneumatic_pipe_01,
	obj_pneumatic_pipe_02,
	obj_pneumatic_pipe_03,
	obj_pneumatic_pipe_04,
	obj_pneumatic_pipe_05,
	obj_pneumatic_pipe_bend
}
for _,v in ipairs( ContainerUuids ) do assert( v ) end
for _,v in ipairs( PipeUuids ) do assert( v ) end

PipeState = { off = 1, invalid = 2, connected = 3, valid = 4 }

local PipeTravelTime = math.max( PIPE_TRAVEL_TICK_TIME / 40.0, 0.025 )

function RecursePipedShapeGraph( parent, setMarkedShapes, fnOnVertex )
	setMarkedShapes[parent.shape:getId()] = true
	for _, pipedShape in ipairs( parent.shape:getPipedNeighbours() ) do
		if setMarkedShapes[pipedShape:getId()] == nil then

			-- Set up new vertex in graph
			local vertex = {
				shape = pipedShape,
				childs = {},
				distance = parent.distance + 1,
				shapesOnPath = shallowcopy( parent.shapesOnPath ),
			}
			table.insert( vertex.shapesOnPath, pipedShape )
			table.insert( parent.childs, vertex )

			-- Callback to allow for custom traversal behaviours
			local recurse = true
			if fnOnVertex then
				recurse = fnOnVertex( vertex, parent )
			end

			if recurse then
				RecursePipedShapeGraph( vertex, setMarkedShapes, fnOnVertex )
			end
		end
	end
end

function ConstructPipedShapeGraph( shape, fnOnVertex )
	local setMarkedShapes = {}
	local root = { childs = {}, shape = shape, shapesOnPath = {}, distance = 0 }
	RecursePipedShapeGraph( root, setMarkedShapes, fnOnVertex )
end

--matches item UUID to special container UUID
local ItemSpecialContainer = {}

ItemSpecialContainer[tostring(obj_consumable_gas)] = obj_container_gas
ItemSpecialContainer[tostring(obj_consumable_battery)] = obj_container_battery
ItemSpecialContainer[tostring(obj_consumable_chemical)] = obj_container_chemical
ItemSpecialContainer[tostring(obj_consumable_water)] = obj_container_water
ItemSpecialContainer[tostring(obj_plantables_potato)] = obj_container_ammo
ItemSpecialContainer[tostring(obj_consumable_fertilizer)] = obj_container_fertilizer

--lightest/darkest colours, only allows items in if they match what item is in the first position in container
local oneItemContainer = {
    "eeeeeeff", "f5f071ff", "cbf66fff", "68ff88ff", "7eededff", "4c6fe3ff", "ae79f0ff", "ee7bf0ff", "f06767ff", "eeaf5cff",
	"222222ff", "323000ff", "375000ff", "064023ff", "0a4444ff", "0a1d5aff", "35086cff", "520653ff", "560202ff", "472800ff"
}

--3rd row colours, only allows items in if they belong to group type
local catagoryContainer = {}
--metal blocks grey
catagoryContainer["4a4a4aff"] = {blk_metal1, blk_metal2, blk_metal3, blk_scrapmetal, blk_beam, blk_crossnet,
                                 blk_tryponet, blk_metalnet, blk_spaceshipmetal, blk_lights
                                }
--wood blocks green
catagoryContainer["0E8031ff"] = {blk_cardboard, blk_wood1, blk_wood2, blk_wood3, blk_scrapwood, blk_caution}
--stone blocks yellow
catagoryContainer["817C00ff"] = {blk_sand, blk_concrete1, blk_concrete2, blk_concrete3, blk_scrapstone,
                        blk_bricks, blk_glass, blk_armoredglass, blk_glasstile, blk_tiles
                    }
--other blocks lime
catagoryContainer["577D07ff"] = {blk_carpet, blk_plastic, blk_bubblewrap}
--pipes blue
catagoryContainer["4c6fe3ff"] = {small_2way_pipe, small_2wayb_pipe, small_3way_pipe, small_3wayb_pipe, small_4way_pipe, small_4wayb_pipe,
                        small_5way_pipe, small_6way_pipe, small_long_pipe, obj_fittings_pipe, obj_fittings_pipebend, 
                        obj_fittings_pipesplit, obj_fittings_pipelong, obj_fittings_pipevalve
                    }
--vehicle parts red
catagoryContainer["7C0000ff"] = {obj_interactive_driversaddle_01, obj_interactive_driversaddle_02, obj_interactive_driversaddle_03, obj_interactive_driversaddle_04, obj_interactive_driversaddle_05,
                        obj_interactive_driverseat_01, obj_interactive_driverseat_02, obj_interactive_driverseat_03, obj_interactive_driverseat_04, obj_interactive_driverseat_05,
                        obj_interactive_seat_01, obj_interactive_seat_02, obj_interactive_seat_03, obj_interactive_seat_04, obj_interactive_seat_05,
                        obj_interactive_saddle_01, obj_interactive_saddle_02, obj_interactive_saddle_03, obj_interactive_saddle_04, obj_interactive_saddle_05,
                        obj_interactive_gasengine_01, obj_interactive_gasengine_02, obj_interactive_gasengine_03, obj_interactive_gasengine_04, obj_interactive_gasengine_05, 
                        obj_interactive_electricengine_01, obj_interactive_electricengine_02, obj_interactive_electricengine_03, obj_interactive_electricengine_04, obj_interactive_electricengine_05, 
                        obj_interactive_thruster_01, obj_interactive_thruster_02, obj_interactive_thruster_03, obj_interactive_thruster_04, obj_interactive_thruster_05, 
                        jnt_suspensionoffroad_01, jnt_suspensionoffroad_02, jnt_suspensionoffroad_03, jnt_suspensionoffroad_04, jnt_suspensionoffroad_05, 
                        jnt_suspensionsport_01, jnt_suspensionsport_02, jnt_suspensionsport_03, jnt_suspensionsport_04, jnt_suspensionsport_05, 
                        jnt_interactive_piston_01, jnt_interactive_piston_02, jnt_interactive_piston_03, jnt_interactive_piston_04, jnt_interactive_piston_05, 
                        obj_interactive_mountablespudgun, jnt_bearing, 
                    }
--logic parts orange
catagoryContainer["673B00ff"] = {obj_interactive_controller_01, obj_interactive_controller_02, obj_interactive_controller_03, obj_interactive_controller_04, obj_interactive_controller_05, 
                        jnt_interactive_piston_01, jnt_interactive_piston_02, jnt_interactive_piston_03, jnt_interactive_piston_04, jnt_interactive_piston_05,
                        obj_interactive_sensor_01,  obj_interactive_sensor_02, obj_interactive_sensor_03, obj_interactive_sensor_04, obj_interactive_sensor_05,
                        obj_interactive_switch, obj_interactive_button, obj_interactive_logicgate, obj_interactive_timer
                    }

--
local function evaluateChestPriority(container, itemUid)
	--if container is the unique container type for item
	if container.shape.uuid == ItemSpecialContainer[tostring(itemUid)] then
		return 4
	else
		local color = tostring(container.shape.color)
		--if container is single item type and item matches
        if isAnyOf(color,oneItemContainer) and sm.container.getFirstItem(container.shape:getInteractable():getContainer())["uuid"] == itemUid then
            return 3
		--if container is limited by catagory and item matches
        elseif catagoryContainer[color] and isAnyOf(itemUid,catagoryContainer[color]) then
            return 2
        end
    end
	--container has no limits on item type
    return 1
end

function FindContainerToCollectTo( containers, itemUid, amount )
	local chestPriority = 0
    local chest = nil
	for _, container in ipairs( containers ) do
		if sm.container.canCollect( container.shape:getInteractable():getContainer(), itemUid, amount ) then
			local v = evaluateChestPriority(container,itemUid)
			-- if current container is the new best, remember it
            if chestPriority < v then
                chestPriority = v
                chest = container
            end
		end
	end
	--return best valid container
    return chest
end

function FindContainerToSpendFrom( containers, itemUid, amount )
	for _, container in ipairs( containers ) do
		if sm.container.canSpend( container.shape:getInteractable():getContainer(), itemUid, amount ) then
			return container
		end
	end
end

PipeStateOverrideTable = {
	[PipeState.off] = {
		[PipeState.off] = false,
		[PipeState.invalid] = true,
		[PipeState.connected] = true,
		[PipeState.valid] = true,
	},
	[PipeState.invalid] = {
		[PipeState.off] = false,
		[PipeState.invalid] = false,
		[PipeState.connected] = false,
		[PipeState.valid] = false,
	},
	[PipeState.connected] = {
		[PipeState.off] = false,
		[PipeState.invalid] = true,
		[PipeState.connected] = false,
		[PipeState.valid] = true,
	},
	[PipeState.valid] = {
		[PipeState.off] = false,
		[PipeState.invalid] = true,
		[PipeState.connected] = false,
		[PipeState.valid] = false,
	},
}

function LightUpPipes( arrayPipes, fnOverride )
	for  _, pipe in ipairs( arrayPipes ) do
		local shape = pipe.shape
		local state = pipe.state
		if sm.exists( shape ) then
			local pipeGlow = 1.0

			if fnOverride then
				state, pipeGlow = fnOverride( pipe )
			end

			local currentUvFrameIndex = shape:getInteractable():getUvFrameIndex() + 1
			if PipeStateOverrideTable[currentUvFrameIndex][state] then
				shape:getInteractable():setUvFrameIndex( state - 1 )
				shape:getInteractable():setGlowMultiplier( pipeGlow )
			end
		end
	end
end

PipeEffectNode = class()

function PipeEffectNode.shapeExists( self )
	return self.shape:shapeExists()
end

function PipeEffectNode.getWorldPosition( self )
	return self.shape:transformLocalPoint( self.point )
end

PipeEffectPlayer = class()

function PipeEffectPlayer.onCreate( self )
	self.effectTasks = {}
end

function PipeEffectPlayer.pushShapeEffectTask( self, shapeList, item )

	assert( item )
	local effect = sm.effect.createEffect( "ShapeRenderable" )
	local bounds = sm.item.getShapeSize( item )
	assert( bounds )
	effect:setParameter( "uuid", item )
	effect:setPosition( shapeList[1]:getWorldPosition() )
	effect:setScale( sm.vec3.new( sm.construction.constants.subdivideRatio, sm.construction.constants.subdivideRatio, sm.construction.constants.subdivideRatio ) / bounds )

	self:pushEffectTask( shapeList, effect )
end

function PipeEffectPlayer.pushEffectTask( self, shapeList, effect )
	table.insert( self.effectTasks, { shapeList = shapeList, effect = effect, progress = 0 })
end

function PipeEffectPlayer.update( self, dt )
	for idx, task in reverse_ipairs( self.effectTasks ) do

		if task.progress == 0 then
			task.effect:start()
		end

		if task.progress > 0 and task.progress < 1 and #task.shapeList > 1 then
			local span = ( 1.0 / ( #task.shapeList - 1 ) )

			local b = math.ceil( task.progress / span ) + 1
			local a = b - 1
			local t = ( task.progress - ( a - 1 ) * span ) / span
			--print( "A: "..a.." B: "..b.." t: "..t)

			assert(a ~= 0 and a <= #task.shapeList)
			assert(b ~= 0 and b <= #task.shapeList)

			local nodeA = task.shapeList[a]
			local nodeB = task.shapeList[b]

			if pcall( function() nodeA:shapeExists() end ) and pcall( function() nodeB:shapeExists() end ) then
				local lerpedPosition = ( nodeA:getWorldPosition() * ( 1 - t ) ) + ( nodeB:getWorldPosition() * t )
				task.effect:setPosition( lerpedPosition )
			else
				task.progress = 1 -- End the effect
			end
		end

		task.progress = task.progress + dt / PipeTravelTime

		if task.progress >= 1 then
			task.effect:stop()
			table.remove( self.effectTasks, idx )
		end
	end
end