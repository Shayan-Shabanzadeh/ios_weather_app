
import SDWebImageSwiftUI
import SwiftUI

//struct ContentView: View {
//    @StateObject  var forecastListVM = ForecastListViewModel()
//    var body: some View {
//        ZStack {
//            NavigationView {
//                VStack {
//                    Picker(selection: $forecastListVM.system, label: Text("System")) {
//                        Text("°C").tag(0)
//                        Text("°F").tag(1)
//                    }
//                    .pickerStyle(SegmentedPickerStyle())
//                    .frame(width: 100)
//                    .padding(.vertical)
//                    HStack {
//                        TextField("Enter Location", text: $forecastListVM.location,
//                                  onCommit: {
//                                    forecastListVM.getWeatherForecast()
//                                  })
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                            .overlay (
//                                Button(action: {
//                                    forecastListVM.location = ""
//                                    forecastListVM.getWeatherForecast()
//                                }) {
//                                    Image(systemName: "xmark.circle")
//                                        .foregroundColor(.gray)
//                                }
//                                .padding(.horizontal),
//                                alignment: .trailing
//                            )
//                        Button {
//                            forecastListVM.getWeatherForecast()
//                        } label: {
//                            Image(systemName: "magnifyingglass.circle.fill")
//                                .font(.title3)
//                        }
//                    }
//                    List(forecastListVM.forecasts, id: \.day) { day in
//                            VStack(alignment: .leading) {
//                                Text(day.day)
//                                    .fontWeight(.bold)
//                                HStack(alignment: .center) {
//                                    WebImage(url: day.weatherIconURL)
//                                        .resizable()
//                                        .placeholder {
//                                            Image(systemName: "hourglass")
//                                        }
//                                        .scaledToFit()
//                                        .frame(width: 75)
//                                    VStack(alignment: .leading) {
//                                        Text(day.overview)
//                                            .font(.title2)
//                                        HStack {
//                                            Text(day.high)
//                                            Text(day.low)
//                                        }
//                                        HStack {
//                                            Text(day.clouds)
//                                            Text(day.pop)
//                                        }
//                                        Text(day.humidity)
//                                    }
//                                }
//                            }
//                        }
//                        .listStyle(PlainListStyle())
//                }
//                .padding(.horizontal)
//                .navigationTitle("Mobile Weather")
//                .alert(item: $forecastListVM.appError) { appAlert in
//                    Alert(title: Text("Error"),
//                          message: Text("""
//                            \(appAlert.errorString)
//                            Please try again later!
//                            """
//                            )
//
//                    )
//                }
//            }
//            if forecastListVM.isLoading {
//                ZStack {
//                    Color(.white)
//                        .opacity(0.3)
//                        .ignoresSafeArea()
//                    ProgressView("Fetching Weather")
//                        .padding()
//                        .background(
//                            RoundedRectangle(cornerRadius: 10)
//                                .fill(Color(.systemBackground))
//                        )
//                        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/ )
//                }
//            }
//        }
//    }
//}


struct ContentView: View {
    var body: some View {
        TabView {
            MainApplicationView()
                .tabItem {
                    Label("Main", systemImage: "house")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct City: Identifiable {
    let id = UUID()
    let name: String
}

struct MainApplicationView: View {
    let popularCities = [City(name: "London"), City(name: "Paris"), City(name: "New York"), City(name: "Tokyo"), City(name: "Sydney")]
    
    @StateObject private var weatherService = WeatherService()
    @State private var selectedCity: City? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Popular Cities")
                    .font(.title)
                    .padding(.top)
                
                List(popularCities) { city in
                    if let forecast = weatherService.forecasts[city.name] {
                        Button(action: {
                            selectedCity = city
                        }) {
                            VStack(alignment: .leading) {
                                Text(city.name)
                                    .fontWeight(.bold)
                                HStack(alignment: .center) {
                                    WebImage(url: forecast.weatherIconURL)
                                        .resizable()
                                        .placeholder {
                                            Image(systemName: "hourglass")
                                        }
                                        .scaledToFit()
                                        .frame(width: 75)
                                    VStack(alignment: .leading) {
                                        Text(forecast.overview)
                                            .font(.title2)
                                        HStack {
                                            Text(forecast.high)
                                            Text(forecast.low)
                                        }
                                        HStack {
                                            Text(forecast.clouds)
                                            Text(forecast.pop)
                                        }
                                        Text(forecast.humidity)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .sheet(item: $selectedCity, onDismiss: {
                    // Code to perform when the sheet is dismissed
                }) { city in
                    if let forecast = weatherService.forecasts[city.name] {
                        WeatherDetailView(city: city.name)
                    }
                }
            }
            .onAppear {
                weatherService.getWeathersByCitiesList(cities: popularCities.map { $0.name })
            }
            .navigationTitle("Weather")
        }
    }
}



struct WeatherDetailView: View {
    let city: String
    @ObservedObject private var cityService = CityService()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text(city)) {
                    ForEach(cityService.forecasts, id: \.day) { forecast in
                        VStack(alignment: .leading) {
                            Text("Date: \(forecast.day)")
                                .font(.headline)
                                .padding(.vertical, 4)
                            // Display daily forecast details here
                            WebImage(url: forecast.weatherIconURL)
                                .resizable()
                                .placeholder {
                                    Image(systemName: "hourglass")
                                }
                                .scaledToFit()
                                .frame(width: 75)
                            Text(forecast.overview)
                                .font(.title2)
                            HStack {
                                Text("High: \(forecast.high)")
                                Text("Low: \(forecast.low)")
                            }
                            HStack {
                                Text("Clouds: \(forecast.clouds)")
                                Text("POP: \(forecast.pop)")
                            }
                            Text("Humidity: \(forecast.humidity)")
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Weather Detail")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .onAppear {
            cityService.getWeatherForCity(city: city)
        }
    }
}













struct SettingsView: View {
    var body: some View {
        // Your settings content goes here
        Text("Settings")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

