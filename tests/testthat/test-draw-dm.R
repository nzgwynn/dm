test_that("API", {
  expect_identical(
    color_quos_to_display(
      flights = "blue",
      airlines = ,
      airports = "orange",
      planes = "green_nb"
    ),
    set_names(
      c("flights", "airlines", "airports", "planes"),
      c("blue", "orange", "orange", "green_nb")
    )
  )
})

test_that("`dm_set_colors()` works", {
  skip_if_src("postgres")
  skip_if_src("mssql")

  expect_identical(
    dm_set_colors(
      dm_nycflights_small(),
      blue = starts_with("air"),
      green = contains("h")
    ) %>%
      dm_get_colors(),
    set_names(
      src_tbls(dm_nycflights_small()),
      c("#00FF00FF", "default", "#0000FFFF", "#0000FFFF", "#00FF00FF")
    )
  )

  # test splicing
  colset <- c(blue = "flights", green = "airports")

  expect_identical(
    dm_set_colors(
      dm_nycflights_small(),
      !!!colset
    ) %>%
      dm_get_colors(),
    set_names(
      src_tbls(dm_nycflights_small()),
      c("#0000FFFF", "default", "default", "#00FF00FF", "default")
    )
  )
})

test_that("`dm_set_colors()` errors if old syntax used", {
  skip_if_src("postgres")
  skip_if_src("mssql")

  expect_dm_error(
    dm_set_colors(
      dm_nycflights_small(),
      airports = ,
      airlines = "blue",
      flights = ,
      weather = "green"
    ),
    class = "wrong_syntax_set_cols"
  )
})

test_that("`dm_set_colors()` errors with unnamed args", {
  skip_if_src("postgres")
  skip_if_src("mssql")

  expect_dm_error(
    dm_set_colors(
      dm_nycflights_small(),
      airports
    ),
    class = "only_named_args"
  )
})

test_that("last", {
  expect_dm_error(
    color_quos_to_display(
      flights = "blue",
      airlines =
      ),
    class = "last_col_missing"
  )
})

test_that("bad color", {
  skip_if_not(getRversion() >= "3.5")
  skip_if_src("postgres")
  skip_if_src("mssql")

  expect_dm_error(
    dm_set_colors(
      dm_nycflights_small(),
      "zzz-bogus" = flights
    ),
    class = "cols_not_avail"
  )
})

test_that("getter", {
  skip_if_src("postgres")
  skip_if_src("mssql")
  expect_equal(
    dm_get_colors(dm_nycflights13()),
    c(
      "#ED7D31FF" = "airlines",
      "#ED7D31FF" = "airports",
      "#5B9BD5FF" = "flights",
      "#ED7D31FF" = "planes",
      "#70AD47FF" = "weather"
    )
  )
})

test_that("datamodel-code for drawing", {
  data_model_for_filter <- dm_get_data_model(dm_for_filter())

  expect_s3_class(
    data_model_for_filter,
    "data_model"
  )

  expect_identical(
    map(data_model_for_filter, nrow),
    list(tables = 6L, columns = 15L, references = 5L)
  )
})

test_that("get available colors", {
  expect_length(
    dm_get_available_colors(),
    length(colors()) + 1
  )
})

test_that("helpers", {
  expect_identical(
    dm_get_all_columns(dm_for_filter()),
    tibble::tribble(
      ~table, ~id, ~column,
      "tf_1", 1L, "a",
      "tf_1", 2L, "b",
      "tf_2", 1L, "c",
      "tf_2", 2L, "d",
      "tf_2", 3L, "e",
      "tf_3", 1L, "f",
      "tf_3", 2L, "g",
      "tf_4", 1L, "h",
      "tf_4", 2L, "i",
      "tf_4", 3L, "j",
      "tf_5", 1L, "k",
      "tf_5", 2L, "l",
      "tf_5", 3L, "m",
      "tf_6", 1L, "n",
      "tf_6", 2L, "o"
    )
  )
})

test_that("output", {
  skip_if_src("postgres")
  skip_if_src("mssql")
  expect_known_output(
    dm_nycflights13() %>%
      dm_draw() %>%
      DiagrammeRsvg::export_svg() %>%
      cli::cat_line(),
    "out/nycflights13.svg"
  )
})
