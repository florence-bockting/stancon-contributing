# Writing a Stan Math function

The library-specific C++ patterns a reviewer will expect. Condensed from the
[Math contributor help pages](https://github.com/stan-dev/math/tree/develop/doxygen/contributor_help_pages);
read `getting_started.md` and `common_pitfalls.md` there in full before a first
contribution.

## Contents

- [The shape of a new function](#the-shape-of-a-new-function)
- [1. require_ type traits](#1-require_-type-traits)
- [2. to_ref for Eigen expressions](#2-to_ref-for-eigen-expressions)
- [3. value_type_t and friends](#3-value_type_t-and-friends)
- [4. coeff and coeffRef](#4-coeff-and-coeffref)
- [Adding a distribution](#adding-a-distribution)

## The shape of a new function

A worked example: a dot product of a vector with itself, in `prim/fun`. The four
numbered lines are the Math-specific parts.

```cpp
// stan/math/prim/fun/dot_self.hpp
template <typename EigVec, require_eigen_vector_t<EigVec>* = nullptr> // (1)
inline value_type_t<EigVec> dot_self(const EigVec& x) {
  const auto& x_ref = to_ref(x);                                      // (2)
  value_type_t<EigVec> sum_x = 0.0;                                   // (3)
  for (int i = 0; i < x.size(); ++i) {
    sum_x += x_ref.coeff(i) * x_ref.coeff(i);                         // (4)
  }
  return sum_x;
}
```

A real `dot_self()` would call `x.squaredNorm()`. The unrolled version is here
because it exposes the four patterns.

## 1. `require_` type traits

Functions in `prim` take general template parameters so they accept Eigen
**expression templates**, but they must still be restricted to sensible types.
Without a constraint, the function above would happily accept an
`Eigen::MatrixXd`.

```cpp
template <typename EigVec, require_eigen_vector_t<EigVec>* = nullptr>
```

The odd-looking `void*` defaulted to `nullptr` is the SFINAE mechanism: a
satisfied `require_` yields `void`, so the parameter becomes `void* = nullptr`
and the compiler ignores it; an unsatisfied one removes the overload from the
candidate set. Conceptually it is a pre-C++20 `requires` clause.

The library already defines a `require_` for most types you will need. See
`require_meta` in the contributor guide rather than writing your own.

## 2. `to_ref` for Eigen expressions

Because functions accept expressions, `x` may not be a concrete matrix. Calling
`.coeff()` on an expression is either a compile error or silently recomputes the
expression on every access.

`to_ref()` resolves this: it evaluates expressions that compute something, and
passes through expressions that are only a view or slice.

```cpp
const auto& x_ref = to_ref(x);
```

**Use `const auto&`, not `auto`.** C++ lifetime-extension rules make the
reference safe, and `auto` would copy when `to_ref()` returns a concrete matrix.

Two cases that go wrong without it:

```cpp
// Compile error: Eigen forbids coefficient access on a product expression
dot_self(A_mat * A_vec);

// Compiles, but evaluates the elementwise product twice per iteration
dot_self(A_vec1.array() * A_vec2.array());
```

versus one that must *not* be evaluated:

```cpp
// A view into an existing vector; to_ref keeps it as Eigen::Block, no copy
dot_self(A.segment(1, 5));
```

## 3. `value_type_t` and friends

Type traits for querying containers:

- `value_type_t<T>` — the inner type. `Eigen::MatrixXd` gives `double`;
  `std::vector<std::vector<double>>` gives `std::vector<double>`; `double` gives
  `double`.
- `scalar_type` and `base_type` — see the API docs for how they differ.

Use these instead of hard-coding `double`, so the function works for `var` and
`fvar` too.

## 4. `.coeff()` and `.coeffRef()`

Eigen bounds-checks `[]` and `()`. Stan does its bounds checking at the language
level, so inside Math the unchecked accessors are safe and preferred:

- `.coeff(i)` to read
- `.coeffRef(i)` to assign

## Adding a distribution

Longer than adding a plain function, and reviewed harder. The
`adding_new_distributions` page of the contributor guide is the reference; the
shape of it:

1. **Get it working in the Stan language first.** Write the lpdf as a
   user-defined Stan function and verify it against another implementation. Post
   it on [Discourse](https://discourse.mc-stan.org/) or file an issue at this
   point — before writing C++.

   ```stan
   real new_normal_lpdf(real y, real mu, real sigma) {
     return -0.5 * pow((y - mu) / sigma, 2) - log(sigma) - 0.5 * log(2 * pi());
   }
   ```

2. **Write out the partial derivatives** for every input, by hand.

3. **Write the C++.** Univariate distributions must accept any mix of scalars
   and vectors for their arguments, which is what makes the code look daunting.

4. **Test it** — see [testing.md](testing.md).

For acceptance, a distribution needs its `lpdf`, `lcdf`, `cdf`, `lccdf`, **and**
`rng` implemented. Budget for that: contributing only the `lpdf` will not be
merged.
