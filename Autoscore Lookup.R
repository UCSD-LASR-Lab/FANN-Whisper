install.packages("readxl")
install.packages("writexl")
library(readxl)
library(dplyr)
library(writexl)
#open files
USMXlookup <- read_excel("/Users/sarahpaull/Desktop/Creel-Lab/USMXlookup.xlsx")
USMXhumantranscriptions <- read_excel("/Users/sarahpaull/Desktop/Creel-Lab/US&MXhumantranscriptions updated.xlsx")

#Function to extract the lookup info
extract <- function(file_name) {
  sent_type <- str_extract(file_name, "(?<=_)\\w+")
  number <- str_extract(file_name, "(?<=word|sent)\\d+")
  return(paste0(sent_type, number))
}

#Add lookup info column to USMXhumantranscriptions
USMXhumantranscriptions <- USMXhumantranscriptions %>%
  mutate(lookupval = sapply(File, extract))

#Combine dataframes by lookupval
merged_df <- merge(USMXhumantranscriptions, USMXlookup, by = "lookupval", all.x = TRUE)

#Create Actual column depending on if we transcribed the full sentence or just the final word
USMX <- merged_df %>%
  mutate(Actual = ifelse(grepl("sent", File), Sentence, FinalWord))

USMX<- USMX %>%
  mutate(type = ifelse(grepl("sent", File), "sentence", "word"))

#Write this to new excel file USMXoutput
write_xlsx(USMX, "USMXoutput.xlsx")

