scriptencoding utf-8

" Despite my avoidance of the abbreviated forms of commands elsewhere, I use
" `dig` here due to the sheer volume of those commands that this script
" contains.

" Digraphs are categorized by Unicode block.

" Reminder: low-lines aren’t allowed as the first characters of digraphs.

"{{{ 0080–00FF — Latin-1 Supplement
dig  s/ 167   " U+00A7 § SECTION SIGN (also ^KSE)
dig  xx 215   " U+00D7 × MULTIPLICATION SIGN (also ^K*X, ^K/\)
"}}}
"{{{ 0180–024F — Latin Extended-B
dig  fn 402   " U+0192 ƒ LATIN SMALL LETTER F WITH HOOK
"}}}
"{{{ 2000–206F — General Punctuation
dig  h- 8208  " U+2010 ‐ HYPHEN (also ^K-1)
dig  .- 8209  " U+2011 ‑ NON-BREAKING HYPHEN
dig  f- 8210  " U+2012 ‒ FIGURE DASH
dig  n- 8211  " U+2013 – EN DASH (also ^K-N)
dig  m- 8212  " U+2014 — EM DASH (also ^K-M)
dig  q- 8213  " U+2015 ― HORIZONTAL BAR (quotation dash; also ^K-3)
dig  '[ 8216  " U+2018 ‘ LEFT SINGLE QUOTATION MARK (also ^K'6)
dig  '] 8217  " U+2019 ’ RIGHT SINGLE QUOTATION MARK (also ^K'9)
dig \"[ 8220  " U+201C “ LEFT DOUBLE QUOTATION MARK (also ^K"6)
dig \"] 8221  " U+201D ” RIGHT DOUBLE QUOTATION MARK (also ^K"9)
dig  ** 8226  " U+2022 • BULLET
dig  ./ 8230  " U+2026 … HORIZONTAL ELLIPSIS
dig  ?! 8253  " U+203D ‽ INTERROBANG
"}}}
"{{{ 2100—214F — Letterlike Symbols
"{{{ Mathematical symbols from the Hebrew alphabet
" The Hebrew letters have (by default) the same digraphs, except with plus
" signs (‘+’) rather than number signs (‘#’).
dig  A# 8501  " U+2135 ℵ ALEF SYMBOL
dig  B# 8502  " U+2136 ℶ BET SYMBOL
dig  G# 8503  " U+2137 ℷ GIMEL SYMBOL
dig  D# 8504  " U+2138 ℸ DALET SYMBOL
"}}}
"}}}
"{{{ 2200–22FF — Mathematical Operators
dig  ~~ 8776  " U+2248 ≈ ALMOST EQUAL TO (also ^K?2)
dig  := 8788  " U+2254 ≔ COLON EQUALS
dig  =: 8789  " U+2255 ≕ EQUALS COLON
"}}}
"{{{ 2300–23FF — Miscellaneous Technical
dig  Z~ 8961  " U+2301 ⌁ ELECTRIC ARROW
dig  KB 9000  " U+2328 ⌨ KEYBOARD
"}}}
"{{{ 2600–26FF — Miscellaneous Symbols
dig  XX 9747  " U+2613 ☓ SALTIRE
dig  :( 9785  " U+2639 ☹ WHITE FROWNING FACE
dig  :) 9786  " U+263A ☺ WHITE SMILING FACE
dig  (: 9787  " U+263B ☻ BLACK SMILING FACE
dig  <3 9829  " U+2665 ♥ BLACK HEART SUIT
dig  Z! 9889  " U+26A1 ⚡ HIGH VOLTAGE SIGN
"}}}
"{{{ 2700–27BF — Dingbats
dig  Cc 10003 " U+2713 ✓ CHECK MARK (also ^KOK)
dig  CC 10004 " U+2714 ✔ HEAVY CHECK MARK
dig  mx 10005 " U+2715 ✕ MULTIPLICATION X
dig  mX 10006 " U+2716 ✖ HEAVY MULTIPLICATION X
dig  Cx 10007 " U+2717 ✗ BALLOT X
dig  CX 10008 " U+2718 ✘ HEAVY BALLOT X
"}}}
"{{{ 27C0–27EF — Miscellaneous Mathematical Symbols-A
dig  <[ 10216 " U+27E8 ⟨ MATHEMATICAL LEFT ANGLE BRACKET
dig  >] 10217 " U+27E9 ⟩ MATHEMATICAL RIGHT ANGLE BRACKET
"}}}
"{{{ 2E00–2E7F — Supplemental Punctuation
dig  !? 11800 " U+2E18 ⸘ INVERTED INTERROBANG
dig  :- 11802 " U+2E1A ⸚ HYPHEN WITH DIAERESIS (looks like a :| emoticon)
dig  [^ 11810 " U+2E22 ⸢ TOP LEFT HALF BRACKET
dig  ]^ 11811 " U+2E23 ⸣ TOP RIGHT HALF BRACKET
dig  [v 11812 " U+2E24 ⸤ BOTTOM LEFT HALF BRACKET (begin citation reference)
dig  ]v 11813 " U+2E25 ⸥ BOTTOM RIGHT HALF BRACKET (end citation reference)
dig  (( 11816 " U+2E28 ⸨ LEFT DOUBLE PARENTHESIS
dig  )) 11817 " U+2E29 ⸩ RIGHT DOUBLE PARENTHESIS
dig  x- 11834 " U+2E3A ⸺ TWO-EM DASH (omission dash)
dig  X- 11835 " U+2E3B ⸻ THREE-EM DASH
"}}}

" vim: syntax=vimdigraphs foldmethod=marker foldlevel=1
