# print.stamp_template(): prints template information [plain]

    Code
      print(template)
    Message
      
      -- Template: print_test --------------------------------------------------------
      
      -- Fields: --
      
      * copyright: Test 2025 (Required)
      * author: Test Author (Optional)
      
      -- Content: --
      
      Copyright: {{copyright}}
      Author: {{author}}

# print.stamp_template(): prints template information [ansi]

    Code
      print(template)
    Message
      
      [36m--[39m [1mTemplate: print_test[22m [36m--------------------------------------------------------[39m
      
      -- [1m[1mFields:[1m[22m --
      
      * copyright: Test 2025 (Required)
      * author: Test Author (Optional)
      
      -- [1m[1mContent:[1m[22m --
      
      Copyright[33m:[39m [33m{[39m[33m{[39mcopyright[33m}[39m[33m}[39m
      Author[33m:[39m [33m{[39m[33m{[39mauthor[33m}[39m[33m}[39m

# print.stamp_template(): prints template information [unicode]

    Code
      print(template)
    Message
      
      ── Template: print_test ────────────────────────────────────────────────────────
      
      ── Fields: ──
      
      • copyright: Test 2025 (Required)
      • author: Test Author (Optional)
      
      ── Content: ──
      
      Copyright: {{copyright}}
      Author: {{author}}

# print.stamp_template(): prints template information [fancy]

    Code
      print(template)
    Message
      
      [36m──[39m [1mTemplate: print_test[22m [36m────────────────────────────────────────────────────────[39m
      
      ── [1m[1mFields:[1m[22m ──
      
      • copyright: Test 2025 (Required)
      • author: Test Author (Optional)
      
      ── [1m[1mContent:[1m[22m ──
      
      Copyright[33m:[39m [33m{[39m[33m{[39mcopyright[33m}[39m[33m}[39m
      Author[33m:[39m [33m{[39m[33m{[39mauthor[33m}[39m[33m}[39m

# print.stamp_preview(): prints preview information [plain]

    Code
      print(preview)
    Message
      
      -- Preview for: test.R ---------------------------------------------------------
      
      -- Header to be inserted: --
      
      # Copyright (c) Test 2025
      # Author: Test Author
      
      -- Insertion point: --
      
      Beginning of file
      
      -- File properties: --
      
      * Encoding: UTF-8
      * Line ending: LF
      * Read-only: No

# print.stamp_preview(): prints preview information [ansi]

    Code
      print(preview)
    Message
      
      [36m--[39m [1mPreview for: test.R[22m [36m---------------------------------------------------------[39m
      
      -- [1m[1mHeader to be inserted:[1m[22m --
      
      [90m# Copyright (c) Test 2025[39m
      [90m# Author: Test Author[39m
      
      -- [1m[1mInsertion point:[1m[22m --
      
      Beginning of file
      
      -- [1m[1mFile properties:[1m[22m --
      
      * Encoding: UTF-8
      * Line ending: LF
      * Read-only: No

# print.stamp_preview(): prints preview information [unicode]

    Code
      print(preview)
    Message
      
      ── Preview for: test.R ─────────────────────────────────────────────────────────
      
      ── Header to be inserted: ──
      
      # Copyright (c) Test 2025
      # Author: Test Author
      
      ── Insertion point: ──
      
      Beginning of file
      
      ── File properties: ──
      
      • Encoding: UTF-8
      • Line ending: LF
      • Read-only: No

# print.stamp_preview(): prints preview information [fancy]

    Code
      print(preview)
    Message
      
      [36m──[39m [1mPreview for: test.R[22m [36m─────────────────────────────────────────────────────────[39m
      
      ── [1m[1mHeader to be inserted:[1m[22m ──
      
      [90m# Copyright (c) Test 2025[39m
      [90m# Author: Test Author[39m
      
      ── [1m[1mInsertion point:[1m[22m ──
      
      Beginning of file
      
      ── [1m[1mFile properties:[1m[22m ──
      
      • Encoding: UTF-8
      • Line ending: LF
      • Read-only: No

# print.stamp_language(): prints language information [plain]

    Code
      print(language)
    Message
      
      -- Language: print_lang --------------------------------------------------------
      
      -- File extensions: --
      
      pl, prl
      
      -- Comment style: --
      
      * Single line: #
      * Multi-line start: =begin
      * Multi-line end: =end

# print.stamp_language(): prints language information [ansi]

    Code
      print(language)
    Message
      
      [36m--[39m [1mLanguage: print_lang[22m [36m--------------------------------------------------------[39m
      
      -- [1m[1mFile extensions:[1m[22m --
      
      pl, prl
      
      -- [1m[1mComment style:[1m[22m --
      
      * Single line: #
      * Multi-line start: =begin
      * Multi-line end: =end

# print.stamp_language(): prints language information [unicode]

    Code
      print(language)
    Message
      
      ── Language: print_lang ────────────────────────────────────────────────────────
      
      ── File extensions: ──
      
      pl, prl
      
      ── Comment style: ──
      
      • Single line: #
      • Multi-line start: =begin
      • Multi-line end: =end

# print.stamp_language(): prints language information [fancy]

    Code
      print(language)
    Message
      
      [36m──[39m [1mLanguage: print_lang[22m [36m────────────────────────────────────────────────────────[39m
      
      ── [1m[1mFile extensions:[1m[22m ──
      
      pl, prl
      
      ── [1m[1mComment style:[1m[22m ──
      
      • Single line: #
      • Multi-line start: =begin
      • Multi-line end: =end

# print.stamp_dir_results(): prints directory results [plain]

    Code
      print(results)
    Message
      
      -- Directory Stamping Results: test_dir ----------------------------------------
      
      -- Action: modify --
      
      v 2 files successfully processed
      x 1 files had errors
      
      -- Errors: --
      
      * file3.R: Error message

# print.stamp_dir_results(): prints directory results [ansi]

    Code
      print(results)
    Message
      
      [36m--[39m [1mDirectory Stamping Results: test_dir[22m [36m----------------------------------------[39m
      
      -- [1m[1mAction: [1mmodify[1m[1m[22m --
      
      [32mv[39m 2 files successfully processed
      [31mx[39m 1 files had errors
      
      -- [1m[1mErrors:[1m[22m --
      
      * file3.R: Error message

# print.stamp_dir_results(): prints directory results [unicode]

    Code
      print(results)
    Message
      
      ── Directory Stamping Results: test_dir ────────────────────────────────────────
      
      ── Action: modify ──
      
      ✔ 2 files successfully processed
      ✖ 1 files had errors
      
      ── Errors: ──
      
      • file3.R: Error message

# print.stamp_dir_results(): prints directory results [fancy]

    Code
      print(results)
    Message
      
      [36m──[39m [1mDirectory Stamping Results: test_dir[22m [36m────────────────────────────────────────[39m
      
      ── [1m[1mAction: [1mmodify[1m[1m[22m ──
      
      [32m✔[39m 2 files successfully processed
      [31m✖[39m 1 files had errors
      
      ── [1m[1mErrors:[1m[22m ──
      
      • file3.R: Error message

# print.stamp_file_info(): prints file information [plain]

    Code
      print(file_info)
    Message
      
      -- File Information: test.R ----------------------------------------------------
      * Encoding: UTF-8
      * Line ending: LF
      * Read-only: No

# print.stamp_file_info(): prints file information [ansi]

    Code
      print(file_info)
    Message
      
      [36m--[39m [1mFile Information: test.R[22m [36m----------------------------------------------------[39m
      * Encoding: UTF-8
      * Line ending: LF
      * Read-only: No

# print.stamp_file_info(): prints file information [unicode]

    Code
      print(file_info)
    Message
      
      ── File Information: test.R ────────────────────────────────────────────────────
      • Encoding: UTF-8
      • Line ending: LF
      • Read-only: No

# print.stamp_file_info(): prints file information [fancy]

    Code
      print(file_info)
    Message
      
      [36m──[39m [1mFile Information: test.R[22m [36m────────────────────────────────────────────────────[39m
      • Encoding: UTF-8
      • Line ending: LF
      • Read-only: No

# print.stamp_update_preview(): prints update preview [plain]

    Code
      print(update_preview)
    Message
      
      -- Update Preview for: test.R --------------------------------------------------
      
      -- Updated fields: --
      
      * copyright: Test 2025
      * author: Test Author
      
      -- Header location: --
      
      Lines 1 to 3
      
      -- File properties: --
      
      * Encoding: UTF-8
      * Line ending: LF
      * Read-only: No

# print.stamp_update_preview(): prints update preview [ansi]

    Code
      print(update_preview)
    Message
      
      [36m--[39m [1mUpdate Preview for: test.R[22m [36m--------------------------------------------------[39m
      
      -- [1m[1mUpdated fields:[1m[22m --
      
      * copyright: Test 2025
      * author: Test Author
      
      -- [1m[1mHeader location:[1m[22m --
      
      Lines 1 to 3
      
      -- [1m[1mFile properties:[1m[22m --
      
      * Encoding: UTF-8
      * Line ending: LF
      * Read-only: No

# print.stamp_update_preview(): prints update preview [unicode]

    Code
      print(update_preview)
    Message
      
      ── Update Preview for: test.R ──────────────────────────────────────────────────
      
      ── Updated fields: ──
      
      • copyright: Test 2025
      • author: Test Author
      
      ── Header location: ──
      
      Lines 1 to 3
      
      ── File properties: ──
      
      • Encoding: UTF-8
      • Line ending: LF
      • Read-only: No

# print.stamp_update_preview(): prints update preview [fancy]

    Code
      print(update_preview)
    Message
      
      [36m──[39m [1mUpdate Preview for: test.R[22m [36m──────────────────────────────────────────────────[39m
      
      ── [1m[1mUpdated fields:[1m[22m ──
      
      • copyright: Test 2025
      • author: Test Author
      
      ── [1m[1mHeader location:[1m[22m ──
      
      Lines 1 to 3
      
      ── [1m[1mFile properties:[1m[22m ──
      
      • Encoding: UTF-8
      • Line ending: LF
      • Read-only: No

