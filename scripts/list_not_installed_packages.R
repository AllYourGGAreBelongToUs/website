#!/usr/bin/env r

pkgs <- readLines(file("stdin"))
pkgs_not_installed <- purrr::discard(pkgs, ~ . %in% installed.packages())
cat(pkgs_not_installed, sep = "\n")
