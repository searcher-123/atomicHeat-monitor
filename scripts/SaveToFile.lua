heat_groups_by_pos={}

function create_and_sort_heat_groups (heat_groups,heat_groups_by_pos)
  heat_groups_by_pos={}
  log("create_and_sort_heat_groups s")
  if heat_groups == nil then return end
  log("create_and_sort_heat_groups cont")
  heat_groups_by_pos.min_x=9999999
  heat_groups_by_pos.max_x=-9999999
  heat_groups_by_pos.min_y=9999999
  heat_groups_by_pos.max_y=-9999999
  heat_groups_by_pos.ent={}
   for _, heat_group in pairs(heat_groups) do       
		for _, heat_group in pairs(heat_group ) do		
		log ("heat_group ")
		if heat_group == nil then return end
		log ("heat_group 1")
		if heat_group.entities == nil then return end		
		log ("heat_group 2")
		e=heat_group.entities
		log ("strange "..#e)
        for _, heat_entity in pairs(heat_group.entities) do 
			if heat_entity.valid ==true then
				pos=heat_entity.selection_box.left_top
				log ("pos "..pos.x)
				x_l=pos.x
				y_t=pos.y
				pos=heat_entity.selection_box.right_bottom
				x_r=pos.x-1
				y_b=pos.y-1
				if x_r>heat_groups_by_pos.max_x then heat_groups_by_pos.max_x=x_r end
				if y_t>heat_groups_by_pos.max_y then heat_groups_by_pos.max_y=y_t end
				if x_l<heat_groups_by_pos.min_x then heat_groups_by_pos.min_x=x_l end
				if y_b<heat_groups_by_pos.min_y then heat_groups_by_pos.min_y=y_b end			
				for x=x_l, x_r do				
					for y=y_t,y_b do					
						heat_groups_by_pos.ent["x"..x.."y"..y]=heat_entity				
					end
				end
			end
        end
    end
	end
	log ("done "..heat_groups_by_pos.max_x)
	return  heat_groups_by_pos
end

function save_rows_temp (heat_groups,heat_groups_by_pos)
    log ("save_rows_temp")
	--if heat_groups_by_pos=={} then heat_groups_by_pos=create_and_sort_heat_groups{heat_groups} end
	heat_groups_by_pos=create_and_sort_heat_groups{heat_groups,heat_groups_by_pos}
--game.write_file ("atomicHeat_temps.txt")
	log ("create_and_sort_heat_groups done")
	if heat_groups_by_pos =={} then 
		log ("no sort ")
		end
	ym=heat_groups_by_pos.min_y
	xm=heat_groups_by_pos.min_x
	for y= 0, (heat_groups_by_pos.max_y-heat_groups_by_pos.min_y)-1 do	
			   str_line="temp_data. tick ;"..game.tick.."; line ;"..y
				for x=0,  heat_groups_by_pos.max_x-heat_groups_by_pos.min_x-1 do							
					ent=heat_groups_by_pos.ent["x"..x+xm.."y"..y+ym]					
					str_temp="-"
					if ent ~=nil then 
						str_temp=ent.temperature
					else
						str_temp="-"
					end
					str_line=str_line..";"..str_temp
				end
				game.write_file ("atomicHeat_temps_x.txt",str_line.."\r\n",true)
			end

end
