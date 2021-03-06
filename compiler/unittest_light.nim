# note: consider merging tests/assert/testhelper.nim here.

proc mismatch*[T](lhs: T, rhs: T): string =
  ## Simplified version of `unittest.require` that satisfies a common use case,
  ## while avoiding pulling too many dependencies. On failure, diagnostic
  ## information is provided that in particular makes it easy to spot
  ## whitespace mismatches and where the mismatch is.
  proc replaceInvisible(s: string): string =
    for a in s:
      case a
      of '\n': result.add "\\n\n"
      else: result.add a

  proc quoted(s: string): string = result.addQuoted s

  result.add "\n"
  result.add "lhs:{\n" & replaceInvisible(
      $lhs) & "}\nrhs:{\n" & replaceInvisible($rhs) & "}\n"
  when compiles(lhs.len):
    if lhs.len != rhs.len:
      result.add "lhs.len: " & $lhs.len & " rhs.len: " & $rhs.len & "\n"
    when compiles(lhs[0]):
      var i = 0
      while i < lhs.len and i < rhs.len:
        if lhs[i] != rhs[i]: break
        i.inc
      result.add "first mismatch index: " & $i & "\n"
      if i < lhs.len and i < rhs.len:
        result.add "lhs[i]: {" & quoted($lhs[i]) & "} rhs[i]: {" & quoted(
            $rhs[i]) & "}"
      result.add "lhs[0..<i]:{\n" & replaceInvisible($lhs[
          0..<i]) & "}\nrhs[0..<i]:{\n" & replaceInvisible($rhs[0..<i]) & "}"

proc assertEquals*[T](lhs: T, rhs: T) =
  when false: # can be useful for debugging to see all that's fed to this.
    echo "----" & $lhs
  doAssert lhs==rhs, mismatch(lhs, rhs)
