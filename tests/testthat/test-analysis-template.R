test_that("analysis template file created snapshot", {
  withr::with_tempdir(
    {
      writeLines(
        c(
          "Package: testPackage",
          "Type: Package",
          "Version: 0.1.0",
          "Author: Test Author",
          "Maintainer: test@example.com",
          "Description: A test package",
          "License: MIT"
        ),
        "DESCRIPTION"
      )
      analysis_template("abundance", open = FALSE)
      expect_snapshot_file("abundance.R") 
    }
  )
})
