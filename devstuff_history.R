# Hide this file from build
usethis::use_build_ignore("devstuff_history.R")
usethis::use_build_ignore("inst/dev")
usethis::use_build_ignore("rsconnect")
usethis::use_git_ignore("docs/")
usethis::use_git_ignore("rsconnect/")
# usethis::create_package(".")

# git
usethis::use_git()
usethis::use_github()

# description ----
library(desc)
unlink("DESCRIPTION")
my_desc <- description$new("!new")
my_desc$set_version("0.0.0.9000")
my_desc$set(Package = "cartomisc")
my_desc$set(Title = "Miscellaneous tools for spatial data")
my_desc$set(Description = "Some useful tools for use with spatial data.")
my_desc$set("Authors@R",
            'c(
  person("Sebastien", "Rochette", email = "sebastien@thinkr.fr", role = c("aut", "cre"), comment = c(ORCID = "0000-0002-1565-9313"))
)')
my_desc$set("VignetteBuilder", "knitr")
my_desc$del("Maintainer")
my_desc$del("URL")
my_desc$del("BugReports")
my_desc$write(file = "DESCRIPTION")

# Licence ----
usethis::use_mit_license("Sébastien Rochette")
# usethis::use_gpl3_license("ThinkR")

# Pipe ----
usethis::use_pipe()

# Package quality ----

# _Tests
usethis::use_testthat()
usethis::use_test("app")

# _CI
# usethis::use_travis()
# usethis::use_appveyor()
# usethis::use_coverage()
usethis::use_github_action_check_standard()
usethis::use_github_action("pkgdown")

# _rhub
# rhub::check_for_cran()


# Documentation ----
# _Readme
usethis::use_readme_rmd()
# _News
usethis::use_news_md()
# _Vignette
thinkridentity::create_vignette_thinkr("aa-introduction")
usethis::use_vignette("aa-introduction")
usethis::use_vignette("regional-seas-buffer")
devtools::build_vignettes()

# Dependencies ----
# devtools::install_github("ThinkR-open/attachment")
attachment::att_to_description()
attachment::att_to_description(extra.suggests = c("bookdown", "pkgdown"))
# attachment::create_dependencies_file()

# Utils for dev ----
devtools::install(upgrade = "never")
# devtools::load_all()
devtools::check(vignettes = TRUE)
# ascii
stringi::stri_trans_general("é", "hex")
