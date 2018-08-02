#' colorize metacell using a set of prefered markers and their colors
#'
#' @param mc_id metacell id in scdb
#' @param marker_color a data frame with fields gene, group, color, priority, thresh
#' @param override if this is true, all colors are going to be set to white unless some marker match is found
#'
#' @export
mc_colorize = function(mc_id, marker_colors = NULL, override = T)
{
	mc = scdb_mc(mc_id)
	if(is.null(mc)) {
		stop("MC-ERR metacell object is not avaialble in scdb, id = ", mc_id)
	}
	if(class(marker_colors)[1] != "data.frame"
	| length(intersect(c("gene","group", "color","priority","T_fold"),
								colnames(marker_colors))) != 5) {
		stop("MC-ERR marker colors parameter must be a data frame with fields gene, group, color, priority, T_fold")
	}
	marker_colors$gene = as.character(marker_colors$gene)
	marker_colors$color= as.character(marker_colors$color)
	rownames(marker_colors) = marker_colors$gene

	if(override) {
	  mc@colors = rep("white", ncol(mc@mc_fp))
	}
	good_marks = intersect(rownames(marker_colors),
						rownames(mc@mc_fp))
	if(length(good_marks) == 0) {
		message("no color makers are found")
		return
	}
	marker_colors = marker_colors[good_marks, ]

	mc@color_key = as.data.frame(marker_colors)

	cl_colors = rep(NA, ncol(mc@mc_fp))

	marker_colors = marker_colors[order(marker_colors$priority),]
	marker_fold = mc@mc_fp[marker_colors$gene,]
	marker_fold = ifelse(marker_fold > marker_colors$T_fold, log2(marker_fold), 0)
	marker_fold = marker_fold * marker_colors$priority
	marker_fold[marker_fold == 0] = NA
	if(length(good_marks) > 1) {
		nonz = colSums(!is.na(marker_fold)) > 0
		hit = apply(marker_fold[, nonz], 2, which.max)
	} else {
		nonz = marker_fold > 0
		hit = rep(1, sum(nonz))
	}
	cl_colors[nonz] = marker_colors[hit, "color"]
	if(!override) {
		cl_colors[is.na(cl_colors)] = mc@colors[is.na(cl_colors)]
	}
	mc@colors = cl_colors
	scdb_add_mc(mc_id, mc)
}

#' colorize metacell using an ugly default color spectrum, or a user supplied one
#'
#' @param mc_id metacell id in scdb
#'
#' @export
mc_colorize_default = function(mc_id, spectrum = NULL)
{
	mc = scdb_mc(mc_id)
	if(is.null(mc)) {
		stop("MC-ERR metacell object is not avaialble in scdb, id = ", mc_id)
	}

	if(is.null(spectrum)) {
		spectrum = colorRampPalette(c("white", "lightgray", "darkgray", "burlywood1", "chocolate4","orange", "red", "purple", "blue", "cyan"))
	}
	mc@colors = spectrum(max(mc@mc))
	scdb_add_mc(mc_id, mc)
}

#' colorize metacells using a set of super MCs derived by hclust, colored according to a user defined table
#'
#' @param mc_id metacell id in scdb
#' @param supmc output from mcell_mc_hierarchy, defining groups of mcs
#' @param supmc_key filename of color index, specifying an ordered list of supmc ids and colors, to be colored in the order of apperance (i.e. last line overrid previous lines). Expected field names: supid, color, name
#'
#' @export
mc_colorize_sup_hierarchy = function(mc_id, supmc, supmc_key, gene_key=NULL)
{
	mc = scdb_mc(mc_id)
	if(is.null(mc)) {
		stop("MC-ERR metacell object is not avaialble in scdb, id = ", mc_id)
	}

	lfp = log2(mc@mc_fp)

	mc@colors = rep("white", ncol(mc@mc_fp))

	if(!file.exists(supmc_key)) {
		stop("Sup mc key file ", supmc_key, " does not exist")
	}
	key = read.table(supmc_key, h=T, sep="\t", stringsAsFactors=F)
	
	if(class(key)[1] != "data.frame"
	| length(intersect(c("supid", "color", "name"), colnames(key))) != 3) {
		stop("MC-ERR sup id color key must be a data frame with fields supid, color, name")
	}
	for(i in 1:nrow(key)) {
		mcs = supmc[[key$supid[i]]]$mcs
		mc@colors[mcs] = key$color[i]
	}
	color_key = data.frame(gene=rep("",times=nrow(key)), group=as.character(key$name), color=as.character(key$color))
	if(!is.null(gene_key)) {
		if(!file.exists(gene_key)) {
			stop("Gene color key file ", gene_key, " does not exist")
		}
		gkey = read.table(gene_key, h=T, sep="\t", stringsAsFactors=F)
		if(class(gkey)[1] != "data.frame"
		| length(intersect(c("name", "gene", "color", "T_fold"), colnames(gkey))) != 4) {
			stop("MC-ERR sup id color key must be a data frame with fields gene, name, color, T_fold")
		}
		for(i in 1:nrow(gkey)) {
			gene = gkey$gene[i]
			if(gene %in% rownames(lfp)) {
				T_fold = gkey$T_fold[i]
				mcs = which(lfp[gene,]>T_fold)
				if(length(mcs)>0) {
					mc@colors[mcs] = gkey$color[i]
					color_key = rbind(as.matrix(color_key), 
										matrix(c(gene=gene, group=gkey$name[i], color=gkey$color[i]),nrow=1))
				}
			}
		}
	}

	colnames(color_key) = c("gene", "group", "color")
	mc@color_key = as.data.frame(color_key)
	scdb_add_mc(mc_id, mc)
}


