/*
 * Utils - part of plain javascript wallet app for Snail tokens 🐌
 *
 * (c) Takeshi Kodo, under the MIT License (MIT)
 */

// Imports 
import { default as BN } from 'bn.js'

// Constants
const E18 = new BN(Math.ceil(1e18).toString())


export function assert(condition, message) {
    if (!condition) {
        throw message || "Assertion failed";
    }
}

export function isNumber(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}

export function BNfmt(value, pad) {
  if (!BN.isBN(value)) {
    if (isNumber(value)) {
      value = value.toString()
    }
    value = new BN(value)
  }
  let s = value.toString()
  while (s.length < (pad || 19)) {s = "0" + s;}
  s = s.slice(0, s.length - 18) + "." + s.slice(-18)
  return s
}

export function BNe18(value) {
  return new BN(value).mul(E18)
}

export function BNparse(value) {
  let r
  if (isNumber(value)) {
    value = value.toString()
  }
  let s = value
  let p = s.indexOf(".")
  if (p >= 0) {
    let m = (p > 0) ? s.slice(0, p) : 0
    let f = s.slice(p+1, 20)
    while (f.length < 18) {f += "0";}
    r = (new BN(m)).imul(E18)
    r = r.iadd(new BN(f))
  } else {
    r = (new BN(s)).imul(E18)
  }
  return r
}
