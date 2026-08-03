# =============================================================================
# R Debugger demo <U+2014> vscDebugger (rdebugger.r-debugger extension)
#
# HOW TO USE
# ----------
# 1. Make sure the extension is installed: rdebugger.r-debugger
# 2. Press F5 (or Run > Start Debugging) — choose "R Debugger"
#    launch config
# 3. Set breakpoints by clicking the gutter (left margin) on any
#    line marked 🔴
# 4. Use the debug toolbar: Continue (F5), Step Over (F10), Step Into (F11),
#    Step Out (Shift+F11), Restart, Stop
# 5. Inspect variables in the "Variables" panel (left sidebar)
# 6. Evaluate expressions in the "Debug Console" panel


# --- A. Simple function: set a breakpoint on any line inside ----------------

add_and_scale <- function(x, y, scale = 2) {
  total <- x + y # <U+0001F534> set breakpoint here <U+2014> inspect x, y, total
  result <- total * scale
  result
}


# --- B. Nested calls: use Step Into (F11) to follow the call stack ----------

square <- function(x) {
  x^2 # <U+0001F534> step into here from calling function
}

sum_of_squares <- function(a, b) {
  sq_a <- square(a) # <U+0001F534> F11 steps INTO square(); F10 stays here
  sq_b <- square(b)
  sq_a + sq_b
}


# --- C. Loop: inspect how a variable evolves iteration by iteration ---------

running_stats <- function(n = 10) {
  results <- numeric(n)
  for (i in seq_len(n)) {
    results[i] <- i^2 + rnorm(1, sd = 0.5) # <U+0001F534> watch `results` grow
  }
  list(
    values = results,
    mean   = mean(results),
    sd     = sd(results)
  )
}


# --- D. Conditional breakpoint demo ----------------------------------------
# Right-click the gutter on the line marked 🔴❓ and set
# condition: i == 5
# The debugger will only pause at that iteration.

find_first_above <- function(threshold = 50, n = 10) {
  for (i in seq_len(n)) {
    value <- i^2 # <U+0001F534><U+2753> condition: i == 5
    if (value > threshold) {
      return(i)
    }
  }
  NA_integer_
}


# --- E. browser() — programmatic breakpoint, always triggers ------

validate_input <- function(x) {
  if (!is.numeric(x)) {
    browser() # execution pauses here unconditionally when hit
    stop("x must be numeric")
  }
  sqrt(abs(x))
}


# --- F. Traceback on error — inspect the call stack panel ----------

risky_divide <- function(x, y) {
  if (y == 0) stop("Division by zero!") # <U+0001F534> set breakpoint here
  x / y
}

safe_pipeline <- function(a, b) {
  intermediate <- add_and_scale(a, b)
  risky_divide(intermediate, b - a) # triggers error when a == b
}


# =============================================================================
# RUN SECTION — step through this block with F10 to exercise all
# functions
# =============================================================================

set.seed(42)

# A
result_a <- add_and_scale(3, 7, scale = 3)
cat("A:", result_a, "\n")

# B <U+2014> step into to follow the call stack
result_b <- sum_of_squares(4, 5)
cat("B:", result_b, "\n")

# C
stats <- running_stats(n = 8)
cat("C: mean =", round(stats$mean, 2), "sd =", round(stats$sd, 2), "\n")

# D <U+2014> set a conditional breakpoint on i == 5 inside find_first_above()
idx <- find_first_above(threshold = 20, n = 10)
cat("D: first index above threshold:", idx, "\n")

# E <U+2014> passes fine (numeric input)
result_e <- validate_input(-9)
cat("E:", result_e, "\n")

# F <U+2014> uncomment to trigger the error and inspect the traceback panel
safe_pipeline(5, 5)

cat("\n<U+2705> All checks passed <U+2014> debugger is working correctly.\n")
