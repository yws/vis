-- complete file path at primary cursor location using vis-complete(1)

vis:map(vis.modes.INSERT, "<C-x><C-f>", function()
	local win = vis.win
	local file = win.file
	local pos = win.cursor.pos
	if not pos then return end
	-- TODO do something clever here
	local range = file:text_object_word(pos > 0 and pos-1 or pos);
	if not range then return end
	if range.finish > pos then range.finish = pos end
	if range.start == range.finish then return end
	local prefix = file:content(range)
	if not prefix then return end
	local cmd = string.format("vis-complete --file '%s'", prefix:gsub("'", "'\\''"))
	local status, out, err = vis:pipe(file, { start = 0, finish = 0 }, cmd)
	if status ~= 0 or not out then
		if err then vis:info(err) end
		return
	end
	file:insert(pos, out)
	win.cursor.pos = pos + #out
end, "Complete file path")

-- complete file path at primary cursor location using vis-open(1)

vis:map(vis.modes.INSERT, "<C-x><C-o>", function()
	local win = vis.win
	local file = win.file
	local pos = win.cursor.pos
	if not pos then return end
	local range = file:text_object_word(pos > 0 and pos-1 or pos);
	if not range then return end
	if range.finish > pos then range.finish = pos end
	local prefix = file:content(range)
	if not prefix then return end
	if prefix:match("^%s*$") then
		prefix = ""
		range.start = pos
		range.finish = pos
	end
	local cmd = string.format("vis-open -- '%s'*", prefix:gsub("'", "'\\''"))
	local status, out, err = vis:pipe(file, { start = 0, finish = 0 }, cmd)
	if status ~= 0 or not out then
		if err then vis:info(err) end
		return
	end
	out = out:gsub("\n$", "")
	file:delete(range)
	file:insert(range.start, out)
	win.cursor.pos = range.start + #out
end, "Complete file name")
