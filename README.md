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

[Fountain](https://fountain.io/) allows you to write screenplays in any text editor on any device. Because it’s just text, it’s portable and future-proof.

### Writing in Fountain

### Exporting to LibreOffice
