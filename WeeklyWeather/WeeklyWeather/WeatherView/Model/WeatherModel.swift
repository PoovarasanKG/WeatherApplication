import Foundation

struct WeatherData: Decodable {
    var current: Current? = Current()
    var forecast: Forecast? = Forecast()
}

struct Current: Decodable {
    var temp_c: Double = 0.0
    var is_day: Int = 0
}

struct Forecast: Decodable {
    var forecastday: [ForecastDay] = []
}

struct ForecastDay: Decodable {
    var date: String = ""
    var day: Day = Day()
}

struct Day: Decodable {
    var avgtemp_c: Double = 0.0
    var maxtemp_c: Double = 0.0
    var mintemp_c: Double = 0.0
    var condition: Condition? = Condition()
}


struct Condition: Decodable {
    var text : String = ""
    var icon : String = ""
}



