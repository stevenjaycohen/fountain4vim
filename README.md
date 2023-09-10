# Vim Fountain (CONT'D)

Two wonderful Fountain Plugins for Vim have been unmaintained for a while now:
* [Vim Fountain](https://github.com/vim-scripts/fountain.vim)
  (A Syntax Highlighter for Fountain Files)
* [Fountain Flow](https://github.com/vim-scripts/fountainflow.vim)
  (A Fountain Exporter written in VimScript)

This project combines the functionality of the two and extends them, where possible.

## Installation

Mostly, it follows the install for a standard Vim plugin:

~~~
doc/
  fountain.txt
ftdetect/
  fountain.vim
ftplugin/
  fountain.vim
plugin/
  fountain.vim
syntax/
  fountain.vim
~~~

Remember to open vim and `:helptags ALL` to generate the new documentation.

You will also need to add this variable to your `.vimrc` pointing to your flowfiles folder.

~~~vimrc
let g:flow_directory = $HOME.'/path/to/flowfiles/'
~~~

To Import the LibreOffice Templates:

1. Open LibreOffice Writer
2. Open File > Templates > Manage Templates
3. In the Templates Window, find the Manage Dropdown and choose Import

## Usage

### What is Fountain?

> [Fountain](https://fountain.io/) allows you to write screenplays in any text editor on any device. Because it’s just text, it’s portable and future-proof. It is a simple markup syntax for writing, editing and sharing screenplays in plain, human-readable text. Fountain allows you to work on your screenplay anywhere, on any computer or tablet, using any software that edits text files.
> 
> Taking its cues from [Markdown](https://en.wikipedia.org/wiki/Markdown), Fountain files are eminently readable. When special syntax is required, it is straightforward and intuitive.

--[The Fountain Team](https://fountain.io/)

### Why Write in Vim?

I like distraction free writing. And, a terminal is about as distraction free as you can get. Writing in plain text not only keeps me from playing with fonts, etc, but it also means that what I write is easily portable to any new program/systems/etc.

For more information, see [writingvim](https://github.com/phantomdiorama/writingvim)

The code below (from my `.vimrc`) allows me to toggle easily between Coding and Writing:

~~~vimrc
"Toggle Writing/Code
map <silent><leader><leader> <esc>:call ToggleWriteCode()<cr>
function! ToggleWriteCode()
  if &foldcolumn=='0'
    :call WriteMode()
  else
    :call CodeMode()
  endif
endfunction
"Hide line numbers, activate spellcheck, increase left margin
function! WriteMode()
  exec('set nonumber')
  exec('set spell spelllang=en')
  exec('map j gj') 
  exec('map k gk')
  exec('set foldcolumn=1')
  exec('set linespace=11')
endfunction
"Show line numbers, deactivate spellcheck, reduce left margin
function! CodeMode()
  exec('set number')
  exec('set nospell')
  exec('map j j') 
  exec('map k k')
  exec('set foldcolumn=0')
  exec('set linespace=0')
endfunction
~~~

### Writing with Fountain

The plugin will automatically identify any file ending with .fountain and highlight all of the elements (Scene Headings, Actions, Characters, Dialogue, Parentheticals, Lyrics, Transitions, etc).

Right now, the Syntax Highlighter recognizes every Standard Transition that I could find. I will be working on adding that functionality to the export function. So, if your Transition does not render in the output, follow the Fountain Standard of using a `>` (example: >MYTRANSITION) until I can add it to the code.

### Why use LibreOffice?

Exporting to an editable format instead of directly to PDF allows me to review the content graphically before _signing off_ on the final PDF.

And, the LibreOffice PDF Export Tool has all of the options that I would ever need. So, there is no reason to reinvent the wheel and build yet another PDF exporter.

Also, I do a similar thing with Markdown files using `cmark` to translate:

~~~vimrc
"eXport Markdown (LibreOffice)
map <silent><leader>xm <esc>:!cmark % > /tmp/%:r.html<cr>:!libreoffice -o /tmp/%:r.html<cr>
~~~

### Exporting to LibreOffice

I added the following to my `.vimrc`:

~~~vimrc
"eXport Fountain (LibreOffice)
map <silent><leader>xf <esc>:FountainFlow<cr>:LibreOffice<cr>
let g:flow_directory = $HOME.'/Documents/vim-fountain/flowfiles/'
~~~

The two functions are `:FountainFlow` and `:LibreOffice`. Instead of calling these separately, I have connected the two with a single command.

`FountainFlow` parses the current file and fills the current buffer with an HTML version of the file.

`LibreOffice` opens the current file in LibreOffice (Writer in this case).

You can press `DELETE` to delete the HTML and return to your original document.
