# MPL Standard Library

This repository contains a collection of algorithms and tools to help with common tasks during development using the MPL Programming Language.

## Documentation
Documentation is a work in progress.

- [algebra](#algebra)
  - [Vector](#vector)
  - [Matrix](#matrix)
  - [getColCount](#getcolcount)
  - [getRowCount](#getrowcount)
  - [angle](#angle)
  - [cosSin](#cossin)
  - [toColumn](#tocolumn)
  - [multiply](#multiply)
  - [divide](#divide)
  - [dot](#dot)
  - [cross](#cross)
  - [squaredLength](#squaredlength)
  - [length](#length)
  - [unit](#unit)
  - [unitChecked](#unitchecked)
  - [neg](#neg)
  - [cast](#cast)
  - [trans](#trans)
  - [lerp](#lerp)
  - [rotationMatrix](#rotationmatrix)
  - [det](det)
  - [adj](#adj)
  - [inv](#inv)
  - [solve](#solve)
  - [operations](#operations)

### algebra

#### Vector
Arguments: `elements_type` `length`
Return values: created vector
Example:
```
v: Real32 3 Vector;
```

#### vector?
###### check if input is vector or not
Arguments: `v`: object
Return values:
`TRUE` if v is `Vector`
`FALSE` otherwise

#### Matrix
Arguments: `columnCount` `rowCount`
Return values: created matrix
Example:
```
v: Real32 3 3 Matrix;
```

#### matrix? 
###### check if input is matrix or not
Arguments:  `v`: object
Return values:
`TRUE` if v is `Matrix`
`FALSE` otherwise

#### getColCount
Arguments: `m`: `Matrix`
Return values: columns count

#### getRowCount
Arguments: `m`: `Matrix`
Return values: rows count

#### angle
Arguments: `v`: `Vector` of dimension 2 (x, y)
Return values: `atan2(x, y)`

#### cosSin
Arguments: `angle`: real number
Return values: builtin-list `(cos(angle) sin(angle))`

#### toColumn
###### translate vector to column
Arguments: `v`: `Vector`
Return values: `v` presented as column
Example:
```
a: (1 2 3 4) toColumn; # a = ((1) (2) (3) (4))
```

#### multiply
###### multiplies vectors element by element
Arguments: `v1: Vector`, `v2: Vector` such that  length(v1) = length(v2)
Return values: `v: Vector` such that `v[i] = v1[i] * v2[i]`
Example:
```
a: (2 4 6 8) (1 2 3 4) divide; # a = (2 8 18 32)
```

#### divide
###### divides vectors element by element
Arguments: `v1: Vector`, `v2: Vector` such that  length(v1) = length(v2)
Return values: `v: Vector` such that `v[i] = v1[i] / v2[i]`
Example:
```
a: (2 4 6 8) (1 2 3 4) divide; # a = (2 2 2 2)
```

#### dot
###### a scalar multiplication of 2 vectors
Arguments: `v1: Vector`, `v2: Vector` such that  length(v1) = length(v2)
Return values: a scalar multiplication of `v1` and `v2`
Example:
```
a: (1 2 3) (4 5 6) cross; # a = 32
```
#### cross
###### a cross product of 2 vectors
Arguments: `v1: Vector`, `v2: Vector` such that  length(v1) = length(v2) = 3
Return values: `v: Vector` `v = v1 x v2` -- cross product
Example:
```
a: (1 2 3) (4 5 6) cross; # a = (-3 6 -3)
```
#### squaredLength
###### square of vector length
Arguments: `v: Vector`
Return values: a scalar multiplication of `v` and `v` (`v v dot`)
Example:
```
a: (1 2 3) squaredLength; # a = 14
```

#### length
###### vector length
Arguments: `v: Vector of Real values`
Return values: a scalar multiplication of `v` and `v` (`v v dot sqrt`)
Example:
```
a: (0.0r32 3.0r32 4.0r32) length; # a = 5
```

#### unit
###### Calculates unit vector
Arguments: `v: Vector of Real values`
Return values: a normalized vector `v`
Example:
```
a: (0.0r32 3.0r32 4.0r32) unit; # a = (0.0r32 0.6r32 0.8r32)
```
```
a: (0.0r32 0.0r32 0.0r32) unit; # fail
```
#### unitChecked
###### Same as unit, but with a check for zero length
Arguments: `v: Vector of Real values`
Return values: a normalized vector `v`
Example:
```
a: (0.0r32 3.0r32 4.0r32) unit; # a = (0.0r32 0.6r32 0.8r32)
```
```
a: (0.0r32 0.0r32 0.0r32) unit; # a = (1.0r32 0.0r32 0.0r32)
```
#### neg
###### Negate all vector elements
Arguments: `v: Vector`
Return values: a negated element by element vector `v`
Example:
```
a: (1 -2 3) neg; # a = (-1 2 -3)
```

#### cast
###### Cast all elements of first vector to second vector element types
Arguments: `v1: Vector`, `v2: Vector`
Return values: `v: Vector` casted vector
Example:
```
a: (1 2 3) (4 5.0r32 6.0r64) cast; # a = (1 2.0r32 3.0r64)
```
#### trans
###### transpose the matrix (or vector)
Arguments: `v: Vector` or `m: Matrix`
Return values: transpose matrix (or vector)

#### lerp
Arguments: `v0, v1, f` -- numbers
Return values: `(v1 - v0) * f + v0`

#### rotationMatrix
###### Calculates rotation matrix for `R^2`
Arguments: `angle: Real32`
Return values: rotation matrix
`
(cos(angle) sin(angle))
(-sin(angle) cos(angle))
`

#### det
###### Calculates determinant of matrix
Arguments: `m`: `Matrix` such that `getColCount(m) = getRowCount(m)` and `getRowCount(m) <= 4`
Return values: determinant
#### adj
###### Calculates adjugate matrix
Arguments: `m`: `Matrix` such that `getColCount(m) = getRowCount(m)` and `getRowCount(m) <= 4`
Return values: adjugate matrix
#### inv
###### Calculates inverse matrix
Arguments: `m`: `Matrix` such that `getColCount(m) = getRowCount(m)` and `getRowCount(m) <= 4`
Return values: inverse matrix

#### solve
###### Solves linear equations system
Arguments: `m: Matrix`, `v: Vector` such that 
* `det(m) != 0`
* `getColCount(m) = getRowCount(m) = length(v)`
* `getRowCount(m) <= 4`

Return values: `v: Vector` -- solution of the given system
Example:
```
a: ((1.0r32 2.0r32) (3.0r32 4.0r32)) (5.0r32 6.0r32) solve; # a = (-4.0r32 4.5r32)
```

#### operations
* `+`
Arguments: `v1: Vector`, `v2: Vector` such that  length(v1) = length(v2)
Return values: `v1 + v2`
* `-`
Arguments: `v1: Vector`, `v2: Vector` such that  length(v1) = length(v2)
Return values: `v1 - v2`
* `=`
Arguments: 
`v1: Vector`, `v2: Vector` such that  length(v1) = length(v2)
or
`v1: Vector`, `v2: Matrix` such that  length(v2) = 1 and length(v1) = length(v2[0])
Return values: 
`TRUE` if `v1` equals `v2`
`FALSE` otherwise
* `/`
Arguments:  `vector: Vector`, `value`
* `*`
Arguments: 
`vector: Vector`, `value`
or
`value`, `vector: Vector`
or
`m1: Matrix`, `m2: Matrix`
or
`v1: Vector`, `m: Matrix` such that  length(v1) = getRowCount(m)
* `|` "down concatenation"
Arguments: 
`m1: Matrix`, `m2: Matrix`
or
`m1: Matrix`, `m2: Vector`
Return values: concatenated matrix `m1|m2` (m2 concatenated at the right m1)
* `&` "right concatenation"
Arguments: 
`m1: Vector`, `m2: Vector`
or
`m1: Matrix`, `m2: Matrix`
Return values: concatenated matrix `m1|m2` (m2 concatenated at the right m1)
