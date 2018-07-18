//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation // Allows to access the GPS location of the phone
import SwiftyJSON
import Alamofire




// Here, CLLocationManager : How we will handle the Location Data
class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate{
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather" // the url to get the weather data.
    let APP_ID = "f8fcdade016440c5ab012e3f29edd389"
    

    //TODO: Declare instance variables here
      //creates an instance. Meaning an Object.
    let locationManager = CLLocationManager();
    let weatherData = WeatherDataModel()
    
    

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBAction func Navigator(_ sender: UIButton) {
        performSegue(withIdentifier : "goToSecondScreen" , sender: self)
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This is the line that sets your class as a delegate (a volunteer). Meaning tell the CLlocation that
        // when you get the Location Data, inform me. I need the data, so Please do... Inform me...!!
        locationManager.delegate = self
        
        // Remember to do this always whenever you are using CLLocation !!. Also, Note that the more accuracy you crave
        // for , the more time and memory it will consume.
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // POP-UP that will ask the user to allow us to use their location of the phone. Also make sure to
        // update the Plist.. 
        locationManager.requestWhenInUseAuthorization()
        
        /* This method is an asychronous method. Now, it starts getting the location */
        locationManager.startUpdatingLocation()
        
        
        
        
        
        
        //TODO:Set up the location manager here.
    
        
        
    }
    
    
    
    
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherFromApi (parameters : [String:String]) {
        Alamofire.request(WEATHER_URL, method: .get, parameters : parameters).responseJSON{
            response in
            if response.result.isSuccess {
        // Since the data you recieve from the request is of Type (Any), you have to convert it to the Json.
                let jsonData :JSON = JSON(response.result.value!)
                print(jsonData)
            // Now, since you have the data, you will have to parse it and save it
                // Note : Whenever you see "in" and your code is inside it, then you have to use self
                self.updateWeatherData(data : jsonData)
            }
            else {
                print (response.result.error!)
                self.cityLabel.text = "Connection Issues"
            }
        }
      
        
    }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    // Here, we will get the Json data and the we will update the weather class.
    
    //Write the updateWeatherData method here:
    func updateWeatherData (data : JSON){
        
        if let temp = data ["main"]["temp"].double {
        weatherData.temperature = Int (temp - 273.15)
        weatherData.city = data["name"].stringValue
        weatherData.condition = data ["weather"][0]["id"].intValue
        weatherData.iconName = weatherData.updateWeatherIcon(condition: weatherData.condition)
            updateUIWeatherData()
        }
        else {
            cityLabel.text = "Weather Unavailable"
        }
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWeatherData(){
        print (weatherData.city)
        cityLabel.text = weatherData.city
        temperatureLabel.text = String(weatherData.temperature)+"°"
        weatherIcon.image = UIImage(named : weatherData.iconName)
    }
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    // Only one of them will be executed dependent on the situation..
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // We are doing this because we want to best accuracy and it will be at the last.
        let location = locations[locations.count-1]
        
        // We will get the location but what if it's not accurate? So, lets check it.
        if (location.horizontalAccuracy > 0 ){
            /* IMPORTANT : You will have to use this to stop the process as the process heavily consists of heavy memory usage and consumes
            users phone battery a lot.. So, ALWAYS, always, Always make sure to use this whenever dealing with the GPs location */
            locationManager.stopUpdatingLocation()
        }
        let latitude = String(location.coordinate.latitude)
        let longtitude = String(location.coordinate.longitude)
        // Now pass the location as a parameter. It is a dictionary.
        let params : [String:String] = ["lat": latitude , "lon" : longtitude , "appid" : APP_ID]
        getWeatherFromApi (parameters: params) // Send the parameters and then it uses that to get the Data.
    }
    
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print (error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func useTheCityName (city : String){
        let parameters: [String : String] = ["q" : city , "appid" : APP_ID] //gets the data by city name
        getWeatherFromApi(parameters: parameters)
        
        
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSecondScreen" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
            
        }
    }
    
    
    
    
}


