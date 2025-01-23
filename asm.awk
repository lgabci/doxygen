BEGIN {
  in_comm = 0                   # in comment
}

{
  for (i = 1; i <= NF; i ++) {
    if (in_comm) {              # in comment
      if ($i ~ /\*\/$/) {
        in_comm = 0;
      }
    }
    else {                      # not in comment
      if ($i ~ /^\/\*/) {
        in_comm = 1;
      }
      else if ($i == ".set") {
        $i = "#define"
        i ++
        sub(/,$/, "", $i)
        i ++
        if ($i == ",") {
          $i = ""
          i ++
        }
      }
      else if ($i ~ ":$") {
        $i = "int " $i
      }
      else {
        $i = ""
      }
    }
  }

  print($0, "X")
}
