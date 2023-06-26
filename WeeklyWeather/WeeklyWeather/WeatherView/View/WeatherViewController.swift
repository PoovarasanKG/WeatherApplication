import UIKit
import CoreLocation
import MapKit


class WeatherViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var cityCellsiusLabel: UILabel!
    @IBOutlet weak var weatherTableView: UITableView!
    @IBOutlet weak var hourWeatherTableViewCell: UITableView!
    @IBOutlet weak var currentWeatherCondition: UILabel!
    @IBOutlet weak var highAndLowTemp: UILabel!
    
    
    var whetherData: WeatherData?
    var cityName: String? = ""
    var labelTextColor: UIColor?
    
    let locationManager = CLLocationManager()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // To request location authorization always
        locationManager.requestAlwaysAuthorization()
        // To request location authorization when the app is in use
        locationManager.requestWhenInUseAuthorization()
        
        weatherTableView.register(UINib(nibName: "WeatherTableViewCell", bundle: nil), forCellReuseIdentifier:"WeatherTableViewCell")
        DispatchQueue.main.async {
            self.weatherTableView.reloadData()
        }
        
        
        getCurrentLocation()
        setBackgroundImageForTimeOfDay()
        
    }
    
    
    //MARK: - Collect data From open api
    func fetchData(city: String) {
        
        if let url = URL(string: "https://api.weatherapi.com/v1/forecast.json?q=\(city)&days=7&key=17262384a5f3403b8bb124218231306") {
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                
                if let data = data {
                    do {
                        let responseData = try JSONDecoder().decode(WeatherData.self, from: data)
                        DispatchQueue.main.async {
                            self.whetherData = responseData
                            self.cityCellsiusLabel.text = (self.whetherData?.current?.temp_c.description ?? "") + "°"
                            self.cityCellsiusLabel.font = UIFont.boldSystemFont(ofSize: 75)
                            self.currentWeatherCondition.text = (self.whetherData?.forecast?.forecastday[0].day.condition?.text)
                            self.highAndLowTemp.text = "H:" + (self.whetherData?.forecast?.forecastday[0].day.maxtemp_c.description ?? "") + "°" + "   L:" + (self.whetherData?.forecast?.forecastday[0].day.mintemp_c.description ?? "") + "°"
                            self.weatherTableView.reloadData()
                            //print(self.whetherData)
                        }
                    } catch let error {
                        print(error)
                        
                    }
                }
            }.resume()
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return whetherData?.forecast?.forecastday.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let weatherTableViewCell: WeatherTableViewCell = tableView.dequeueReusableCell(withIdentifier: "WeatherTableViewCell", for: indexPath) as! WeatherTableViewCell
        
        let inputDate = whetherData?.forecast?.forecastday[indexPath.row].date ?? ""
        weatherTableViewCell.dayLabel.text = getDay(date: inputDate)
        weatherTableViewCell.dayLabel.font = UIFont.systemFont(ofSize: 17)
        weatherTableViewCell.dayHighlightImageView.isHidden = !isToday(inputDate: inputDate)
        weatherTableViewCell.cellsiusLabel.text = (whetherData?.forecast?.forecastday[indexPath.row].day.avgtemp_c.description ?? "") + "°"
        weatherTableViewCell.cellsiusLabel.font = UIFont.systemFont(ofSize: 16)
        

        if let url = URL(string: "https:" + (self.whetherData?.forecast?.forecastday[indexPath.row].day.condition?.icon ?? "")) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                // Error handling...
                guard let imageData = data else { return }
                
                DispatchQueue.main.async {
                    weatherTableViewCell.weatherImageView.image = UIImage(data: imageData)
                }
            }.resume()
        }
        
        return weatherTableViewCell
    }
    
    
    
    
    // MARK: Todays Day and API Day checks function
    func getDay(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: date) {
            dateFormatter.dateFormat = "EEEE"
            let resultString = dateFormatter.string(from: date)
            return resultString
        }
        
        return ""
    }

    func isToday(inputDate: String) -> Bool {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let result = dateFormatter.string(from: date)
        return result == inputDate
    }
    
    

    
    // MARK: Location Service & convert city name
    func getCurrentLocation(){
        // location manager to update access map and get lang&lant & below ()to we get city name
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    // The location manager will update the delegate function
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocation = manager.location else { return }
        fetchCityAndCountry(from: location) { city, country, error in
            guard let city = city, let country = country, error == nil else { return }
            print(city + ", " + country)
            self.cityNameLabel.text = city
            self.cityNameLabel.font = UIFont.italicSystemFont(ofSize: 30)
            self.fetchData(city: city)
            
        }
    }
    
    // To get the city and country from a longitude and latitude, and update in upper delegate method
    func fetchCityAndCountry(from location: CLLocation, completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.locality,
                       placemarks?.first?.country,
                       error)
        }
    }
    
    
    
    //MARK: Day and Night background Color Changer
    func setBackgroundImageForTimeOfDay() {
        let currentDate = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentDate)

        var backgroundImage: UIImage?
        var labelTextColor: UIColor?

        if hour >= 6 && hour < 18 {
            // Daytime
            backgroundImage = UIImage(named: "sunRaiceImage")
            
        } else {
            // Nighttime
            backgroundImage = UIImage(named: "nightImage")
            labelTextColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0) // Light gray color
        }

        if let backgroundImage = backgroundImage {
            backgroundImageView.image = backgroundImage
        }
        weatherTableView.reloadData()
        
        cityNameLabel.textColor = labelTextColor
        cityCellsiusLabel.textColor = labelTextColor
        
    }
    
    
}
    

