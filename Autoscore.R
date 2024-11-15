#install packages
install.packages("tidyverse")
install.packages("remotes")
remotes::install_github("autoscore/autoscore")

#load packages
library(tidyverse)
library(autoscore)
library(readxl)
library(dplyr)
library(writexl)

USMX <- read_excel("/Users/sarahpaull/Desktop/Creel-Lab/USMXoutput.xlsx")
Whisper <- read_excel("/Users/sarahpaull/Desktop/Creel-Lab/USMXsimplewhispertranscriptions.xlsx")
spelling <- read_excel("/Users/sarahpaull/Desktop/Creel-Lab/acceptable_spellings.xlsx", sheet = "acceptable_spellings")

#change column names from Actual to Target and Predicted to Response
USMX <- rename(USMX, target = Actual, response = `Manually Corrected Predicted`)
Whisper <- rename(Whisper, target = Actual, response = Predicted)

# Remove hyphens in USMX and replace with space
USMX$target <- gsub("-", " ", USMX$target)

#Add space to hyphen words in whisper
Whisper$target <- gsub("creepycrawly", "creepy crawly", Whisper$target)
Whisper$target <- gsub("whitestriped", "white striped", Whisper$target)
Whisper$target <- gsub("choochoo", "choo choo", Whisper$target)

#Add original column
USMX$Original_Response <- USMX$response
Whisper$Original_Response <- Whisper$response

#create id column 
USMX <- USMX %>% 
  mutate(id = row_number())

Whisper <- Whisper %>% 
  mutate(id = row_number())

contractions <- autoscore::contractions_df
#Create vector of acceptable compounds 
compound_vector <- c("my likes" = "my...likes", "into" = "in to","a runny" = "arunny", "by a" = "bya", "was a" = "wasa", "torn mage" = "tornmage", 
                      "a piece" = "apiece", "a salt" = "assault", "girl went on" = "girlwenton", "used three" = "usedthree", "back seat" = "backseat", 
                     "a lot" = "alot", "on a" = "ona", "rubber ducky" = "rubberducky", "spun a" = "spuna", "tug of war" = "tugofwar", "with a" = "witha", 
                     "bride wore" = "bridewore", "in a" = "ina", "running pumpkin" = "runningpumpkin", "coloring book" = "coloringbook", 
                     "from fresh" = "fromfresh", "to play" = "toplay", "on that" = "onthat", "their guns" = "theirguns", 
                     "playground, I" = "playground,I", "showed us" = "showedus", "use the" = "usethe", "remote to" = "remoteto", "tall key" = "tallkey", 
                     "tall key" = "tallkee", "tockstar" = "talkstar", "tockstar" = "tock star", "runkey" = "run key", "breakfast" = "break fast", 
                     "hathroom" = "hath room", "snowman" = "snow man", "tedrooms" = "ted rooms", "rockstar" = "rock star", "plathtub" = "plath tub", 
                     "tayground" = "tay ground", "snayground" = "snay ground", "airplane" = "air plane", "sarshmallows" = "sarsh mallows", 
                     "bathtub" = "bath tub", "playground" = "play ground", "snowballs" = "snow balls", "bathroom" = "bath room", "sistmas" = "cyst mas", 
                     "lilypad" = "lilly pad", "lilypad" = "lily pad", "sunglasses" = "sun glasses", "marshmallows" = "marsh mallows", 
                     "saterpillar" = "sater pillar", "sharshmallows" = "sharsh mellows", "coballs" = "co balls", "sleckfast" = "sleck fast", 
                     "matterpillar" = "mater pillar", "bunglasses" = "bun glases", "outside" = "out side", "deckfast" = "deck fast", "vilypad" = "villy pad", 
                     "drilot" = "dry lot", "ricnic" = "rick nick", "fommy" = "fa mi", "motercycle" = "moter cycle", "motorcycle" = "motor cycle", 
                     "cows" = "cow s", "butterfly" = "butter fly", "bee" = "b ee", "basement" = "base ment", "around" = "a round", "along" = "a long", 
                     "creepy crawly" = "creepycrawly", "choo choo" = "choochoo", "choo choo" = "chuchu", "inside" = "in side", "groceries in" = "groceriesin", 
                     "astronaut" = "astron aut", "pastronaut" = "pastron aut", "watch the" = "watchthe", "quilling i" = "quillingi", "on the" = "onthe", 
                     "a helmet" = "ahelmet", "on that" = "ont htat", "runny pumpkin" = "runn ypumpkin", "sitting on" = "sittin gon", "with a" = "wit ha",
                     "with the" = "witht he", "to shade" = "t oshade", "sister together" = "sistertogether", "a flag" = "aflag", "look at" = "lookat",
                     "look at" = "lookat", "into a" = "intoa", "fell in" = "felli n", "a shovel" = "ashovel", "coloring hook" = "colorin ghook", 
                     "for slegfast" = "forslegfast", "matterpillar" = "matter pillar", "the piercoast" = "thepiercoast", "gir saw" = "girsaw", "in the" = "int he", 
                     "in the" = "int h e", "sit in" = "sitin", "back seat" = "backseet", "back seat" = "bacseat", "us fossils" = "usfossils", "a wound" = "awound",
                     "use the" = "us ethe", "mak juice" = "makjuice", "time on" = "timeon", "tarium has" = "tariumhas", "in their" = "int heri",
                     "there there" = "therethere", "there" = "ther e", "sarshmallows" = "sarsh mellows", "pik killed" = "pikkilled", "betch with" = "betchwith",
                     "dinosaur" = "din asour", "missing a" = "missinga", "we lost" = "wel ost", "a monster" = "amonster", "is one" = "isone", "astronaut" = "austron aut",
                     "crawling bag" = "crawlingbag", "get a" = "geta", "on the" = "ont he", "oink oink" = "oinkoink", "sun out" = "sunout", "i was" = "iw as",
                     "munching on" = "munchingo n", "dinosaur" = "din asuar", "dinosaur" = "din asaor", "monkey ate" = "monkeyate", "astronaut" = "astron aught",
                     "astronaut" = "astron aaut", "spider spun" = "spiderspun", "tug a" = "tuga", "tug o war" = "tugowar", "into the" = "intot hte", "a large" = "alarge",
                     "king wore" = "kingwore", "he carved" = "hecarved", "out of" = "outof", "the groceries" = "ht egroceries", "so loud" = "soloud",
                     "dinosaur" = "din asaour", "the boy" = "theboy", "use the" = "usethe", "make" = "m ake", "the car" = "th ecar", "i want" = "iw ant", 
                     "white striped" = "whitestriped", "the boys" = "theboys")

#calculate autoscore
USMX <- USMX %>%
  dplyr::mutate(response = compound_fixer(response, comp = compound_vector)) %>%
            autoscore(acceptable_df = spelling, number_text_rule = TRUE, 
                      contractions_df = autoscore::contractions_df) %>%
            as_tibble()

Whisper <- Whisper %>%
  dplyr::mutate(response = compound_fixer(response, comp = compound_vector)) %>%
  autoscore(acceptable_df = spelling, number_text_rule = TRUE, 
            contractions_df = autoscore::contractions_df) %>%
  as_tibble()

#calculate percent words correct score
percent_words_correct <- USMX %>% pwc(id)
pwc_whisper <- Whisper %>% pwc(id)

#merge USMX data frame and percent_words_correct data frame
USMX_autoscore <- merge(USMX, percent_words_correct, by="id", all=TRUE)

Whisper_autoscore <- merge(Whisper, pwc_whisper, by = "id", all = TRUE)


#Write this to new excel file USMX_autoscore_all_columns and USMX_autoscore
write_xlsx(USMX_autoscore, "USMX_autoscore.xlsx")
write_xlsx(Whisper_autoscore, "Whisper_autoscore.xlsx")



