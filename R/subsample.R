#' Subsample multivariate datasets
#'
#' This function performs subsampling of multivariate datasets where the
#' proportions of the outcome variables may be inbalanced, which can lead to
#' poor preduction accuracy.
#' @importFrom caret downSample upSample
#' @importFrom checkmate assertCharacter assertClass checkIntegerish checkNull
#' @param data an \code{\link{ELSIPData}} object, such as the output of
#'   \code{\link{classifyPrepare}}.
#' @param type a single length character indicating the type of subsampling to
#'   perform. Current options are \code{"up"} (upsampling; using
#'   \code{\link[caret]{upSample}}) and \code{"down"}
#'   (downsampling; using \code{\link[caret]{downSample}}).
#' @param seed a random seed for initializing the subsampling.
#' @return An \code{\link{ELSIPData}} object.
#' @export
subsample <- function (data, type = c("up", "down"), seed = NULL) {
  assertClass(data, "ELSIPData")
  assertCharacter(type, len = 1, any.missing = FALSE)
  assert(
    checkNull(seed),
    checkIntegerish(seed)
  )

  unknowns <- is.na(data$y)
  ss_args <- list(x = data$x[!unknowns,],
                  y = data$y[!unknowns])
  type <- match.arg(type)
  if (type == "up") {
    ss_fn <- upSample
  } else if (type == "down") {
    ss_fn <- downSample
  }
  set.seed(seed = seed)
  ss <- do.call(ss_fn, ss_args)
  ss <- merge(ss, data$x[unknowns,], all = TRUE, sort = FALSE)

  ELSIPData$new(ss[,names(ss) != "Class"], ss$Class, data$data_type)
}
