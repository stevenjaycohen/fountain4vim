# Vim Fountain (CONT'D)

Two wonderful Fountain Plugins for Vim have been unmaintained for a while now:
* [Vim Fountain](https://github.com/vim-scripts/fountain.vim)
  (A Syntax Highlighter for Fountain Files)
* [Fountain Flow](https://github.com/vim-scripts/fountainflow.vim)
  (A Fountain Exporter written in VimScript)

This project combines the functionality of the two and extends them, where possible.

## Installation

Mostly, it follows a standard Vim plugin

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

You will also need to add this variable to your `.vimrc`

~~~
let g:flow_directory = $HOME.'/path/to/flowfiles/'
~~~

To Import the LibreOffice Templates:

1. Open LibreOffice Writer
2. Open File > Templates > Manage Templates
3. In the Templates Window, find the Manage Dropdown and choose Import

## Usage

### What is Fountain?

[Fountain](https://fountain.io/) allows you to write screenplays in any text editor on any device. Because it’s just text, it’s portable and future-proof. It is a simple markup syntax for writing, editing and sharing screenplays in plain, human-readable text. Fountain allows you to work on your screenplay anywhere, on any computer or tablet, using any software that edits text files.

Taking its cues from [Markdown](https://en.wikipedia.org/wiki/Markdown), Fountain files are eminently readable. When special syntax is required, it is straightforward and intuitive.

### Writing in Fountain

### Exporting to LibreOffice
