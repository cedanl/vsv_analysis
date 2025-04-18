#' Close all tabs that are not already in the Tabs vector and close view panes
#'
#' This function iterates through all tabs in RStudio, closing those that are not
#' already listed in the Tabs vector. It also handles view panes by closing them
#' if they do not have a corresponding document context.
#'
#' @return NULL
#' @export
close_view <- function() {
    Tabs <- c()

    doc <- rstudioapi::getSourceEditorContext()

    while (is.null(doc) || !doc$id %in% Tabs) {
        if (is.null(doc)) {
            rstudioapi::executeCommand("closeSourceDoc")
        }
        rstudioapi::executeCommand("nextTab")

        Tabs <- c(Tabs, doc$id)

        doc <- rstudioapi::getSourceEditorContext()
    }
}

#' clear script objects.
#'
#' Clear objects which are created in the current script.
#' @param ... which object(s) to keep.
#' @param filepath path to script
#' @param list list of objects
#' @param pos what position in the environment to clear
#' @param envir which environment to clear
#' @param line_start from which line
#' @param line_end until which line
#' @param silent whether to mute console output
#' @export
clear_script_objects <- function(..., filepath = NULL, list = character(), pos = -1, envir = as.environment(pos), line_start = 0, line_end = -1L, silent = TRUE) {
    if (missing(filepath)) {
        filepath <- this.path::sys.path()
    }

    dots <- match.call(expand.dots = FALSE)$...
    if (length(dots) &&
        !all(vapply(dots, function(x) is.symbol(x) || is.character(x), NA, USE.NAMES = FALSE))) {
        stop("... must contain names or character strings")
    }
    names <- vapply(dots, as.character, "")
    if (length(names) == 0L) names <- character()
    list <- .Primitive("c")(list, names)

    Teststring_assignment <- "^[a-zA-Z_0-9]*(?=(\\s<-))"
    Regels <-
        stringr::str_extract(
            readr::read_lines(filepath, skip = line_start, n_max = line_end),
            Teststring_assignment
        )
    Regels <- base::unique(Regels[!base::is.na(Regels)])

    Regels2 <- setdiff(Regels, list)
    rm(list = Regels2, pos = ".GlobalEnv")
    if (!silent) {
        base::cat(cli::style_bold(cli::col_red("De volgende variabelen worden verwijderd: \n")))
        base::cat(cli::style_bold(cli::col_red(paste(Regels2,
                                                     collapse = ", \n"
        ))))
        base::cat(paste("\n"))
    }
}

# install_homebrew_and_deps.R

install_homebrew <- function() {
    if (Sys.which("brew") == "") {
        message("Installing Homebrew...")
        system(
            '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"',
            wait = TRUE
        )
        # Ensure brew is in PATH
        if (file.exists("/opt/homebrew/bin/brew")) {
            Sys.setenv(PATH = paste("/opt/homebrew/bin", Sys.getenv("PATH"), sep = ":"))
        }
    }
}

get_installed_brew_aliases <- function() {
    # Get installed package info in JSON format
    json_raw <- system("brew info --installed --json=v2", intern = TRUE)
    parsed <- jsonlite::fromJSON(paste(json_raw, collapse = "\n"), simplifyDataFrame = FALSE)

    if (!"formulae" %in% names(parsed)) return(character())

    # Loop over each formula and extract all known identifiers
    all_aliases <- unlist(
        lapply(parsed$formulae, function(x) {
            c(x$name, x$full_name, x$aliases)
        }),
        use.names = FALSE
    )

    unique(all_aliases)
}



install_brew_packages <- function(pkgs) {

    message("Check for system dependencies")
    installed <- get_installed_brew_aliases()

    # Check which are formulae or casks
    is_cask <- function(pkg) {
        # This returns TRUE if it's a valid cask, FALSE otherwise
        out <- system(paste("brew info --cask", pkg), intern = TRUE, ignore.stderr = TRUE)
        return(length(out) > 0)
    }

    casks <- suppressWarnings(Filter(is_cask, pkgs))
    formulae <- setdiff(pkgs, casks)

    # Check what is missing
    missing_formulae <- setdiff(formulae, installed)
    installed_casks <- system("brew list --cask", intern = TRUE)
    missing_casks <- setdiff(casks, installed_casks)

    # Install missing formulae
    if (length(missing_formulae)) {
        message("📦 Installing missing brew formulae: ", paste(missing_formulae, collapse = ", "))
        system(paste("brew install", paste(missing_formulae, collapse = " ")))
    }

    # Install missing casks (via Terminal to allow sudo)
    if (length(missing_casks)) {
        message("🖥️ Opening Terminal to install casks: ", paste(missing_casks, collapse = ", "))
        for (cask in missing_casks) {
            system(sprintf(
                'osascript -e \'tell application "Terminal" to do script "brew install --cask %s"\'',
                cask
            ))
        }
    }

    message("✅ All dependencies installed.")

}

install_brew_packages <- function(pkgs) {
    message("🔍 Checking for system dependencies...")

    installed <- get_installed_brew_aliases()

    # Categorize as casks or formulae (once)
    casks <- character()
    formulae <- character()

    for (pkg in pkgs) {
        msg <- paste0("  • Checking type of: ", pkg)
        message(msg)
        is_cask <- tryCatch({
            out <- suppressWarnings(system(paste("brew info --cask", pkg), intern = TRUE, ignore.stderr = TRUE))
            length(out) > 0 && !grepl("^Error", out[1])
        }, error = function(e) FALSE)

        if (is_cask) {
            casks <- c(casks, pkg)
        } else {
            formulae <- c(formulae, pkg)
        }
    }

    # Filter what's actually missing
    missing_formulae <- setdiff(formulae, installed)
    installed_casks <- system("brew list --cask", intern = TRUE)
    missing_casks <- setdiff(casks, installed_casks)

    if (length(missing_formulae)) {
        message("📦 Installing missing formulae: ", paste(missing_formulae, collapse = ", "))
        system(paste("brew install", paste(missing_formulae, collapse = " ")))
    }

    if (length(missing_casks)) {
        message("🖥️ Opening Terminal to install missing casks: ", paste(missing_casks, collapse = ", "))
        for (cask in missing_casks) {
            system(sprintf(
                'osascript -e \'tell application "Terminal" to do script "brew install --cask %s"\'',
                cask
            ))
        }
    }

    message("✅ Done checking/installing dependencies.")
}



get_platform <- function() {
    sysname <- Sys.info()[["sysname"]]
    switch(sysname,
           Darwin = "macOS",
           Linux = "Linux",
           Windows = "Windows",
           sysname)
}

ask_restart_rstudio <- function() {
    if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
        ans <- readline("🔄 Rtools installed. Restart R session now? [y/N]: ")
        if (tolower(ans) == "y") {
            message("Restarting R session...")
            rstudioapi::restartSession()
        } else {
            message("❗ Please restart R manually to complete Rtools setup.")
        }
    } else {
        message("⚠️ Not running in RStudio — please restart R manually.")
    }
}

get_required_r_version <- function(lockfile = "renv.lock") {
    lock <- jsonlite::fromJSON(lockfile)
    r_version <- lock$R$Version
    return(r_version)
}

r_version_to_rtools_suffix <- function(r_version) {
    # Extract major and minor version (e.g., "4.3.2" -> "4" and "3")
    parts <- strsplit(r_version, ".", fixed = TRUE)[[1]]
    major <- parts[1]
    minor <- parts[2]

    # Collapse to suffix like "43"
    paste0(major, minor)
}

get_rtools_info_from_lockfile <- function(lockfile = NULL) {
    if (is.null(lockfile)) {
        lockfile <- Sys.getenv("RENV_PATHS_LOCKFILE")
    }

    lock <- jsonlite::fromJSON(lockfile)
    r_version <- lock$R$Version
    suffix <- r_version_to_rtools_suffix(r_version)

    list(
        r_version = r_version,
        rtools_suffix = suffix,
        rtools_version = paste0("Rtools", suffix),
        rtools_exe = paste0("rtools", suffix, ".exe"),
        download_url = paste0("https://cran.r-project.org/bin/windows/Rtools/rtools", suffix, ".exe")
    )
}

install_rtools <- function() {
    rtools_info <- get_rtools_info_from_lockfile()

    rtools_url <- rtools_info$download_url
    dest <- file.path(tempdir(), rtools_info$rtools_exe)

    message("📥 Downloading Rtools installer...")
    download.file(rtools_url, dest, mode = "wb")

    message("🚀 Launching Rtools installer (will require user interaction)...")
    shell.exec(dest)  # opens installer GUI

    ask_restart_rstudio()
}

# Function to quickly check if packages are installed at correct versions
# Function to check if packages are installed at correct versions
are_packages_up_to_date <- function(packages) {
    library_paths <- .libPaths()
    project_lib <- renv::paths$library()

    # Get the lockfile
    lockfile <- renv::lockfile_read()

    # Check if any packages need updating
    all_up_to_date <- TRUE

    for (pkg in packages) {
        # Skip if package isn't in lockfile
        if (!pkg %in% names(lockfile$Packages)) {
            next
        }

        # Check if installed
        is_installed <- requireNamespace(pkg, quietly = TRUE)
        if (!is_installed) {
            all_up_to_date <- FALSE
            break
        }

        # Check version
        expected_version <- lockfile$Packages[[pkg]]$Version
        installed_version <- as.character(packageVersion(pkg))

        if (expected_version != installed_version) {
            all_up_to_date <- FALSE
            break
        }
    }

    return(all_up_to_date)
}
