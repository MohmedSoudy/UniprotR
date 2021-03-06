#' Connect and parse UniProt protein taxonomic information.
#'
#' The function is work to retrieve Miscellaneous data from UniProt for a list of proteins accessions.
#' For more information about what included in the Miscellaneous
#' data see https://www.uniprot.org/help/uniprotkb_column_names.
#'
#' @usage GetTaxaidentifier(ProteinAccList, directorypath = NULL)
#'
#' @param ProteinAccList Vector of UniProt Accession/s
#'
#' @param directorypath path to save excel file containig results returened by the function.
#'
#' @return DataFrame where rows names are the accession
#'      and columns contains the Taxonomic Information of protein from the UniProt
#'
#' @note The function also, Creates a csv file with the retrieved information.
#'
#' @examples Obj <- GetTaxaidentifier("O14520")
#'
#' @export
#'
#' @author Mohmed Soudy \email{Mohamed.soudy@57357.com} and Ali Mostafa \email{ali.mo.anwar@std.agr.cu.edu.eg}

GetTaxaidentifier <- function(ProteinAccList, directorypath = NULL)
{
  if(!has_internet())
  {
    message("Please connect to the internet as the package requires internect connection.")
    return()
  }
  ProteinInfoParsed_total = data.frame()
  baseUrl <- "http://www.uniprot.org/uniprot/"
  Colnames = "lineage-id(all),lineage-id(SUPERKINGDOM),lineage-id(KINGDOM),lineage-id(SUBKINGDOM),lineage-id(SUPERPHYLUM),lineage-id(PHYLUM),lineage-id(SUBPHYLUM),lineage-id(SUPERCLASS),lineage-id(CLASS),lineage-id(SUBCLASS),lineage-id(INFRACLASS),lineage-id(SUPERORDER),lineage-id(ORDER),lineage-id(SUBORDER),lineage-id(INFRAORDER),lineage-id(PARVORDER),lineage-id(SUPERFAMILY),lineage-id(FAMILY),lineage-id(SUBFAMILY),lineage-id(TRIBE),lineage-id(SUBTRIBE),lineage-id(GENUS),lineage-id(SUBGENUS),lineage-id(SPECIES GROUP),lineage-id(SPECIES SUBGROUP),lineage-id(SPECIES),lineage-id(SUBSPECIES),lineage-id(VARIETAS),lineage-id(FORMA)"
  for (ProteinAcc in ProteinAccList)
  {
    #to see if Request == 200 or not
    Request <- tryCatch(
      {
        GET(paste0(baseUrl , ProteinAcc,".xml") , timeout(7))
      },error = function(cond)
      {
        message("Internet connection problem occurs and the function will return the original error")
        message(cond)
      }
    )
    #this link return information in tab formate (format = tab)
    #columns = what to return from all of the information (see: https://www.uniprot.org/help/uniprotkb_column_names)
    ProteinName_url <- paste0("?query=accession:",ProteinAcc,"&format=tab&columns=", Colnames)
    RequestUrl <- paste0(baseUrl , ProteinName_url)
    RequestUrl <- URLencode(RequestUrl)
    if (length(Request) == 0)
    {
      message("Internet connection problem occurs")
      return()
    }
    if (Request$status_code == 200){
      # parse the information in DataFrame
      ProteinDataTable <- tryCatch(read.csv(RequestUrl, header = TRUE, sep = '\t'), error=function(e) NULL)
      if (!is.null(ProteinDataTable))
      {
        ProteinDataTable <- ProteinDataTable[1,]
        ProteinInfoParsed <- as.data.frame(ProteinDataTable,row.names = ProteinAcc)
        # add Dataframes together if more than one accession
        ProteinInfoParsed_total <- rbind(ProteinInfoParsed_total, ProteinInfoParsed)
      }
    }else {
      HandleBadRequests(Request$status_code)
    }
  }
  if(!is.null(directorypath)){
  write.csv(ProteinInfoParsed_total , paste0(directorypath, "/" ,"Taxa Information.csv"))
  }
  return(ProteinInfoParsed_total)
}
