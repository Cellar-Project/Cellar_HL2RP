local function DrawCorners(x, y, w, h, length, thickness)
	-- Top left
	surface.DrawRect(x, y, length, thickness)
	surface.DrawRect(x, y, thickness, length)

	-- Top right
	surface.DrawRect(x + (w - length), y, length, thickness)
	surface.DrawRect(x + (w - thickness), y, thickness, length)

	-- Bottom left
	surface.DrawRect(x, y + (h - length), thickness, length)
	surface.DrawRect(x, y + (h - thickness), length, thickness)

	-- Bottom right
	surface.DrawRect(x + (w - thickness), y + (h - length), thickness, length)
	surface.DrawRect(x + (w - length), y + (h - thickness), length, thickness)
end

local PANEL = {}

function PANEL:Init()
	self.segmentData = {}
	self.textData = {}
	self.messageData = "СОЦИО-СТАБИЛЬНОСТЬ В НОРМЕ"
	self.font = "dispatch.stability"
	self.color = Color(128, 255, 128)
	self.borderThickness = 1
	self.borderLength = 6
	self.freq = 1
	self.rate = 100
	self.realWidth = 385
	self.open = false
	self.flashing = false
end

function PANEL:SetText(text) self.messageData = tostring(text) end
function PANEL:SetFont(fontName) self.font = tostring(fontName) end
function PANEL:SetTextColor(color) self.color = color end

function PANEL:PaintSingle(w, h)
	local text = self.messageData .. "     ///     "

	surface.SetFont(self.font)

	local textw, texth = surface.GetTextSize(text)

	local alpha = self.flashing and (math.sin(CurTime() * 40) > 0 and 255 or 0) or 255

	surface.SetTextColor(self.color.r, self.color.g, self.color.b, alpha)

	if table.Count(self.segmentData) < 1 then
		table.insert(self.segmentData, {
			x = w,
			start = RealTime()
		})
	end

	for k, v in pairs(self.segmentData) do
		if !self.segmentData[k] then continue end

		self.segmentData[k].x = w - (RealTime() - v.start) * self.rate

		surface.SetTextPos(v.x, h / 2 - texth / 2)
		surface.DrawText(text)
	end

	for k, v in pairs(self.segmentData) do
		if v.x < -textw then
			table.remove(self.segmentData, k)
		end
	end

	local lastIndex = #self.segmentData
	local lastSegment = self.segmentData[lastIndex]

	if lastSegment and (lastSegment.x < (w - textw)) then
		table.insert(self.segmentData, {
			x = w,
			start = RealTime()
		})
	end
end

function PANEL:SetThickness(thickness)
	self.borderThickness = tonumber(thickness)
end

function PANEL:SetLength(length)
	self.borderLength = tonumber(length)
end

function PANEL:SetFlashFrequency(freq)
	self.freq = tonumber(freq)
end

local function SinBetween(freq, min, max)
	return math.abs(math.sin(CurTime() * freq)) * (max - min) + min
end

function PANEL:SetRealWidth(w)
	self.realWidth = tonumber(w)
	self:SetWide(w)
end

function PANEL:Paint(w, h)
	local red = SinBetween(self.freq, 0, self.color.r / 1.6)
	local green = SinBetween(self.freq, 0, self.color.g / 1.6)
	local blue = SinBetween(self.freq, 0, self.color.b / 1.6)

	surface.SetDrawColor(red, green, blue, 100)
	surface.DrawRect(0, 0, w, h)

	self:PaintSingle(self.realWidth, h)
	
	surface.SetDrawColor(self.color)

	DrawCorners(0, 0, w, h, self.borderLength, self.borderThickness)
end

vgui.Register("dispatch.stablity", PANEL)