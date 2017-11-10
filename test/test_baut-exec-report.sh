#!/usr/bin/env bash

test_exec_report_RDY() {
  code="#:RDY;1\t2"
  eval2 "printf '%b\n' '$code' | baut report -f tap"
  [[ "$result" =~ "1..2" ]]
}

test_exec_report_OK() {
  code="#:RDY;1\t1\n"
  code+="#:STR;hoge.baut\thoge.sh\t1\n"
  code+="#:STRT;test_hoge\n"
  code+="#:OK;test_hoge\n"
  code+="#:ENDT;test_hoge\t0\n"
  code+="#:END;hoge.baut\thoge.sh\n"

  eval2 "printf '%b' '$code' | baut report -f oneline --no-color"
  [[ "${lines[0]}" =~ "1 file, 1 test" ]]
  [[ "${lines[1]}" =~ "#1 hoge.sh" ]]
  [[ "${lines[2]}" =~ "o test_hoge" ]]
}

test_exec_report_ERR() {
  code="#:RDY;1\t1\n"
  code+="#:STR;hoge.baut\thoge.sh\t1\n"
  code+="#:STRT;test_hoge\n"
  code+="#:ERR;test_hoge\t1\n"
  code+="#:ENDT;test_hoge\t0\n"
  code+="#:END;hoge.baut\thoge.sh\n"

  eval2 "printf '%b' '$code' | baut report -f oneline --no-color"
  [[ "${lines[0]}" =~ "1 file, 1 test" ]]
  [[ "${lines[1]}" =~ "#1 hoge.sh" ]]
  [[ "${lines[2]}" =~ "x test_hoge" ]]
}

test_exec_report_SKP() {
  code="#:RDY;1\t1\n"
  code+="#:STR;hoge.baut\thoge.sh\t1\n"
  code+="#:STRT;test_hoge\n"
  code+="#:SKP;test_hoge\n"
  code+="#:ENDT;test_hoge\t0\n"
  code+="#:END;hoge.baut\thoge.sh\n"

  eval2 "printf '%b' '$code' | baut report -f oneline --no-color"
  [[ "${lines[0]}" =~ "1 file, 1 test" ]]
  [[ "${lines[1]}" =~ "#1 hoge.sh" ]]
  [[ "${lines[2]}" =~ "~ test_hoge" ]]
}

test_exec_report_DPR() {
  code="#:RDY;1\t1\n"
  code+="#:STR;hoge.baut\thoge.sh\t1\n"
  code+="#:STRT;test_hoge\n"
  code+="#:DPR;test_hoge\n"
  code+="#:OK;test_hoge\n"
  code+="#:ENDT;test_hoge\t0\n"
  code+="#:END;hoge.baut\thoge.sh\n"

  eval2 "printf '%b' '$code' | baut report -f oneline --no-color"
  [[ "${lines[0]}" =~ "1 file, 1 test" ]]
  [[ "${lines[1]}" =~ "#1 hoge.sh" ]]
  [[ "${lines[2]}" =~ "o test_hoge" ]]
  [[ "${lines[2]}" =~ "# DEPRECATED" ]]
}

test_exec_report_ERR0() {
  code="#:RDY;1\t1\n"
  code+="#:STR;hoge.baut\thoge.sh\t1\n"
  code+="#:STRT;test_hoge\n"
  code+="#:ERR0;test_hoge\n"
  code+="#:ENDT;test_hoge\t0\n"
  code+="#:END;hoge.baut\thoge.sh\n"

  eval2 "printf '%b' '$code' | baut report -f oneline --no-color"
  [[ "${lines[0]}" =~ "1 file, 1 test" ]]
  [[ "${lines[1]}" =~ "#1 hoge.sh" ]]
  [[ "${lines[2]}" =~ "!ERROR test_hoge" ]]
}

test_exec_report_STP() {
  code="#:RDY;1\t1\n"
  code+="#:STR;hoge.baut\thoge.sh\t1\n"
  code+="#:STRT;test_hoge\n"
  code+="#:STP;hoge.baut\thoge.sh\ttest_hoge\n"

  eval2 "printf '%b' '$code' | baut report -f oneline --no-color"
  [[ "${lines[0]}" =~ "1 file, 1 test" ]]
  [[ "${lines[1]}" =~ "#1 hoge.sh" ]]
  [[ "${lines[2]}" =~ "Error detected in hoge.sh#test_hoge" ]] || fail "$result"
}
