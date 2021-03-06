#!/usr/bin/env r

library(purrr)

doc <- 'Usage: generate_Rmd.R [-o DIR] PACKAGE ...

-o --outdir DIR  directory to put Rmds [default: Rmds]'

opts <- docopt::docopt(doc)

#----------------------------

header_tmpl <- '---
title: |
%s
rdname: %s
date: %s
---

```{r, echo = FALSE, message = FALSE}
library(ggplot2)
library(%s)
```

```{r %s, cache = TRUE}
'

footer <- '
```'

## Functions --------

load_RdDB <- function(pkg) {
  library(pkg, character.only = TRUE, quietly = TRUE)
  RdDB <- tools::Rd_db(pkg)
  
  # discard if there is no Examples section
  RdDB <- keep(RdDB, ~ any(tools:::RdTags(.) == '\\examples'))
  
  RdDB
}

extract_Rd_field <- function(Rd, name) {
  # discard if the Rd field is not 'name' or 'alias'
  Rd_names <- keep(Rd, ~attr(., 'Rd_tag') == name)
  
  # each Rd field is nested; we need to Rd[[1]][[1]] to extract the character.
  map_chr(Rd_names, `[[`, c(1, 1))
}

get_Rd_aliases <- function(Rd) {
  c(
    extract_Rd_field(Rd, '\\name'),
    extract_Rd_field(Rd, '\\alias')
  )
}

get_Rd_title <- function(Rd) {
  extract_Rd_field(Rd, '\\title')
}

write_Rmd <- function(Rd, pkg, outdir) {
  title <- get_Rd_title(Rd)
  rdname <- extract_Rd_field(Rd, '\\name')
  
  out <- file.path(outdir, paste0(rdname, ".Rmd"))
  
  # header
  cat(sprintf(header_tmpl,
              title,
              rdname,
              strftime(Sys.time(), '%Y-%m-%d'),
              pkg,
              rdname),
      file = out)
  
  # codes
  tmp_ex <- tempfile()
  tools::Rd2ex(Rd, tmp_ex)
  ex <- readLines(tmp_ex)
  # dischard first six lines
  cat(paste0(ex[7:length(ex)], collapse = '\n'), file = out, append = TRUE)
  
  # footer
  cat(sprintf(footer, title), file = out, append = TRUE)
}


## Main --------


for (pkg in opts$PACKAGE) {
  outdir <- file.path(opts$outdir, pkg)
  dir.create(outdir, showWarnings = FALSE, recursive = TRUE)
  
  for (Rd in load_RdDB(pkg)) {
    write_Rmd(Rd, pkg, outdir)
  }
}
