" Utility:          fountain.vim
" Author:           Steven Jay Cohen, steven@stevenjaycohen.com
" Version:          3.00
" Release Date:     2023-10-01
"

" Default VARIABLES {{{
if !exists('g:flow_extensions')
    let g:flow_extensions = 'txt fountain spmd'
endif
let g:flow_extensions = substitute(g:flow_extensions,",*\\s\\+","\\\\|","g")
if !exists('g:flow_directory')
    let g:flow_directory = $HOME.'/.vim/plugin/fountain/'
endif
if !exists('g:flow_style_sheet')
    let g:flow_style_sheet = "screenplayStyle.css"
endif
if !exists('g:flow_style_method')
    let g:flow_style_method = "embed"
    " option: embed|link
endif
if !exists('g:flow_header')
    let g:flow_header = "screenplayHeader.html"
endif
if !exists('g:flow_footer')
    let g:flow_footer = "screenplayFooter.html"
endif
if !exists('g:flow_title_page')
    let g:flow_title_page = "screenplayTitlePage.html"
endif
if !exists('g:flow_dual_processing')
    let g:flow_dual_processing = "yes"
    " option: yes/no
endif
if !exists('g:flow_collaboration')
    let g:flow_collaboration = "no"
    " option: yes/no
endif
if !exists('g:flow_line_style')
    let g:flow_line_style = "margin-top: 0pt; margin-bottom: 0pt;"
endif
if !exists('g:flow_line_style_spaced')
    :let g:flow_line_style_spaced = "margin-top: 13pt; margin-bottom: 0pt;"
endif
" }}}

function! FountainTOhtml()

    " CREATE OR RETURN TO HTML FILE {{{
    echo "Loading HTML file."
    let g:flow_original = expand("%")
    let g:flow_html = expand("%:p:r").".temp.html"
    if filereadable(g:flow_html)
        silent exe 'normal ggvGg_"fy'
        silent exe 'tab drop '.substitute(g:flow_html," ","\\\\ ","g")
        exe 'normal ggvGg_"fp'
        silent write
    else
        tab drop %
        silent exe 'saveas! '.substitute(g:flow_html," ","\\\\ ","g")
    endif
    " }}}

    " Let's make sure we're in the right buffer!
    if expand("%:p") == g:flow_html
        echo "Everything looks OK."
        if isdirectory(g:flow_directory)
            echo "Template directory found."
        else
            echo "Template directory not found. Loading default code."
        endif

        " Grab TITLE PAGE DATA {{{
        exe 'normal ggv'
        exe '/^\s*$'
        exe 'normal "fx'
        let g:flow_data = substitute(@f,"\\n\\s\\+","<br>","g")
        let fd = split(g:flow_data,"[\n]")
        0put='<p style=\"page-break-before: always;\"></p>'
        " }}}

        " Remove or reformat SECTIONS/NOTES/BONEYARD {{{
        if g:flow_collaboration == "yes"
            echo "Processing notes and other private data."
            silent exe '%s/\v\[\[([^\]]*)\]\]/<p class="Notes" style="'.g:flow_line_style_spaced.'">\1<\/p>/ge'
        else
            echo "Removing notes and other private data."
            silent %s/\v\[\[(.*)\]\]//ge
        endif
        if g:flow_collaboration == "yes"
            silent %s/\v\/\*(\_.+)\*\//<span class="Boneyard">\1<\/span>/ge
        else
            silent %s/\v\/\*(\_.+)\*\///ge
        endif
        if g:flow_collaboration == "yes"
            silent %s/\v^\s*#{6}\s(.+)$/<h6>\6<\/h6>/ge
            silent %s/\v^\s*#{5}\s(.+)$/<h5>\5<\/h5>/ge
            silent %s/\v^\s*#{4}\s(.+)$/<h4>\4<\/h4>/ge
            silent %s/\v^\s*#{3}\s(.+)$/<h3>\3<\/h3>/ge
            silent %s/\v^\s*#{2}\s(.+)$/<h2>\2<\/h2>/ge
            silent %s/\v^\s*#{1}\s(.+)$/<h1>\1<\/h1>/ge
        else
            silent %s/\v^\s*#{1,6}\s.+\n+//ge
        endif
        " }}}

        " Insert PAGE BREAK {{{
        silent %s/\v^\s*\={3,}\s*/<p style="page-break-before: always;"><\/p>/ge
        silent %s/\v^(\s*)\\(\={3,})\s/\1\2/ge
        " }}}

        " Process SCENE HEADING and TRANSITIONAL {{{
        echo "Processing scene headers and transitions."
        silent exe '%s/\v^$\n\c((\.|(int|ext|int\.\/ext|int\/ext|est|ie))(.+))\n^$/\r<p style="'.g:flow_line_style_spaced.'" class="SceneHeading">\3\4<\/p>\r/ge'
        "
        " Must process CENTERED before TRANSITIONAL
        silent exe '%s/\v^\s*\>(.+)\</<p style="'.g:flow_line_style_spaced.' text-align: center;">\1<\/p>/ge'
                                                   
        silent exe '%s/\v^$\n\s*(\>\s*(.+)|(\L+ TO:))\s*\n^$/\r<p style="'.g:flow_line_style_spaced.'" class="Transitional">\2\3<\/p>\r/ge'
        " }}}

        " Process CHARACTER/PARENTHETICAL/DIALOGUE BLOCK {{{
        echo "Processing dialogue blocks."
        silent exe '%s/\v^$\n\s*(\@([^\(]+)|([A-Z0-9]\L+))(\s*\(.+\))*\s*\n(.+)/\r<p style="'.g:flow_line_style_spaced.'" class="Character">\2\3\4<\/p>::c::\r\5/ge'
        let lnum = 1
        while lnum <= (line("$"))-1
            silent exe lnum.','.lnum+1.'s/\v::[cd]::\n\s*(\(.+\))\n/\r<p style="'.g:flow_line_style.'" class="Parenthetical">\1<\/p>::p::\r/ge'
            silent exe lnum.','.lnum+1.'s/\v::[cp]::\n(.+\n)/\r<p style="'.g:flow_line_style.'" class="Dialogue">\r\t\1<\/p>::d::\r/ge'
            silent exe lnum.','.lnum+1.'s/\v::d::\n(.+\n)/\r<p style="'.g:flow_line_style_spaced.'" class="Dialogue">\r\t\1<\/p>::d::\r/ge'
            let lnum = lnum + 1
        endwhile
        silent %s/\v::.:://ge
        " }}}

        " DUAL DIALOGUE {{{
        if g:flow_dual_processing == "yes"
            echo "Processing dual dialogue."
            %s/\v\n(\<p.*class\="Character"\_.{-})^$(\n.*class=\="Character".*)\^(\_.{-}\<\/p\>\n)^$/\r<table class="DualDialogue" width="100%">\r<tr>\r<td class="LeftDialogue" width="50%" valign="top">\r\1<\/td>\r<td class="RightDialogue" width="50%" valign="top">\2\3<\/td>\r<\/tr>\r<\/table>\r/ge
            %s/\v((Left|Right)Dialogue\_.{-})class\="Character"(.*\n.*)class\="Parenthetical"(\_.{-})class\="Dialogue"/\1class="DualCharacter"\3class="DualParenthetical"\4class="DualDialogue"/ge
            %s/\v((Left|Right)Dialogue\_.{-})class\="Character"(.*\n.*)class\="Dialogue"/\1class="DualCharacter"\3class="DualDialogue"/ge
        else
            echo "Dual dialogue processing switched off."
        endif
        " }}}

        " ETCETERA {{{
        echo "Etcetera, etcetera, etcetera."

        " Process SYNOPSIS
        silent exe '%s/\v^\s*\=\s*([^\=].+)$/<div id="SynopsisPage">\r\r<p class="Synopsis" style="'.g:flow_line_style_spaced.'">\1<\/p>\r\r<\/div>/ge'

        " Process LYRICS
        silent exe '%s/\v^\s*\~\s*(.*)/<p style="'.g:flow_line_style.'" class="Lyrics">\1<\/p>/ge'

        " PROTECTED LINES
        silent exe '%s/\v^\\(.*)/<p style="'.g:flow_line_style_spaced.'">\1<\/p>/ge'
        " }}}

        " Process ACTION {{{
        echo "Processing action."
        silent exe '%s/\v^$\n(\s*)!?([^\<^\>].+)$/\r<p style="'.g:flow_line_style_spaced.'" class="Action">\1\2<\/p>:::/ge'
        let lnum = 1
        while lnum <= (line("$"))-1
            silent exe lnum.','.lnum+1.'s/\v:::\n(\s*)!?([^\<^\>].+)$/\r<p style="'.g:flow_line_style.'" class="Action">\1\2<\/p>:::/ge'
        :.s/\v\t/\&nbsp;\&nbsp;\&nbsp;\&nbsp;/ge
        :.s/\v\s{4}/\&nbsp;\&nbsp;\&nbsp;\&nbsp;/ge
            let lnum = lnum + 1
        endwhile
        silent %s/\v::://ge
        " }}}

        " Process EMPHASIS {{{
        echo "Processing emphasis."
        silent %s/\v\\@<!_\s@!(.{-})(\s|\\)@<!_/<span style="text-decoration: underline;">\1<\/span>/ge
        silent %s/\v\\_/_/ge
        silent %s/\v\\@<!\*{3}\s@!(.{-})(\s|\\)@<!\*{3}/<span style="font-weight:bold; font-style:italic;">\1<\/span>/ge
        silent %s/\v\\@<!\*{2}\s@!(.{-})(\s|\\)@<!\*{2}/<span style="font-weight:bold;">\1<\/span>/ge
        silent %s/\v\\@<!\*{1}\s@!(.{-})(\s|\\)@<!\*{1}/<span style="font-style:italic;">\1<\/span>/ge
        silent %s/\\\*/\*/ge
        " }}}

        " FINISH PAGE {{{
        if filereadable(g:flow_directory.g:flow_title_page)
            echo "Loading title page template."
            silent exe '0read '.g:flow_directory.g:flow_title_page
        else
            echo "Inserting default title page template."
            1s/^/<div id="TitlePage">\r\t<div id="Spacer1">\r\t\t<p>\&nbsp;<\/p>\r\t<\/div>\r\t<p class="Title">%Title%<\/p>\r\t<p class="Author">%Credit% %Author%<\/p>\r\t<p class="Source">%Source%<\/p>\r\t<div id="Spacer2">\r\t\t<p>\&nbsp;<\/p>\r\t<\/div>\r\t<table id="TitlePageTable" width="100%" style="page-break-inside: avoid">\r\t\t<tr>\r\t\t\t<td id="TableLeft" width="50%;" align="left" valign="bottom">\r\t\t\t\t<p style="margin-top: 12pt; margin-bottom: 0pt;">%Contact%<\/p>\r\t\t\t<\/td>\r\t\t\t<td id="TableRight" width="50%" align="right" valign="bottom">\r\t\t\t\t<p style="margin-top: 12pt; margin-bottom: 0pt;">%Draftdate%<\/p>\r\t\t\t\t<p style="margin-top: 12pt; margin-bottom: 0pt;">%Notes%<\/p>\r\t\t\t\t<p style="margin-top: 12pt; margin-bottom: 0pt;">%Copyright%<\/p>\r\t\t\t<\/td>\r\t\t<\/tr>\r\t<\/table>\r<\/div>\r\r/ge
        endif
        " ADD DIV AROUND SCRIPT
        silent exe 'normal G'
        silent exe '?<\/div>'
        silent exe '/page-break-before: always;'
        silent exe 'normal o'
        silent .s/^/\r\r<div id="ScriptPage">
        silent exe 'normal Go'
        silent .s/^/\r\r<\/div>
        " The above is kind of jury-rigged at the moment.     
        if filereadable(g:flow_directory.g:flow_header)
            echo "Loading header template."
            silent exe '0read '.g:flow_directory.g:flow_header
        else
            echo "Inserting default header template."
            1s/^/<html>\r<head>\r<meta http-equiv="content-type" content="text\/html; charset=utf-8">\r<title><\/title>\r<style>\r<!--\r\r-->\r<\/style>\r<\/head>\r<body lang="en-US" dir="ltr">\r\r/ge
        endif
        if filereadable(g:flow_directory.g:flow_footer)
            echo "Loading footer template."
            silent exe '$read '.g:flow_directory.g:flow_footer
        else
            echo "Inserting default footer template."
            $s/$/\r<\/body>\r<\/html>/e
        endif
        if g:flow_style_method == 'embed' && filereadable(g:flow_directory.g:flow_style_sheet)
            echo "Embedding styles."
            exe 'normal gg'
            exe '/\n\n\_.*\/style'
            silent exe 'read '.g:flow_directory.g:flow_style_sheet
        elseif g:flow_style_method == "link"
            echo "Linking styles."
            exe 'normal gg'
            exe '/\n<\/head>'
            put='<link rel=\"stylesheet\" type=\"text/css\" href=\"'.g:flow_directory.g:flow_style_sheet.'\">'
        else
            echo "Inserting default styles."
            exe 'normal gg'
            exe '/\n\n\_.*\/style'
            .s/^/@page:first\r{\r\tmargin: 0.75in 1in 0.75in 1.5in;\r}\r@page\r{\r\tmargin: 0.75in 1in 0.75in 1.5in;\r}\rp\r{\r\tmargin-top: 0pt;\r\tmargin-bottom: 0pt;\r\tpadding-top: 0pt;\r\tpadding-bottom: 0pt;\r\tbackground: transparent;\r\tline-height: 13pt;\r}\r.normal\r{\r\tmargin-top: 13pt;\r\tmargin-bottom: 0pt;\r\tpadding-top: 0pt;\r\tpadding-bottom: 0pt;\r\tbackground: transparent;\r\tline-height: 13pt;\r}\rbody\r{\r\twidth: 8.5in;\r\tbackground: #fff;\r\tfont-family: 'Courier Prime', 'courier new';\r\tfont-size: 12pt;\r}\r.SceneHeading\r{\r\tmargin-top: 13pt;\r\tpage-break-before: auto;\r\tpage-break-after: avoid;\r}\r.Action, .Synopsis\r{\r\tmargin-top: 13pt !important;\r\torphans: 3;\r\twidows: 3;\r} \r.Transitional\r{\r\tmargin-top: 13pt;\r\tmargin-left: 4in;\r}\r.Character\r{\r\tmargin-left: 2in;\r\tpage-break-before: auto;\r\tpage-break-after: avoid;\r}\r.Parenthetical\r{\r\tmargin-left: 1.5in;\r\tmargin-right: 1.5in;\r\tpage-break-after: avoid;\r}\r.Dialogue\r{\r\tmargin-left: 1in;\r\tmargin-right: 1in;\r\torphans: 2;\r\twidows: 2;\r\tpage-break-before: avoid;\r\tpage-break-after: auto;\r}\r.DualCharacter\r{\r\tmargin-left: 1in;\r\tpage-break-before: auto;\r\tpage-break-after: avoid;\r}\r.DualParenthetical\r{\r\tmargin-left: 0.6in;\r\tmargin-right: 0.6in;\r\tpage-break-after: avoid;\r}\r.DualDialogue\r{\r\tmargin-left: 0.125in;\r\tmargin-right: 0.125in;\r\torphans: 2;\r\twidows: 2;\r\tpage-break-before: avoid;\r\tpage-break-after: auto;\r}\r#TitlePage\r{\r\tmargin-right: 1.5in;\r\tmargin-left: 1.5in;\r\ttext-align: center;\r\tmargin-top: 13pt;\r\tmargin-bottom: 0pt;\r}\r#TitlePageNotes\r{\r\tmargin-top: 13pt;\r}\r#Spacer1\r{\r\tmargin-top: 0.5in;\r}\r#Spacer2\r{\r\tmargin-top: 3in;\r}\rh1, h2, h3, h4, h5, h6\r{\r\tfont-family: serif;\r}\r.Notes\r{\r\tfont-family: serif;\r\tcolor: #777;\r}\r.Boneyard\r{\r\ttext-decoration: line-through;\r}\r/ge
        endif
        echo "Processing title page."
        for item in fd
            let s:Field = substitute(item,":.*","","g")
            let s:Data = substitute(item,s:Field.":\s*","","g")
            "let s:Data = substitute(item,".*:\\s*","","g")
            let s:Field = substitute(s:Field," ","","g")
            let s:Data = substitute(s:Data,"^\\(<br>\\|\\s\\)","","g")
            let s:Data = substitute(s:Data,"/","\\\\/","g")
            if s:Field == "Title"
                let s:Title = s:Data
            endif
            exe '%s/%'.s:Field.'%/'.s:Data.'/ge'
        endfor
        silent exe '%s/\v\<title\>.*\<\/title\>/<title>'.substitute(s:Title,"<br>"," ","g").'<\/title>'
        silent exe '%s/\v\%\w+\%//ge'
        " }}}

        " CLEANING UP {{{
        silent g/^$/,/./-j
        silent write
        silent e
        normal gg
        " }}}

    endif

    echo "Thank you for using Fountain Flow for Vim."

endfunction

function! Flow()
    if expand("%:e") =~ "\\(".g:flow_extensions."\\)"
        call FountainTOhtml()
        noh
        nnoremap <silent> <buffer> <home> :exe 'Tex '.g:flow_directory<cr>
        nnoremap <silent> <buffer> <backspace> :exe 'e '.substitute(g:flow_original," ","\\\\ ","g")<cr>
        nnoremap <silent> <buffer> <delete> :exe 'tab drop '.substitute(g:flow_original," ","\\\\ ","g")<cr>:exe 'bd '.substitute(g:flow_html," ","\\\\ ","g")<cr>:exe 'call delete("'.substitute(g:flow_html," ","\\\\ ","g").'")'<cr>
        nnoremap <silent> <buffer> <tab> :exe 'tab drop '.substitute(g:flow_original," ","\\\\ ","g")<cr>
        nnoremap <silent> <buffer> <space> :exe 'vsplit '.substitute(g:flow_original," ","\\\\ ","g")<cr>
        nnoremap <silent> <buffer> <cr> :!libreoffice --writer "%" &<cr>
        nnoremap <silent> <buffer> <esc> :mapclear <buffer><cr>
    else
        echo "Wrong filetype. Consult :help fountainflow"
    endif
endfunction
" command! FF call Flow()
command! FountainFlow call Flow()
command! LibreOffice silent !libreoffice --writer "%" &
command! FlowDirectory silent exe 'Tex '.g:flow_directory



