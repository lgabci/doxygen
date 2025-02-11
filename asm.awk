BEGIN {
  in_comm = 0                   # in comment
  in_comm_le = 0                # line comment
  last_label = ""
}

{
  line = ""
  for (i = 1; i <= NF; i ++) {
    if ($i ~ /^\/\*/) {
      in_comm ++;
    } else if ($i ~ /^\/\//) {
      in_comm ++;
      in_comm_le = 1
    }

    if (in_comm > 0) {          # in comment
      if (i == 1) {
        if ($0 ~ /^\#/) {
          line = $0
          sub(/^\#/, "*/", line)
          line = line "/*"
          break
        }
      }
      line = line " " $i
    }
    else {                      # not in comment
      if ($i ~ /:$/) {
        last_label = $i
        sub(/:$/, "", last_label)
      }

      if ($i == ".set") {
        tmp = $(i + 1)
        sub(/,$/, "", tmp)
        line = line " #define " tmp " " $(i + 2)
        i = i + 2
      }
      else if ($i == ".long" || $i == ".word" || $i == ".byte") {
        if ($i == ".long") {
          dtype = "uint32_t"
        }
        else if ($i == ".word") {
          dtype = "uint16_t"
        }
        else if ($i == ".byte") {
          dtype = "uint8_t"
        }
        line = line " " dtype " " last_label " = "
        last_label = ""

        j = 0;
        split("", values)
        while (i ++ < NF) {
          if ($i ~ /^\/\*/) {
            i --
            break
          }
          values[j] = $i
          j ++;
        }
        if (j > 1) {
          line = line "{"
          for (k = 0; k < j; k ++) {
            line = line (k > 0 ? " " : "") values[k];
          }
          line = line "};"
        }
        else {
          line = line " " values[0] ";"
        }
      }
      else if ($i == ".string") {
        line = line " char *" last_label " ="
        last_label = ""
        do {
          i ++
          line = line " " $i
        } while ($i !~ /"$/)    # "
      }
      else if ($i == ".lcomm") {
        tmp = $(i + 1)
        sub(/,$/, "", tmp)
        line = line " uint8_t " tmp "[" $(i + 2) "];"
        i = i + 2
      }
      else {
        $i = ""
      }
    }

    if ($i ~ /\*\/$/) {
      in_comm --;
    }
  }
  if (in_comm_le > 0) {
    in_comm --;
    in_comm_le = 0;
  }

  sub(/^[ \t]+/, "", line)
  sub(/[ \t]+$/, "", line)
  print(line)
}
