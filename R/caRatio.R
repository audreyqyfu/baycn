#' @importFrom stats runif
#'
caRatio <- function (current,
                     edgeType,
                     m,
                     pmr,
                     proposed,
                     prior) {

  # To calculate the acceptance ratio we need to first have the prio probability
  # of the edges in the old individual and the new individual. Because they will
  # be the same for most of the edges we only need to consider the probabilities
  # of the edges that are different.
  difference <- proposed[1:(m - 1)] != current[1:(m - 1)]

  # Ater getting the locations of the differences of the edge directions between
  # the current and proposed graphs we need to get the directions of the edges.
  edgeDirP <- proposed[1:(m - 1)][difference]
  edgeDirC <- current[1:(m - 1)][difference]

  # Extract the edge type for the edges that have changed.
  etDiff <- edgeType[difference]

  # Number of changed edges.
  nDiff <- length(edgeDirP)

  # After getting the edge directions for each edge that is different between
  # the current and proposed graphs we need to get the prior probability
  # associated with each edge direction.
  priorP <- vector(mode = 'numeric',
                   length = nDiff)
  priorC <- vector(mode = 'numeric',
                   length = nDiff)

  # The following vectors will contain the transition probabilities for the
  # current and proposed graphs. transProbP will hold the probabilities for
  # moving from the proposed graph to the current graph and transProbC will hold
  # the probabilities of moving from the current graph to the proposed graph.
  transProbP <- vector(mode = 'numeric',
                       length = nDiff)
  transProbC <- vector(mode = 'numeric',
                       length = nDiff)

  # Attach the correct prior probability to each edge direction for both the old
  # and new individuals.
  for(e in 1:nDiff) {

    # I can use the edge direction (0, 1, or 2) to select the correct prior by
    # adding a 1 to it and using that number to subset the prior vector. For
    # example, if the edge direction is 0 the corresponding prior is in the
    # first position of the prior vector so prior[[0 + 1]] will give 0.05 which
    # is the default prior for an edge being 0.

    # Calculate the log(prior) for the current edge state and the probability of
    # moving from the proposed graph to the current graph.
    ptProposed <- carPrior(edgeDir1 = edgeDirP[[e]],
                           edgeDir2 = edgeDirC[[e]],
                           edgeType = etDiff[[e]],
                           pmr = pmr,
                           prior = prior)

    priorP[[e]] <- ptProposed[1]
    transProbP[[e]] <- ptProposed[2]

    # Calculate the log(prior) for the current edge state and the probability of
    # moving from the current graph to the proposed graph.
    ptCurrent <- carPrior(edgeDir1 = edgeDirC[[e]],
                          edgeDir2 = edgeDirP[[e]],
                          edgeType = etDiff[[e]],
                          pmr = pmr,
                          prior = prior)

    priorC[[e]] <- ptCurrent[1]
    transProbC[[e]] <- ptCurrent[2]

  }

  ratio <- ((sum(priorP) + proposed[[m]] + sum(transProbP))
            - (sum(priorC) + current[[m]] + sum(transProbC)))

  # Generate log uniform(0, 1) to compare to alpha which is
  # min(ratio, 0).
  logU <- log(runif(n = 1,
                    min = 0,
                    max = 1))

  alpha <- min(ratio, 0)

  # Determine if the proposed graph should be accepted.
  if (logU < alpha) {

    return (proposed)

  } else {

    return (current)

  }

}
