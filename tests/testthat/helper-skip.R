skip_if_error <- function(expr) {
  tryCatch(
    force(expr),
    error = function(e) {
      skip(e$message)
    }
  )
}

skip_if_remote_src <- function(src = my_test_src()) {
  if (inherits(src, "src_dbi")) skip("works only locally")
}

skip_if_local_src <- function(src = my_test_src()) {
  if (inherits(src, "src_local")) skip("works only on a DB")
}

skip_if_src <- function(name, src = my_test_src()) {
  if (my_test_src_name == name) skip(paste0("does not work on ", name))
}
