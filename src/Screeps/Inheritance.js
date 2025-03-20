
export function downcastImpl(p, a, just, nothing) {
  if (a instanceof p) {
    return just(a);
  } else {
    return nothing;
  }
}