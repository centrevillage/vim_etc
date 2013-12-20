scriptencoding utf8
" NOTE: Windows環境専用

if exists('g:loaded_m_etc') || &cp
    finish
endif
let g:loaded_m_etc = 1

" surround.vim {{{
let g:surround_{char2nr("_")} = "_(\r)"
let g:surround_{char2nr("r")} = "<%= _(\"\r\") %>"
let g:surround_{char2nr("h")} = "<%= h \r %>"
let g:surround_{char2nr("-")} = "<%= \r -%>"
let g:surround_{char2nr("u")} = "<URL:\r>"
" surround.vim }}}

" httpサポート機能 {{{
function! HttpGet(...)
    if a:0 < 1 | return | endif
    let url = a:1
"    call confirm(url)

python <<EOF
import urllib, vim, sys, string

b = vim.current.buffer
url = vim.eval('url')
result = urllib.urlopen(url)
# うまくいかねえ・・
#cline = long(vim.current.line)
#r = b.range(cline, len(b)) 
b.append(result.readlines())
EOF
"ruby <<EOF
"    require 'open-uri'
"    url = VIM::evaluate('url')
"    proxy = VIM::evaluate('g:mn_proxy')
"    buffer = $curbuf
"    VIM::command("call confirm('url: #{url}, <NL>proxy: #{proxy}')")
"    open(url, :proxy => proxy) {|f|
"        buffer.append(line, f.readlines)
"    }
"EOF
endfunction
command! -nargs=+ HttpGet :call HttpGet(<f-args>)

" httpサポート機能 }}}

" ブックマーク機能(要UTL <URL:http://vim.sf.net/script.php?script_id=293> ) {{{
function! Bookmark()
    if !exists('g:mn_bookmark_path')
        let bookmark_path = $HOME.'/bookmark.txt'
        return
    else
        let bookmark_path = g:mn_bookmark_path
    endif
    if &modified 
        execute 'sp ' . bookmark_path
    else
        execute 'e ' . bookmark_path
    endif
endfunction
command! BM :call Bookmark()

function! BookmarkAdd()
    let path = '<URL:file://' . substitute(expand('%:p'), '\', '/', 'g') . '#line=' . line('.') . '>'
    call Bookmark()
    call append(line('$'), path)
"    execute 'w'
endfunction
command! BA :call BookmarkAdd()

" ブックマーク機能(要UTL <URL:http://vim.sf.net/script.php?script_id=293> ) }}}


" フォントの拡大／縮小
"  set guifont=Ricty:h11
let s:font_sizes = [8, 9, 10, 11, 12, 14, 16, 18 ,20, 22, 24, 26, 28, 36, 48, 72]
function! ZoomIn()
  let h = matchstr(&guifont, ':h\zs\d\+\ze')
  if h == s:font_sizes[-1] | return | endif
  let idx = match(s:font_sizes, h) + 1
  let &guifont = 'Ricty:h' . s:font_sizes[idx]
endfunction
function! ZoomOut()
  let h = matchstr(&guifont, ':h\zs\d\+\ze')
  if h == s:font_sizes[0] | return | endif
  let idx = match(s:font_sizes, h) - 1
  let &guifont = 'Ricty:h' . s:font_sizes[idx]
endfunction

function! VSExec()
  execute getline('.')
endfunction

command! -range VSExec :<line1>,<line2>call VSExec()

" タブごとにディレクトリを設定 {{{
" original: http://whileimautomaton.net/2007/11/diary#d23-1309

command! -nargs=1 TabCD
      \   execute 'cd' <q-args>
      \ | let t:cwd = getcwd()

autocmd TabEnter *
      \   if !exists('t:cwd')
      \ |   let t:cwd = getcwd()
      \ | endif
      \ | execute 'cd' t:cwd

" }}}

" java用
au BufNewFile,BufRead *.java set ts=4 sw=4 expandtab

" マッピングいろいろ
nmap <Leader>* :let @" = GetWordStr()<cr>
nmap <Leader>+* :let @+ = GetWordStr()<cr>
nmap <Leader>spw :StoreWorkPath<cr>
nmap <Leader>ppw :PutBkWorkPath<cr>
nmap <Leader>w :up<cr>
nmap "" :close<cr>
nnoremap <Leader>enu :e ++enc=utf-8<cr>
nnoremap <Leader>ens :e ++enc=cp932<cr>
nnoremap <Leader>ene :e ++enc=euc-jp<cr>
nnoremap <Leader>fs :set fu<cr>
nnoremap <Leader>ns :set nofu<cr>
nmap <Leader><Leader> :let @/ = ''<cr>

" スクリプトレット埋め込み
nmap <Leader>>> i<%=%><ESC>hi
nmap <Leader><< i<%%><ESC>hi
nmap <Leader>o> o<%=%><ESC>hi
nmap <Leader>o< o<%%><ESC>hi

" ブックマーク
noremap <Leader>bm :BM<cr>
noremap <Leader>ba :BA<cr>

" *で次の検索結果に移動しない方法
nmap * *N

" ものぐさマッピング
noremap yp yyp
noremap yP yyP

noremap <Leader>{ i{}<ESC>i
noremap <Leader>( i()<ESC>i
nnoremap + :call ZoomIn()<cr>
nnoremap - :call ZoomOut()<cr>

" タブ移動設定
nnoremap tt gt
nnoremap TT gT
nnoremap tn :tabnew<cr>
nnoremap tc :tabclose<cr> 

" スペルチェック
nmap \spe :set spell<cr>
nmap \nspe :set nospell<cr>

" Window移動
nnoremap <C-H> <C-W>h
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l

" diff画面用
map <M-Up> [c
map <M-Down> ]c

let s:is_mac = (has('mac') || has('macunix') || has('gui_macvim') || system('uname') =~? '^darwin')

if s:is_mac
  vnoremap <C-Y> y:call system("pbcopy", getreg("\""))<CR>
  nnoremap <C-P> :call setreg("\"",system("pbpaste"))<CR>p
else
  " Windows風マッピング
  map <C-Y> "+y
  "nnoremap <C-N> <C-V>
  "map <C-V> "+p
  map <C-P> "+p
  cmap <C-V> <C-R>+
  vnoremap <C-C> "+y
endif

map <C-A> ggVG

" m_vimutilから移動 {{{
command! Date :r!date /t

function! StrGetElem(str, idx, ...)
	if a:idx < 0
		return ""
	endif
	let sep = a:0 > 0 ? a:1 : "\n"	
	let cnt = 0
	let len = strlen(a:str)
	let next = 0
	while next < len
		let prev = next
		let next = match(a:str, sep, next)
		if next == -1
			if cnt == a:idx
				return strpart(a:str, prev)
			endif
			break
		endif
		if cnt == a:idx
			return strpart(a:str, prev)
		endif
		let cnt = cnt + 1
		let next = next + 1
	endwhile
	return ""
endfunction

function! AddLast()
  let c_pos = line(".")
  let list = split(@", "\n")
  let listLen = len(list)
  if c_pos-1 + listLen > line("$") 
    let i = c_pos-1 + listLen - line("$")
    while i > 0
      call append("$", "")
      let i -= 1
    endwhile
  endif
  let i = 0
  while i < listLen
    let target = c_pos + i
    call setline(target, getline(target) . list[i])
    let i += 1 
  endwhile
endfunction

function! ShiftNum(count)
	  let targetL = getline(".")
	  let sPos = 0
	  while 1
		  let sPos = match(targetL, "\\d\\+", sPos)
		  if sPos == -1
			  break
		  endif
		  let matchedStr = matchstr(targetL, "\\d\\+", sPos)
		  let strLen = len(matchedStr)
		  let matchedStr = substitute(matchedStr, "^0*", "", "")
		  let newNum = matchedStr + a:count

		  let padStr = ""
		  let padLen = strLen - len(string(newNum))
		  let i = 0
		  while i < padLen
			  let padStr .= "0"
			  let i += 1
		  endwhile

		  let newStr = padStr . newNum

		  let targetL = strpart(targetL, 0, sPos) . newStr . strpart(targetL, sPos + strLen)
		  let sPos += len(newStr) 
	  endwhile
	  call setline(line("."), targetL)
endfunction

command! -nargs=0 SetLastLine :call AddLast()
command! -nargs=1 -range=% ShiftNum :<line1>,<line2>call ShiftNum(<args>)

command! A :call AltCSource()
function! AltCSource()
    let cfile = expand('%')
    if cfile =~ '\.cpp$'
        let target = substitute(cfile, '\.cpp$', '.h', '') 
    elseif cfile =~ '\.h$'
        let target = substitute(cfile, '\.h$', '.cpp', '') 
    else 
        return 
    endif
    if !filereadable(target) | return | endif
    :exe 'e '.target
endfunction

command! StoreCwd :let tmp_cwd = getcwd()
command! PutCwd :call append('.', tmp_cwd)
command! StoreWorkPath :let mn_work_path_tmp = expand('%:p').' '.line('.')
"command! StoreWorkPath :let mn_work_path_tmp = '<URL:file://' . substitute(expand('%:p'), '\', '/', 'g') . '#line=' . line('.') . '>'
command! PutBkWorkPath :call append('.', mn_work_path_tmp)
command! ClearSign :sign unplace *
command! GBuf :e [GrepResult]
command! SplitAltBuf :exe 'sp '.expand('#')
command! DiffAgainstAltBuf :execute 'vert diffsp '.bufname('#')
command! AddAllNum :echo AddAllNumFunc()

function! AddAllNumFunc()
    let tmp = 0
    for val in getline(line("^"), line("$"))
        let tmp += val
    endfor
    let @" = tmp
    return tmp
endfunction

command! -range UniPat :let @+ = UniPatFunc(<line1>, <line2>)

function! UniPatFunc(from, to)
    let tmp = ''
    for val in getline(a:from, a:to)
        if (match(val, '^\s*$') == -1)
            let tmp .= '\%(' . val . '\)\|'
        endif
    endfor
    let len = len(tmp)
    if len != 0
        let tmp = strpart(tmp, 0, len-2)
    endif
    let @" = tmp
    return tmp
endfunction

" ruby 正規表現版
command! -range UniPatRb :let @+ = UniPatRbFunc(<line1>, <line2>)

function! UniPatRbFunc(from, to)
    let tmp = ''
    for val in getline(a:from, a:to)
        if (match(val, '^\s*$') == -1)
            let tmp .= '(' . val . ')|'
        endif
    endfor
    let len = len(tmp)
    if len != 0
        let tmp = strpart(tmp, 0, len-1)
    endif
    let @" = tmp
    return tmp
endfunction

command! -range CommentOut :<line1>,<line2>call CommentOutFunc()
function! CommentOutFunc()
    if !exists('g:mn_comment_pat')
        let g:mn_comment_pat = '// '
    endif
    call setline('.', substitute(getline('.'), '\S', g:mn_comment_pat.'&', ''))
endfunction


" 二つのキーワードを相互に置換する。
" SwapWord {{{
function! SwapWord(...)
    if a:0 < 2 | return | endif
    let pat1 = a:1
    let pat2 = a:2
    let cline = getline('.')
    let posE = 0
    let pat1len = len(pat1)
    let pat2len = len(pat2)
    while 1
        let pat1pos = stridx(cline, pat1, posE) 
        let pat2pos = stridx(cline, pat2, posE)
        if pat1pos == -1 && pat2pos == -1
            break
        endif
        if pat2pos == -1 || (pat1pos != -1 && pat1pos <= pat2pos)
            let cline = strpart(cline, 0, pat1pos) . pat2 . strpart(cline, pat1pos + pat1len)
            let posE = pat1pos + pat2len
        elseif pat1pos == -1 || pat1pos > pat2pos
            let cline = strpart(cline, 0, pat2pos) . pat1 . strpart(cline, pat2pos + pat2len)
            let posE = pat2pos + pat1len
        else
            echo '来てはいけない場所に来てしまったようだ・・・'
        endif
    endwhile
    call setline('.', cline)
endfunction

command! -nargs=+ -range SwapWord :<line1>,<line2>call SwapWord(<f-args>)
" SwapWord }}}

command! -nargs=1 -complete=tag CppContDest :call CppContDect(<f-args>)
function! CppContDect(arg)
    let tab = '\t'
    if &expandtab
        let tab = repeat(' ', &ts)
    endif

    call append(line('.'), tab . 'virtual ~' . a:arg . '();')
    call append(line('.'), tab . a:arg . '();')
endfunction

command! -nargs=0 -range BoostArr :<line1>,<line2>s/\(\w\+\)\[\(\d\+\)\]/boost::array<\1, \2>/g

command! -nargs=0 -range AlignMember :<line1>,<line2>Align \w\+;

command! -nargs=+ -range MFHeaderToCpp :call MFAddClassScope(<f-args>, <line1>, <line2>)
function! MFAddClassScope(arg, ...)
    let lineS = line('.')
    let lineE = line('.')
    if a:0 > 0 
        let lineS = a:1
    endif
    if a:0 > 1 
        let lineE = a:2
    endif

    " NOTE: 返り値の型がboost::function<void ()>とかだとうまくいかないけど・・・
    silent! execute lineS . ',' . lineE . 's/\w\+\s*(/\=a:arg . "::" . submatch(0)'
    silent! execute lineS . ',' . lineE . 's/static\s*//'
    silent! execute lineS . ',' . lineE . 's/virtual\s*//'
    silent! execute lineS . ',' . lineE . 's/register\s*//'
    silent! execute lineS . ',' . lineE . 's/\s*=[^,)]*\([,)]\)/\1/'
    silent! execute lineS . ',' . lineE . 's/^\s*//'
    silent! execute lineS . ',' . lineE . 's/;/ {\r}\r/'
endfunction

command! -complete=file -nargs=? MSExplorer :call MSExplorer(<f-args>)
function! MSExplorer(...)
    if a:0 > 0
        call system("open " . a:1)
    else 
        call system("open " . expand("%:p:h"))
    endif
endfunction

" NOTE: $FIREFOX_PATH にfireFoxのパスを入れておくこと!
command! -complete=file -nargs=? FireFox :call FireFox(<f-args>)
function! FireFox(...)
    if a:0 > 0
        call system($FIREFOX_PATH . "\\firefox " . a:1)
    else 
        call system($FIREFOX_PATH . "\\firefox " . expand("%:p:h"))
    endif
endfunction

command! DelBlankLines :%g/^\s*$/d
command! TrimAllLines :call TrimAllLines()
function! TrimAllLines()
    :%s/^\s*//
    :%s/\s*$//
endfunction TrimAllLines
command! SerMBStr /[^[:print:][:cntrl:]]
command! Hatenize :%s/^\(\S\+\):\s*/*[\1]/
command! ConvProperties :%!native2ascii -reverse


function! Uniq(s, e)
    let lines = getline(a:s, a:e)
    let dict = {}
    for val in lines
        if val != ''
            let dict[val] = 1
        endif
    endfor
    exe a:s.','.a:e.'d' 
    call append(a:s-1, keys(dict))
endfunction
command! -range=% Uniq :call Uniq(<line1>, <line2>)

" [Key]\t[Field]の形式で記述されているテキストファイルを
" Key値に基づいて結合する。
" Key値が重複した場合、Field値の重複分は削除される。
function! CombineLstTbl(ls1, ls2)
    let d1 = {}
    let d2 = {}
    for r in a:ls1
        let k_v = split(r, '\t') 
        if len(k_v) < 2 | throw '不正なフォーマット:'.r | endif 
        let d1[k_v[0]] = k_v[1]
    endfor
    for r in a:ls2
        let k_v = split(r, '\t') 
        if len(k_v) < 2 | throw '不正なフォーマット:'.r | endif 
        let d2[k_v[0]] = k_v[1]
    endfor

    let rv = []
    for k in keys(d1)
        call add(rv, k ."\t". d1[k] ."\t". d2[k])
    endfor
    return rv
endfunction
function! CombineTxtTbl(...)
    if a:0 < 2 | return | endif
    if !filereadable(a:1) || !filereadable(a:2)
        throw 'ファイルオープンに失敗'
    endif
    call append('$', CombineLstTbl(readfile(a:1), readfile(a:2))) 
endfunction
command! -nargs=+ CombineTxtTbl :call CombineTxtTbl(<f-args>)

" 行またぎで前後に"
function! MultiLineBlock(ls, le, ...)
    if a:0 > 0
        let sign = a:1
    else
        let sign = '"'
    endif
    call setline(a:ls, sign . getline(a:ls))
    call setline(a:le, getline(a:le) . sign)
endfunction
command! -nargs=* -range Mlb :call MultiLineBlock(<line1>, <line2>, <f-args>)


command! HtmlInit :call append(".", HtmlInit())

function! HtmlInit() 
let list = []
call add(list, "<html>")
call add(list, "  <head>")
call add(list, "  </head>")
call add(list, "  <body>")
call add(list, "  </body>")
call add(list, "</html>")
return list
endfunction

function! RbEach(ls, le, start, end) 
    let list = []
    call add(list, "(" . a:start . ".." . a:end . ").each{|i| puts <<EOS")
    call extend(list, getline(a:ls, a:le))
    call add(list, "EOS")
    call add(list, "}")
    return split(system("ruby", join(list, "\n")), "\n")
endfunction
command! -nargs=+ -range RbEach :call append(".", RbEach(<line1>, <line2>, <f-args>))

" タブ・全角文字のハイライト設定 {{{

function! HiZenkaku()
    highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=darkgrey
    match ZenkakuSpace /　/
endfunction
command! HiZenkaku :call HiZenkaku()
function! NoHiZenkaku()
    highlight clear ZenkakuSpace
endfunction
command! NoHiZenkaku :call NoHiZenkaku()

function! HiTab()
    highlight TabWarn cterm=underline ctermfg=lightblue guibg=darkgrey
    match TabWarn /\t/
endfunction
command! HiTab :call HiTab()
function! NoHiTab()
    highlight clear TabWarn
endfunction
command! NoHiTab :call NoHiTab()

function! HiColon()
    highlight ColonWarn cterm=underline ctermfg=lightblue guifg=lightgreen
    match ColonWarn /:/
endfunction
command! HiColon :call HiColon()
function! NoHiColon()
    highlight clear ColonWarn
endfunction
command! NoHiColon :call NoHiColon()

" タブ・全角文字・':'のハイライト設定 }}}

" Javaのプロパティメソッド定義 {{{
function! GenJProps(s, e)
  let lines = getline(a:s, a:e)
  let fields = []
  let pat = '^\(\s*\)private\s\+\(\w\+\)\s\+\(\w\+\).*'
  for line in lines
    if line =~ pat
      call add(fields, {'indent': substitute(line, pat, '\1', ''), 'type': substitute(line, pat, '\2', ''), 'name': substitute(line, pat, '\3', '')})
    endif
  endfor
  let outlines = []
  for field in fields
    let indent = field['indent']
    let type = field['type']
    let name = field['name']
    let capitalName = toupper(name[0]) . name[1:-1]
    call add(outlines, indent . 'public ' . type . ' get' . capitalName . '() {')
    call add(outlines, indent . '    return ' . name . ';')
    call add(outlines, indent . '}')
    call add(outlines, '')
    call add(outlines, indent . 'public void set' . capitalName . '(' . type . ' ' . name . ') {')
    call add(outlines, indent . '    this.' . name . ' = ' . name . ';')
    call add(outlines, indent . '}')
  endfor
  call append(a:e, outlines)
endfunction
command! -range GenJProps :call GenJProps(<line1>, <line2>)
" Javaのプロパティメソッド定義 }}}

" m_vimutilから移動 }}}
command! Date :r!date /t
" vim7: fdm=marker
