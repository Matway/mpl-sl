; Copyright (C) Matway Burkow
;
; This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
; The content is for demonstration purposes only.
; It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
; By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

define i8 @atomicExchangeN8Acquire(i8* %ref, i8 %value) {
  %old = atomicrmw xchg i8* %ref, i8 %value acquire
  ret i8 %old
}

define i16 @atomicExchangeN16Acquire(i16* %ref, i16 %value) {
  %old = atomicrmw xchg i16* %ref, i16 %value acquire
  ret i16 %old
}

define i32 @atomicExchangeN32Acquire(i32* %ref, i32 %value) {
  %old = atomicrmw xchg i32* %ref, i32 %value acquire
  ret i32 %old
}

define i64 @atomicExchangeN64Acquire(i64* %ref, i64 %value) {
  %old = atomicrmw xchg i64* %ref, i64 %value acquire
  ret i64 %old
}

define i8 @atomicExchangeN8Release(i8* %ref, i8 %value) {
  %old = atomicrmw xchg i8* %ref, i8 %value release
  ret i8 %old
}

define i16 @atomicExchangeN16Release(i16* %ref, i16 %value) {
  %old = atomicrmw xchg i16* %ref, i16 %value release
  ret i16 %old
}

define i32 @atomicExchangeN32Release(i32* %ref, i32 %value) {
  %old = atomicrmw xchg i32* %ref, i32 %value release
  ret i32 %old
}

define i64 @atomicExchangeN64Release(i64* %ref, i64 %value) {
  %old = atomicrmw xchg i64* %ref, i64 %value release
  ret i64 %old
}

define i8 @atomicLoadN8Acquire(i8* %ref) {
  %value = load atomic i8, i8* %ref acquire, align 1
  ret i8 %value
}

define i16 @atomicLoadN16Acquire(i16* %ref) {
  %value = load atomic i16, i16* %ref acquire, align 2
  ret i16 %value
}

define i32 @atomicLoadN32Acquire(i32* %ref) {
  %value = load atomic i32, i32* %ref acquire, align 4
  ret i32 %value
}

define i64 @atomicLoadN64Acquire(i64* %ref) {
  %value = load atomic i64, i64* %ref acquire, align 8
  ret i64 %value
}

define i8 @atomicOrN8Acquire(i8* %ref, i8 %value) {
  %old = atomicrmw or i8* %ref, i8 %value acquire
  ret i8 %old
}

define i16 @atomicOrN16Acquire(i16* %ref, i16 %value) {
  %old = atomicrmw or i16* %ref, i16 %value acquire
  ret i16 %old
}

define i32 @atomicOrN32Acquire(i32* %ref, i32 %value) {
  %old = atomicrmw or i32* %ref, i32 %value acquire
  ret i32 %old
}

define i64 @atomicOrN64Acquire(i64* %ref, i64 %value) {
  %old = atomicrmw or i64* %ref, i64 %value acquire
  ret i64 %old
}

define i8 @atomicOrN8Release(i8* %ref, i8 %value) {
  %old = atomicrmw or i8* %ref, i8 %value release
  ret i8 %old
}

define i16 @atomicOrN16Release(i16* %ref, i16 %value) {
  %old = atomicrmw or i16* %ref, i16 %value release
  ret i16 %old
}

define i32 @atomicOrN32Release(i32* %ref, i32 %value) {
  %old = atomicrmw or i32* %ref, i32 %value release
  ret i32 %old
}

define i64 @atomicOrN64Release(i64* %ref, i64 %value) {
  %old = atomicrmw or i64* %ref, i64 %value release
  ret i64 %old
}

define void @atomicStoreN8Release(i8* %ref, i8 %value) {
  store atomic i8 %value, i8* %ref release, align 1
  ret void
}

define void @atomicStoreN16Release(i16* %ref, i16 %value) {
  store atomic i16 %value, i16* %ref release, align 2
  ret void
}

define void @atomicStoreN32Release(i32* %ref, i32 %value) {
  store atomic i32 %value, i32* %ref release, align 4
  ret void
}

define void @atomicStoreN64Release(i64* %ref, i64 %value) {
  store atomic i64 %value, i64* %ref release, align 8
  ret void
}

define i8 @atomicXorN8Acquire(i8* %ref, i8 %value) {
  %old = atomicrmw xor i8* %ref, i8 %value acquire
  ret i8 %old
}

define i16 @atomicXorN16Acquire(i16* %ref, i16 %value) {
  %old = atomicrmw xor i16* %ref, i16 %value acquire
  ret i16 %old
}

define i32 @atomicXorN32Acquire(i32* %ref, i32 %value) {
  %old = atomicrmw xor i32* %ref, i32 %value acquire
  ret i32 %old
}

define i64 @atomicXorN64Acquire(i64* %ref, i64 %value) {
  %old = atomicrmw xor i64* %ref, i64 %value acquire
  ret i64 %old
}

define i8 @atomicXorN8Release(i8* %ref, i8 %value) {
  %old = atomicrmw xor i8* %ref, i8 %value release
  ret i8 %old
}

define i16 @atomicXorN16Release(i16* %ref, i16 %value) {
  %old = atomicrmw xor i16* %ref, i16 %value release
  ret i16 %old
}

define i32 @atomicXorN32Release(i32* %ref, i32 %value) {
  %old = atomicrmw xor i32* %ref, i32 %value release
  ret i32 %old
}

define i64 @atomicXorN64Release(i64* %ref, i64 %value) {
  %old = atomicrmw xor i64* %ref, i64 %value release
  ret i64 %old
}
