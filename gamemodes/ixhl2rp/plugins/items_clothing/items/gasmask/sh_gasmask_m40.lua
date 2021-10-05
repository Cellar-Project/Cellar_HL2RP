ITEM.name = "Противогаз М40"
ITEM.description = "Американский военный противогаз 'М40', производился в Соединенных Штатах Америки для военных нужд, включает в себе улучшенную систему фильтрования, панорамные защитные стекла и устройство позволяющее внятно разговаривать не смотря на противогаз. Чаще всего, не рабочее."
ITEM.model = Model("models/cellar/items/m40.mdl")
ITEM.rarity = 2
ITEM.bodyGroups = {
	[5] = 2
}
ITEM.Filters = {
	["filter_epic"] = true,
	["filter_good"] = true,
	["filter_medium"] = true,
	["filter_standard"] = true
}
ITEM.Stats = {
	[HITGROUP_GENERIC] = 0,
	[HITGROUP_HEAD] = 2,
	[HITGROUP_CHEST] = 0,
	[HITGROUP_STOMACH] = 0,
	[4] = 0,
	[5] = 0,
}