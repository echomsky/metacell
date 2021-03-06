% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/scmat_batch_stat.r
\name{mcell_plot_umis_per_cell}
\alias{mcell_plot_umis_per_cell}
\title{Plot histogram of total number of umis per cell in the umis matrix}
\usage{
mcell_plot_umis_per_cell(mat_id, min_umis_cutoff = NA, bin_for_cutoff = 50)
}
\arguments{
\item{mat_id}{id of the mat to use}

\item{min_umis_cutoff}{If not null, will mark this cutoff by a line. If NA, auto calculate by finding the first bin in the histogram with more cells then its predecessor.}

\item{bin_for_cutoff}{bin size for histogram used to auto find min_umis_cutoff}
}
\value{
min_umis_cutoff (either the given, the calculated, or null)
}
\description{
Plot histogram of total number of umis per cell in the umis matrix
}
