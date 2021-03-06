% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cgraph_knn_mcnorm.r
\name{mcell_add_cgraph_bknn_norm_mc}
\alias{mcell_add_cgraph_bknn_norm_mc}
\title{Build a cell graph using balanced knn after normalizing over a given metacell model}
\usage{
mcell_add_cgraph_bknn_norm_mc(graph_id, mat_id, gset_id, K, mc_to_norm)
}
\arguments{
\item{graph_id}{new graph id to create}

\item{mat_id}{matrix object id}

\item{gset_id}{gset object id defining the gene features used for computing distances}

\item{K}{the guideline Knn parameter. The balanced will be constructed aiming at K edges per cell}
}
\description{
Build a cell graph using balanced knn after normalizing over a given metacell model
}
