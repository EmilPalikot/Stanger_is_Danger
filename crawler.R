rm(list=ls())
library(RSelenium)
library(rJava)
library(jsonlite)
library(plyr)

#Note 19.05 - try only the departing from commun and check if I capture the initial routes; before the pandemic searches

#Docker
shell('docker run -d -p 4445:4444 selenium/standalone-chrome')
remDr <- remoteDriver(remoteServerAddr = "localhost", port = 4445L, browserName = "chrome")
remDr$open()
remDr$navigate("http://www.google.com/ncr")
remDr$getTitle()#
remDr$screenshot(display = TRUE)
remDr$maxWindowSize(winHand = "current")

#API

api <- "XXXX"# set API
date = c("2020-07-12","2020-07-13")




 for(i in 1: 66){
    url <- paste0("https://public-api.blablacar.com/api/v2/trips?fn=",trips[1,i],"&tn=",trips[2,i],"&db=",day,"&cur=EUR&count=100&limit=50&key=YUDeUUu3E2frGD0xOurnTpFal3lBg2G6")
    tryCatch({
      remDr$navigate(url)
    data <- fromJSON(url)
    print(paste("Trip",trips[1,i], " to ",trips[2,i], "on day ", day, "number of rides ",as.numeric(data$total_trip_count_to_display)  ))
    if(as.numeric(data$total_trip_count_to_display) > 0){
    ride_urls <- data$trips$links$`_front`
    departure_date <- data$trips$departure_date
    date_passed <- data$trips$is_passed
    city_departure <- data$trips$departure_place$city_name
    address_departure <- data$trips$departure_place$address
    lat_departure <-data$trips$departure_place$latitude
    long_departure <-data$trips$departure_place$longitude
    city_arrival <- data$trips$arrival_place$city_name
    address_arrival <- data$trips$arrival_place$address
    lat_arrival <-data$trips$arrival_place$latitude
    long_arrival <-data$trips$arrival_place$longitude
    price <- data$trips$price_with_commission$value
    price_no_comission <- data$trips$price_without_commission$value
    seats_left <-data$trips$seats_left
    seats <- data$trips$seats
    seats_total <- data$trips$seats_count_origin
    duration_value <- data$trips$duration$value
    distance_value <- data$trips$distance$value
    permanent_id <- data$trips$permanent_id
    car_id <-data$trips$car$id
    car_model <-data$trips$car$model
    car_make <-data$trips$car$make
    car_comfort <-data$trips$car$comfort
    car_comfort_stars <-data$trips$car$comfort_nb_star
    car_category <- data$trips$car$category
    freeway <- data$trips$freeway
    answer_delay <- data$trips$answer_delay
    bucketing <- data$trips$bucketing_eligible
    booking_mode <- data$trips$booking_mode
    booking_typ <- data$trips$booking_type
    view_count <- data$trips$view_count
    woman_only <- data$trips$viaggio_rosa
    #trip_plan <- unlist(data$trips$trip_plan)
    passengers <- data$trips$passengers
    car_picture <- data$trips$vehicle_pictures
    comfort <- data$trips$is_comfort
    stop_overs <- data$trips$stop_overs
    #depature_meeting_point <- data$trips$departure_meeting_point$name 
    #arrival_drop <- data$trips$arrival_meeting_point$name
    comment <- data$trips$comment
    
    
    
    trip <- as.data.frame(cbind(ride_urls, departure_date,date_passed,city_departure,address_departure ,lat_departure,long_departure ,city_arrival,address_arrival,lat_arrival ,  long_arrival,price,  price_no_comission,
                                seats_left,          seats,             seats_total,              duration_value,             distance_value,              permanent_id ,
                                car_id ,
                                car_model,
                                car_make ,
                                car_comfort ,
                                car_comfort_stars ,
                                car_category,
                                freeway ,
                                answer_delay ,
                                bucketing,
                                booking_mode,
                                booking_typ,
                                view_count ,
                                woman_only ,
                                passengers,
                                car_picture,
                                comfort ,
                                stop_overs ,
                                comment))
    
    trip$no_trips <- data$total_trip_count_to_display
    trip$full_trips <- data$full_trips_count
    trip$distance <- data$distance
    trip$duration <- data$duration
    trip$recommended_price <- data$recommended_price
    
    
    data_API = rbind.fill(data_API, trip)
    }
   } )
    
  }
  
#}








#Check other busy trips

#library(dplyr)
#trips <- clean_data %>% group_by(trip) %>% mutate(nobs = n()) %>%ungroup
#trips <- trips %>% select(trip, nobs) %>% group_by(trip) %>% slice(1)

pop_trips <- c("paris", "villeurbanne"	,"paris" ,"angers"	,"paris", "saint-herblain"	,	"tours", "paris",		"bron",  "paris"	,"angers", "paris"	,"paris", "venissieux",		"paris", "saint-priest"	,	"paris", "marcq-en-baroeul"		,	"paris", "vaulx-en-velin	","valenciennes", "paris"	,"reims", "paris",	"paris", "poitiers",	"reze", "paris","paris", "wattrelos",	"paris", "tourcoing","tourcoing", "paris","paris", "roubaix")

for(k in 1: length(date)){
  day = date[k]
  
  print(day)
  for(i in 1: 18){
    url <- paste0("https://public-api.blablacar.com/api/v2/trips?fn=",pop_trips[i],"&tn=",pop_trips[i+1],"&db=",day,"&cur=EUR&count=100&limit=50&key=YUDeUUu3E2frGD0xOurnTpFal3lBg2G6")
    tryCatch({
      remDr$navigate(url)
      data <- fromJSON(url)
      print(paste("Trip",pop_trips[i], " to ",pop_trips[i+1], "on day ", day, "number of rides ",as.numeric(data$total_trip_count_to_display)  ))
      if(as.numeric(data$total_trip_count_to_display) > 0){
        ride_urls <- data$trips$links$`_front`
        departure_date <- data$trips$departure_date
        date_passed <- data$trips$is_passed
        city_departure <- data$trips$departure_place$city_name
        address_departure <- data$trips$departure_place$address
        lat_departure <-data$trips$departure_place$latitude
        long_departure <-data$trips$departure_place$longitude
        city_arrival <- data$trips$arrival_place$city_name
        address_arrival <- data$trips$arrival_place$address
        lat_arrival <-data$trips$arrival_place$latitude
        long_arrival <-data$trips$arrival_place$longitude
        price <- data$trips$price_with_commission$value
        price_no_comission <- data$trips$price_without_commission$value
        seats_left <-data$trips$seats_left
        seats <- data$trips$seats
        seats_total <- data$trips$seats_count_origin
        duration_value <- data$trips$duration$value
        distance_value <- data$trips$distance$value
        permanent_id <- data$trips$permanent_id
        car_id <-data$trips$car$id
        car_model <-data$trips$car$model
        car_make <-data$trips$car$make
        car_comfort <-data$trips$car$comfort
        car_comfort_stars <-data$trips$car$comfort_nb_star
        car_category <- data$trips$car$category
        freeway <- data$trips$freeway
        answer_delay <- data$trips$answer_delay
        bucketing <- data$trips$bucketing_eligible
        booking_mode <- data$trips$booking_mode
        booking_typ <- data$trips$booking_type
        view_count <- data$trips$view_count
        woman_only <- data$trips$viaggio_rosa
        #trip_plan <- unlist(data$trips$trip_plan)
        passengers <- data$trips$passengers
        car_picture <- data$trips$vehicle_pictures
        comfort <- data$trips$is_comfort
        stop_overs <- data$trips$stop_overs
        #depature_meeting_point <- data$trips$departure_meeting_point$name 
        #arrival_drop <- data$trips$arrival_meeting_point$name
        comment <- data$trips$comment
        
        
        
        trip <- as.data.frame(cbind(ride_urls, departure_date,date_passed,city_departure,address_departure ,lat_departure,long_departure ,city_arrival,address_arrival,lat_arrival ,  long_arrival,price,  price_no_comission,
                                    seats_left,          seats,             seats_total,              duration_value,             distance_value,              permanent_id ,
                                    car_id ,
                                    car_model,
                                    car_make ,
                                    car_comfort ,
                                    car_comfort_stars ,
                                    car_category,
                                    freeway ,
                                    answer_delay ,
                                    bucketing,
                                    booking_mode,
                                    booking_typ,
                                    view_count ,
                                    woman_only ,
                                    passengers,
                                    car_picture,
                                    comfort ,
                                    stop_overs ,
                                    comment))
        
        trip$no_trips <- data$total_trip_count_to_display
        trip$full_trips <- data$full_trips_count
        trip$distance <- data$distance
        trip$duration <- data$duration
        trip$recommended_price <- data$recommended_price
        
        
        data_API = rbind.fill(data_API, trip)
      }
    } )
    
  }
  
}

##maybe add some cities green/red started on the 11th



departments <- read.csv("hotels-de-prefectures-fr.csv", sep = ";")

rouge<- c("Nord", "Pas-de-Calais", "Somme", "Oise", "Aisne", "Bas-Rhin", "Haut-Rhin", "Vosges", "Meurthe-et-Moselle", "Moselle", "Meuse", "Ardennes", "Marne", "Aube", "Haute-Marne", "Haute-SaÃ´ne" ,"CÃ´te-d'Or", "Jura", "Doubs", "Territoire de Belfort", "SaÃ´ne-et-Loire ", "NiÃ¨vre ", "Yonne", "Seine-et-Marne", "Essonne", "Yvelines", "Val-d'Oise", "Seine-Saint-Denis", "Val-de-Marne", "Hauts-de-Seine", "Paris")

departments$zone_rouge <- NA
for(i in 1:105){
  departments$zone_rouge[i] = ifelse(sum(departments$DeptNom[i] == rouge ) == 1, 1, 0)
  
}

departments <- as.data.frame(departments[1:97,])
departments$Commune = as.factor(departments$Commune)

departments$Commune = as.character(departments$Commune)

departments$Commune[10] <- "Charleville"
departments$Commune[18] <- "Angouleme"
departments$Commune[24] <- "Gueret"
departments$Commune[25] <- "Perigueux"
departments$Commune[26] <- "Besancon"
departments$Commune[28] <- "Evreux"
departments$Commune[31] <- "Nimes"
departments$Commune[37] <- "Chateauroux"
departments$Commune[43] <- "Saint-Etienne"
departments$Commune[46] <- "Orleans"
departments$Commune[51] <- "Saint-Lo"
departments$Commune[52] <- "Chalons-en-Champagne"
departments$Commune[62] <- "Alencon"
departments$Commune[72] <- "Macon"
departments$Commune[74] <- "Chambery"
departments$Commune[89] <- "Epinal"
departments$Commune[92] <- "Evry"
departments$Commune[95] <- "Creteil"
departments$Commune[19] <- "Rochelle"
departments$Commune[44] <- "Puy-en-Velay"
departments$Commune[73] <- "Mans"
departments$Commune[86] <- "Roche-sur-Yon"

#strat at 3 - Ajaccio and Bastia don't really have BBC
for(k in 1: length(date)){
  day = date[k]
  
  print(day)
  for(i in 1: 97){
    url <- paste0("http://public-api.blablacar.com/api/v2/trips?fn=",departments$Commune[i],"&db=",day,"&cur=EUR&count=100&limit=50&key=YUDeUUu3E2frGD0xOurnTpFal3lBg2G6")
    tryCatch({
      remDr$navigate(url)
      data <- fromJSON(url)
      print(paste("Trips from",departments$Commune[i], "on day ", day, "number of rides ",as.numeric(data$total_trip_count_to_display)  ))
      if(as.numeric(data$total_trip_count_to_display) > 0){
        ride_urls <- data$trips$links$`_front`
        departure_date <- data$trips$departure_date
        date_passed <- data$trips$is_passed
        city_departure <- data$trips$departure_place$city_name
        address_departure <- data$trips$departure_place$address
        lat_departure <-data$trips$departure_place$latitude
        long_departure <-data$trips$departure_place$longitude
        city_arrival <- data$trips$arrival_place$city_name
        address_arrival <- data$trips$arrival_place$address
        lat_arrival <-data$trips$arrival_place$latitude
        long_arrival <-data$trips$arrival_place$longitude
        price <- data$trips$price_with_commission$value
        price_no_comission <- data$trips$price_without_commission$value
        seats_left <-data$trips$seats_left
        seats <- data$trips$seats
        seats_total <- data$trips$seats_count_origin
        duration_value <- data$trips$duration$value
        distance_value <- data$trips$distance$value
        permanent_id <- data$trips$permanent_id
        car_id <-data$trips$car$id
        car_model <-data$trips$car$model
        car_make <-data$trips$car$make
        car_comfort <-data$trips$car$comfort
        car_comfort_stars <-data$trips$car$comfort_nb_star
        car_category <- data$trips$car$category
        freeway <- data$trips$freeway
        answer_delay <- data$trips$answer_delay
        bucketing <- data$trips$bucketing_eligible
        booking_mode <- data$trips$booking_mode
        booking_typ <- data$trips$booking_type
        view_count <- data$trips$view_count
        woman_only <- data$trips$viaggio_rosa
        #trip_plan <- unlist(data$trips$trip_plan)
        passengers <- data$trips$passengers
        car_picture <- data$trips$vehicle_pictures
        comfort <- data$trips$is_comfort
        stop_overs <- data$trips$stop_overs
        #depature_meeting_point <- data$trips$departure_meeting_point$name 
        #arrival_drop <- data$trips$arrival_meeting_point$name
        comment <- data$trips$comment
        
        
        
        trip <- as.data.frame(cbind(ride_urls, departure_date,date_passed,city_departure,address_departure ,lat_departure,long_departure ,city_arrival,address_arrival,lat_arrival ,  long_arrival,price,  price_no_comission,
                                    seats_left,          seats,             seats_total,              duration_value,             distance_value,              permanent_id ,
                                    car_id ,
                                    car_model,
                                    car_make ,
                                    car_comfort ,
                                    car_comfort_stars ,
                                    car_category,
                                    freeway ,
                                    answer_delay ,
                                    bucketing,
                                    booking_mode,
                                    booking_typ,
                                    view_count ,
                                    woman_only ,
                                    passengers,
                                    car_picture,
                                    comfort ,
                                    stop_overs ,
                                    comment))
        
        trip$no_trips <- data$total_trip_count_to_display
        trip$full_trips <- data$full_trips_count
        trip$distance <- data$distance
        trip$duration <- data$duration
        trip$recommended_price <- data$recommended_price
        
        
        data_API = rbind.fill(data_API, trip)
      }
    } )
    
  }
  
}



#when there are no trips means that nothing was posted

today = Sys.Date()

save(data_API, file = paste0("data_backup_",today))

