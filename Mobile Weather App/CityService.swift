import Foundation
import CoreLocation
import SwiftUI

class CityService: ObservableObject {
    struct AppError: Identifiable {
        let id = UUID().uuidString
        let errorString: String
    }
    
    @Published var forecasts: [ForecastViewModel] = []
    @Published var isLoading: Bool = false
    @Published var appError: AppError?
    
    var system: Int = 0
    
    func getWeatherForCity(city: String) {
        UIApplication.shared.endEditing()
        isLoading = true
        
        CLGeocoder().geocodeAddressString(city) { (placemarks, error) in
            if let error = error as? CLError {
                switch error.code {
                case .locationUnknown, .geocodeFoundNoResult, .geocodeFoundPartialResult:
                    DispatchQueue.main.async {
                        self.appError = AppError(errorString: NSLocalizedString("Unable to determine location from this text.", comment: ""))
                        self.isLoading = false
                    }
                case .network:
                    DispatchQueue.main.async {
                        self.appError = AppError(errorString: NSLocalizedString("You do not appear to have a network connection.", comment: ""))
                        self.isLoading = false
                    }
                default:
                    DispatchQueue.main.async {
                        self.appError = AppError(errorString: error.localizedDescription)
                        self.isLoading = false
                    }
                }
                
                print(error.localizedDescription)
            }
            
            if let lat = placemarks?.first?.location?.coordinate.latitude,
               let lon = placemarks?.first?.location?.coordinate.longitude {
                // Don't forget to use your own key
                let apiService = APIServiceCombine.shared
                apiService.getJSON(urlString: "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lon)&exclude=current,minutely,hourly,alerts&appid=9bfe68c3e80b6b827a5a11303d371ba3",
                                   dateDecodingStrategy: .secondsSince1970) { (result: Result<Forecast, APIServiceCombine.APIError>) in
                    switch result {
                    case .success(let forecast):
                        let forecastViewModels = forecast.daily.map { ForecastViewModel(forecast: $0, system: self.system) }
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.forecasts = forecastViewModels
                        }
                    case .failure(let apiError):
                        switch apiError {
                        case .error(let errorString):
                            DispatchQueue.main.async {
                                self.appError = AppError(errorString: errorString)
                                self.isLoading = false
                            }
                            print(errorString)
                        }
                    }
                }
            }
        }
    }
}
