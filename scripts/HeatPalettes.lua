heat_palettes= {
	[1]={name="baggins_n",
	    b_need_numbers = true, --нужны ли числа true / false
	    b_need_rects = false, --нужна ли подсветка клеток true / false
	    ranges_numbers = {--диапазоны для чисел
        	--здесь от 0 до 250 будет постоянный цвет т.к. low и high одинаковые, и это будет красный - т.к. компонента красного r=255, а остальные по нулям
	        { range = 250, low = { r = 255, g = 0, b = 0, a = 1 }, high = { r = 255, g = 0, b = 0, a = 1 } },
	        --здесь от предыдущей границы т.е. 250 до 500 будет постоянный цвет т.к. low и high одинаковые, и это будет жёлтый - т.к. компоненты красного r=255 и зеленого g=255, а остальные по нулям
        	{ range = 500, low = { r = 255, g = 255, b = 0, a = 1 }, high = { r = 255, g = 255, b = 0, a = 1 } },
	        --здесь от предыдущей границы т.е. 500 до 1000 будет постоянный цвет т.к. low и high одинаковые, и это будет зеленый - т.к. компонента зеленого g=255, а остальные по нулям
        	{ range = 1000, low = { r = 0, g = 250, b = 0, a = 1 }, high = { r = 0, g = 250, b = 0, a = 1 } }
   		 }	        
	},
	[2]={name="Faxir_n",	    b_need_numbers = true, 	    b_need_rects = false, --нужна ли подсветка клеток true / false
	    ranges_numbers = {--диапазоны для чисел	
	        --здесь от 0 до 500 будет градиент от low "синий" до high "почти серый"
        	{ range = 500, low = { r = 0, g = 0, b = 255, a = 255 }, high = { r = 100, g = 200, b = 200, a = 255 } },
	        --здесь от 500 до 950 будет градиент от low "почти белый" до high  "красный"
        	{ range = 950, low = { r = 250, g = 250, b = 230, a = 255 }, high = { r = 200, g = 160, b = 0, a = 255 } },
	        --здесь от 500 до 950 будет градиент от low "почти белый" до high  "красный"
	        { range = 1000, low = { r = 200, g = 0, b = 0, a = 255 }, high = { r = 255, g = 0, b = 0, a = 255 } }
	    }                   
	},
	[3]={name="bombino_n",	  b_need_numbers = true,	  b_need_rects = false,
	  ranges_numbers = {--диапазаны для клеток
        --здесь от 0 до 500 будет градиент от low "синий" до high "почти серый"
        { range = 500, low = { r = 0, g = 0, b = 255, a = 1 }, high = { r = 200, g = 200, b = 200, a = 1 } },
        --здесь от 500 до 1000 будет градиент от low "почти белый" до high  "красный"
        { range = 1000, low = { r = 230, g = 230, b = 230, a = 1 }, high = { r = 255, g = 0, b = 0, a = 1 } }
	    }                   
	},
	[4]={name="rects_and_digits",	  b_need_numbers = true,	  b_need_rects = true,
	  ranges_numbers = {--диапазаны для клеток
        { range = 1000, low = { r = 0, g = 255, b = 0, a = 1 }, high = { r = 0, g = 255, b = 0, a = 1 } }  } ,
	    ranges_rects = {--диапазаны для клеток
	        --здесь от 0 до 500 будет градиент от low "синий" до high "почти серый"
	        { range = 500, low = { r = 0, g = 0, b = 255, a = 0.2 }, high = { r = 200, g = 200, b = 200, a = 0.1 } },
	        --здесь от 500 до 1000 будет градиент от low "почти белый" до high  "красный"
	        { range = 1000, low = { r = 230, g = 230, b = 230, a = 0.1 }, high = { r = 255, g = 0, b = 0, a = 0.2 } }
	    }
  	  },
	[5]={name="rects_n",	    b_need_numbers = false, 	    b_need_rects = true, 
	    ranges_rects = {--диапазаны для клеток
	        --здесь от 0 до 500 будет градиент от low "синий" до high "почти серый"
	        { range = 500, low = { r = 0, g = 0, b = 255, a = 0.2 }, high = { r = 200, g = 200, b = 200, a = 0.1 } },
	        --здесь от 500 до 1000 будет градиент от low "почти белый" до high  "красный"
	        { range = 1000, low = { r = 230, g = 230, b = 230, a = 0.1 }, high = { r = 255, g = 0, b = 0, a = 0.2 } }
	    }                   
	}

	}


heat_palette = {
    b_need_numbers = true, --нужны ли числа true / false
    b_need_rects = true, --нужна ли подсветка клеток true / false
    --диапазоны. указывается верхняя граница и два цвета в формате rgba 0-255 r- красная компонента, g- зеленая б\, b- синяя, a- альфаканал как бы "прозрачность" (1 непрозрачный полностью, 0 - полностью прозрачный)
    ranges_numbers = {--диапазоны для чисел

        --здесь от 0 до 250 будет постоянный цвет т.к. low и high одинаковые, и это будет красный - т.к. компонента красного r=255, а остальные по нулям
        { range = 250, low = { r = 255, g = 0, b = 0, a = 0 }, high = { r = 255, g = 0, b = 0, a = 1 } },
        --здесь от предыдущей границы т.е. 250 до 500 будет постоянный цвет т.к. low и high одинаковые, и это будет жёлтый - т.к. компоненты красного r=255 и зеленого g=255, а остальные по нулям
        { range = 500, low = { r = 255, g = 255, b = 0, a = 0.5 }, high = { r = 255, g = 255, b = 0, a = 0.5 } },
        --здесь от предыдущей границы т.е. 500 до 1000 будет постоянный цвет т.к. low и high одинаковые, и это будет зеленый - т.к. компонента зеленого g=255, а остальные по нулям
        { range = 1000, low = { r = 0, g = 250, b = 0, a = 1 }, high = { r = 0, g = 250, b = 0, a = 1 } }
    },
    ranges_rects = {--диапазаны для клеток
        --здесь от 0 до 500 будет градиент от low "синий" до high "почти серый"
        { range = 500, low = { r = 0, g = 0, b = 255, a = 0.2 }, high = { r = 200, g = 200, b = 200, a = 0.1 } },
        --здесь от 500 до 1000 будет градиент от low "почти белый" до high  "красный"
        { range = 1000, low = { r = 230, g = 230, b = 230, a = 0.1 }, high = { r = 255, g = 0, b = 0, a = 0.2 } }
    }
}

function set_palette ()

    --uncomment one of next lines to change palette style
   -- bambino()
    --baggins()

    if PaletteNumber ~=nil then
	--log ("set_palette "..PaletteNumber)
	--log ("nAME "..heat_palettes[PaletteNumber].name)
	heat_palette.b_need_numbers=heat_palettes[PaletteNumber].b_need_numbers
	heat_palette.b_need_rects=heat_palettes[PaletteNumber].b_need_rects
	heat_palette.ranges_rects=heat_palettes[PaletteNumber].ranges_rects
	heat_palette.ranges_numbers=heat_palettes[PaletteNumber].ranges_numbers
    else
    FaXiR()
    end
    --palette_just_rects()
    --palette_just_green_digits()
end

function baggins()
    heat_palette.b_need_numbers = true --нужны ли числа true / false
    heat_palette.b_need_rects = false--нужна ли подсветка клеток true / false
end

function bombino()
    heat_palette.b_need_numbers = true --нужны ли числа true / false
    heat_palette.b_need_rects = false--нужна ли подсветка клеток true / false
    heat_palette.ranges_numbers = {--диапазаны для клеток
        --здесь от 0 до 500 будет градиент от low "синий" до high "почти серый"
        { range = 500, low = { r = 0, g = 0, b = 255, a = 0.2 }, high = { r = 200, g = 200, b = 200, a = 0.1 } },
        --здесь от 500 до 1000 будет градиент от low "почти белый" до high  "красный"
        { range = 1000, low = { r = 230, g = 230, b = 230, a = 0.1 }, high = { r = 255, g = 0, b = 0, a = 0.2 } }
    }
end

function FaXiR()
    heat_palette.b_need_numbers = true --нужны ли числа true / false
    heat_palette.b_need_rects = false--нужна ли подсветка клеток true / false
    heat_palette.ranges_numbers = {--диапазаны для клеток
        --здесь от 0 до 500 будет градиент от low "синий" до high "почти серый"
        { range = 500, low = { r = 0, g = 0, b = 255, a = 255 }, high = { r = 100, g = 200, b = 200, a = 255 } },
        --здесь от 500 до 950 будет градиент от low "почти белый" до high  "красный"
        { range = 950, low = { r = 250, g = 250, b = 230, a = 255 }, high = { r = 200, g = 160, b = 0, a = 255 } },
        --здесь от 500 до 950 будет градиент от low "почти белый" до high  "красный"
        { range = 1000, low = { r = 200, g = 0, b = 0, a = 255 }, high = { r = 255, g = 0, b = 0, a = 255 } }
    }
end

function palette_just_rects()
    heat_palette.b_need_numbers = false --нужны ли числа true / false
    heat_palette.b_need_rects = true--нужна ли подсветка клеток true / false
end

function palette_just_rects()
    heat_palette.b_need_numbers = false --нужны ли числа true / false
    heat_palette.b_need_rects = true--нужна ли подсветка клеток true / false
end

function palette_just_green_digits()
    heat_palette.b_need_numbers = true --нужны ли числа true / false
    heat_palette.b_need_rects = false--нужна ли подсветка клеток true / false
    ranges_numbers = {--диапазоны для чисел
        { range = 1000, low = { r = 0, g = 250, b = 0, a = 1 }, high = { r = 0, g = 250, b = 0, a = 1 } }
    }
end


