test_that("dm_zoom_to() works", {

  # no zoom in unzoomed `dm`
  expect_false(
    is_zoomed(dm_for_filter())
  )

  # zoom in zoomed `dm`
  expect_true(
    is_zoomed(dm_for_filter() %>% dm_zoom_to(tf_1))
  )

  expect_s3_class(
    dm_for_filter() %>% dm_zoom_to(tf_3),
    c("zoomed_dm", "dm")
  )
})


test_that("dm_discard_zoomed() works", {
  # no zoom in zoomed out from zoomed `dm`
  expect_false(is_zoomed(dm_for_filter() %>% dm_zoom_to(tf_1) %>% dm_discard_zoomed()))

  expect_s3_class(
    dm_for_filter() %>% dm_zoom_to(tf_3) %>% dm_discard_zoomed(),
    c("dm")
  )
})

test_that("print() and format() methods for subclass `zoomed_dm` work", {
  expect_output(
    dm_for_filter() %>% dm_zoom_to(tf_5) %>% print(),
    "# Zoomed table: tf_5"
  )

  expect_output(
    dm_for_filter() %>% dm_zoom_to(tf_2) %>% format(),
    "# Zoomed table: tf_2"
  )
})


test_that("dm_get_zoomed_tbl() works", {
  expect_identical(
    dm_for_filter() %>%
      dm_zoom_to(tf_2) %>%
      dm_get_zoomed_tbl() %>%
      pluck("table"),
    "tf_2"
  )
  expect_equivalent_tbl(
    dm_for_filter() %>%
      dm_zoom_to(tf_2) %>%
      dm_get_zoomed_tbl() %>%
      pluck("zoom") %>%
      pluck(1),
    tf_2()
  )

  # function for getting only the tibble itself works
  expect_equivalent_tbl(
    dm_for_filter() %>% dm_zoom_to(tf_3) %>% get_zoomed_tbl(),
    tf_3()
  )
})

test_that("dm_insert_zoomed() works", {
  # test that a new tbl is inserted, based on the requested one
  expect_equivalent_dm(
    dm_zoom_to(dm_for_filter(), tf_4) %>% dm_insert_zoomed("tf_4_new"),
    dm_for_filter() %>%
      dm_add_tbl(tf_4_new = tf_4()) %>%
      dm_add_pk(tf_4_new, h) %>%
      dm_add_fk(tf_4_new, j, tf_3) %>%
      dm_add_fk(tf_5, l, tf_4_new)
  )

  # test that an error is thrown if 'repair = check_unique' and duplicate table names
  expect_dm_error(
    dm_zoom_to(dm_for_filter(), tf_4) %>% dm_insert_zoomed("tf_4", repair = "check_unique"),
    "need_unique_names"
  )

  # test that in case of 'repair = unique' and duplicate table names -> renames of old and new
  expect_equivalent_dm(
    expect_silent(dm_zoom_to(dm_for_filter(), tf_4) %>% dm_insert_zoomed("tf_4", repair = "unique", quiet = TRUE)),
    dm_for_filter() %>%
      dm_rename_tbl(tf_4...4 = tf_4) %>%
      dm_add_tbl(tf_4...7 = tf_4()) %>%
      dm_add_pk(tf_4...7, h) %>%
      dm_add_fk(tf_4...7, j, tf_3) %>%
      dm_add_fk(tf_5, l, tf_4...7)
  )
})

test_that("dm_update_tbl() works", {
  # setting table tf_7 as zoomed table for tf_6 and removing its primary key and foreign keys pointing to it
  new_dm_for_filter <- dm_get_def(dm_for_filter()) %>%
    mutate(
      zoom = if_else(table == "tf_6", list(tf_7()), NULL)
    ) %>%
    new_dm3(zoomed = TRUE)

  # test that the old table is updated correctly
  expect_equivalent_dm(
    dm_update_zoomed(new_dm_for_filter),
    dm_for_filter() %>%
      dm_rm_tbl(tf_6) %>%
      dm_add_tbl(tf_6 = tf_7()) %>%
      dm_get_def() %>%
      new_dm3()
  )
})

# after #271:
test_that("all cols are tracked in zoomed table", {
  skip_if_src("postgres")
  skip_if_src("mssql")

  expect_identical(
    dm_zoom_to(dm_nycflights_small(), flights) %>% get_tracked_cols(),
    set_names(colnames(tbl(dm_nycflights_small(), "flights")))
  )
})
