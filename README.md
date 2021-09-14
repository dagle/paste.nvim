# paste.nvim a paste tool for neovim
paste.nvim is a small tool that lets you paste files, bufferes, selected text and registers
to a pastebin (currently only paste.rs)

## Install
To install I recommend using your favourite plugin manager. Here is an example using packer:

```lua
	use 'dagle/paste.nvim'
```

## Usage
paste.nvim uses callbacks and doesn't block by default.
The default callback method is just to print the paste. But if you want you could hook it up 
to something like vim.notify.

Here is an exapmle:
```lua
	require('paste').setup({
		callback = vim.notify(response,  {
			title = 'paste.nvim',
		})
	})
```

paste exposes these 5 lua functions:

	paste, pastebuf, pastesel, pasteyank, getPaste

pastesel needs to be bind to something or you can't invoke it without leaving visual:
```vim
vnoremap <C-p> <cmd>lua pastesel()<CR>
```

## Todo
- [ ] Get the visual mode 
- [ ] Add more pastebins
- [ ] Tidy up the code
