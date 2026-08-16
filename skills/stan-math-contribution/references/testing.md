# Testing a Stan Math contribution

## Contents

- [What the project requires](#what-the-project-requires)
- [The expect_ad framework](#the-expect_ad-framework)
- [What expect_ad checks](#what-expect_ad-checks)
- [Tolerances](#tolerances)
- [Exceptions](#exceptions)
- [Running tests](#running-tests)

## What the project requires

- **Bug fix**: at least one test that fails before the patch and passes after.
  Write it and commit it *before* the fix, so the regression is caught if it
  ever returns.
- **New feature**: at least one test showing the expected behaviour, and one
  showing the behaviour when there is an error. This is a floor, not a target —
  reviewers routinely ask for more.
- **Refactoring**: existing behaviour tests are enough, provided they cover the
  behaviour you moved.

## The `expect_ad` framework

For a new function you do not hand-write derivative tests. `expect_ad()` takes
your primitive implementation and a set of inputs, and checks values and
derivatives against finite differences.

```cpp
// test/unit/math/mix/fun/dot_self_test.cpp
TEST(MathMixMatFun, dotSelf) {
  auto f = [](const auto& y) { return stan::math::dot_self(y); };

  Eigen::VectorXd x0(0);
  Eigen::VectorXd x1(1);
  x1 << 2;
  Eigen::VectorXd x2(2);
  x2 << 2, 3;

  stan::test::expect_ad(f, x0);
  stan::test::expect_ad(f, x1);
  stan::test::expect_ad(f, x2);
}
```

Include the test framework header, which pulls in `<stan/math.hpp>` entire —
deliberately, so the test also proves the function compiles with all
higher-order autodiff present.

Choose inputs that cover the edges: empty containers, size 1, a boundary value,
and something that should throw.

## What `expect_ad` checks

For every set of inputs it exercises all combinations of primitive (`int`,
`double`) and autodiff argument instantiations, up to third order:

| Order | Autodiff type | Functional |
| :-- | :-- | :-- |
| 1st | `var`, `fvar<double>` | `gradient()` |
| 2nd | `fvar<var>`, `fvar<fvar<double>>` | `hessian()` |
| 3rd | `fvar<fvar<var>>` | `grad_hessian()` |

It also covers every output dimension of a multivariate function (by projecting
to each in turn) and up to three levels of container nesting for elementwise
vectorized functions.

Supported input and output types: `int`, `double`,
`Eigen::Matrix<double, -1, 1>`, `Eigen::Matrix<double, 1, -1>`,
`Eigen::Matrix<double, -1, -1>`, and `std::vector<T>` of any of these.

## Tolerances

Comparison is on relative error, defined against the average magnitude:

```cpp
relative_error(u, v) = (u - v) / (0.5 * (abs(u) + abs(v)))
```

Absolute error is used instead when an input is zero.

Defaults are deliberately loose, because the reference values come from finite
differences:

| Test | Default tolerance |
| :-- | :-- |
| value (order 0) | 1e-8 |
| gradient (order 1) | 1e-4 |
| Hessian (order 2) | 1e-3 |
| gradient of Hessian (order 3) | 1e-2 |

Every test takes a `stan::test::ad_tolerances` object as its first argument, so
a specific test can override them. **Loosening a tolerance to make a test pass
is a red flag** — it usually means the derivative is wrong, not that the
threshold is. Justify any override in the pull request.

## Exceptions

The framework requires exception behaviour to be *consistent*: if any one of the
primitive or autodiff versions throws for a given input, they must all throw for
that input. A function that validates its arguments only in the `double`
overload will fail here.

## Running tests

Three granularities, and the choice matters to how the work feels: the full suite
is the one that has to pass before a pull request, but running it after every
edit wastes hours. Iterate on the single file, then run everything once before
pushing. From the repository root:

```bash
./runTests.py test/unit                          # everything (slow)
./runTests.py test/unit/math/prim/fun/foo_test.cpp   # one file, while iterating
./runTests.py test/unit/math/mix/fun             # one directory
```

In `stan-dev/stan` the paths are under `src/`: `./runTests.py src/test/unit` and
`./runTests.py src/test/integration`.

On Windows, drop the `./` and call the interpreter: `python runTests.py
test/unit`. The paths and the granularities do not change.

Performance tests live in `test/performance`. They must compile, but may not
pass locally — they depend on machine configuration.

Run the full suite once before pushing. A change in `prim` can break a
specialization in `rev` that you never opened.
