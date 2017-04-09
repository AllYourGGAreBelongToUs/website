#!/usr/bin/env r

doc <- 'Usage: generateRmd.r [-o DIR] PACKAGE

-o --outdir DIR  directory to put Rmds [default: docs]'

opts    <- docopt::docopt(doc)

cat(opts$outdir)
stop(1)

#----------------------------

header_tmpl <- '---
title: |
%s
rdname: %s
date: %s
output: html_document
layout: article
category: %s
images:
FRONTFOMATTER_IMAGES
---

```{r, echo = FALSE, message = FALSE}
library(ggplot2)
library(%s)
```

```{r %s, cache = TRUE}
'

footer <- '
```'

library(opts$PACKAGE, character.only = TRUE, quietly = TRUE)
RdDB <- tools::Rd_db(opts$PACKAGE)

exported_objnames <- ls(sprintf('package:%s', opts$PACKAGE))

f <- tempfile()

for(Rdname in names(RdDB)) {
  Rd <- RdDB[[Rdname]]
  
  # skip if there is no Examples section
  if(!any(tools:::RdTags(Rd) == "\\examples")) next
  
  # skip if the Rd is not related to exported objects
  aliases <- unlist(Rd[which(tools:::RdTags(Rd) %in% c("\\name", "\\alias") )])
  if(!any(aliases %in% exported_objnames)) next
  
  title <- paste0(as.character(Rd[[which(tools:::RdTags(Rd) == "\\title")]]), collapse = "")
  title <- gsub('\n', '\n  ', title)
  title <- gsub('list\\("(\\w+)"\\)', '\\1', title)
  
  rdname <- sub("\\.Rd$", "", Rdname)
  
  # use the date when Zero Wing released on Sega Mega Drive! 
  date  <- "1991-05-31"
  
  out <- file.path("_source", sprintf("%s-%s.Rmd", date, rdname))
  
  # header (Note that categories are normalized to dwoncase by Jekyll anyway)
  cat(sprintf(header_tmpl, title, rdname, strftime(Sys.time(), "%Y-%m-%d"), tolower(opts$PACKAGE), opts$PACKAGE, rdname), file = out)
  
  # codes
  tools::Rd2ex(Rd, f)
  
  # dischard first six lines
  ex <- readLines(f)
  cat(paste0(ex[7:length(ex)], collapse = "\n"), file = out, append = TRUE)
  
  # footer
  cat(sprintf(footer, title), file = out, append = TRUE)
}
