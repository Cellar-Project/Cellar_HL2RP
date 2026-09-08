local ITEM = ix.item.New2("base_citarmbands")
	ITEM.name = "Коричневая повязка Альянса"
	ITEM.skin = 0
	ITEM.armband = 0
ITEM:Register()

local ITEM = ix.item.New2("base_citarmbands")
	ITEM.name = "Черная повязка Альянса"
	ITEM.skin = ITEM.model == "models/cellar/items/armband_citizen.mdl" and 1 or 0
	ITEM.armband = 1
ITEM:Register()

local ITEM = ix.item.New2("base_citarmbands")
	ITEM.name = "Зеленая повязка Альянса"
	ITEM.skin = ITEM.model == "models/cellar/items/armband_citizen.mdl" and 2 or 0
	ITEM.armband = 2
ITEM:Register()

local ITEM = ix.item.New2("base_citarmbands")
	ITEM.name = "Синяя повязка Альянса"
	ITEM.skin = ITEM.model == "models/cellar/items/armband_citizen.mdl" and 3 or 0
	ITEM.armband = 3
ITEM:Register()

local ITEM = ix.item.New2("base_citarmbands")
	ITEM.name = "Красная повязка Альянса"
	ITEM.skin = ITEM.model == "models/cellar/items/armband_citizen.mdl" and 4 or 0
	ITEM.armband = 4
ITEM:Register()
