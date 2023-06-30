
import SDWebImageSwiftUI
import SwiftUI


struct ContentView: View {
    @State private var maxCities = 5 // Declare a @State variable
    
    var body: some View {
        TabView {
            MainApplicationView(maxCities: $maxCities) // Pass maxCities as a binding
                .tabItem {
                    Label("Main", systemImage: "house")
                }
            
            SettingsView(maxCities: $maxCities) // Pass maxCities as a binding
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
struct City: Identifiable , Equatable {
    let id = UUID()
    let name: String
    static func == (lhs: City, rhs: City) -> Bool {
        return lhs.id == rhs.id
    }
}

enum SortOption {
    case name
    case highTemperature
    case lowTemperature
}


struct MainApplicationView: View {
    @State private var popularCities: [City] = [City(name: "London"), City(name: "Paris"), City(name: "New York"), City(name: "Tokyo"), City(name: "Sydney")]
    @Binding var maxCities: Int // Add maxCities as a binding parameter

    @StateObject private var weatherService = WeatherService()
    @StateObject private var cityService = CityService()
    @State private var selectedCity: City? = nil
    @State private var isAddingCity = false
    @State private var newCityName = ""
    @State private var sortOption: SortOption = .name
    var body: some View {
        NavigationView {
            VStack {
                Picker("Sort by", selection: $sortOption) {
                    Text("Name").tag(SortOption.name)
                    Text("High Temperature").tag(SortOption.highTemperature)
                    Text("Low Temperature").tag(SortOption.lowTemperature)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Text("Popular Cities")
                    .font(.title)
                    .padding(.top)

                List {
                    ForEach(popularCities.sorted(by: getSortPredicate())) { city in
                        if let forecast = weatherService.forecasts[city.name] {
                            NavigationLink(destination: WeatherDetailView(city: city.name)) {
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
                    .onDelete(perform: removeCity)
                }
                .listStyle(PlainListStyle())
                .navigationBarItems(trailing: Button(action: {
                    isAddingCity = true
                }) {
                    Image(systemName: "plus")
                })
            }
            .onAppear {
                weatherService.getWeathersByCitiesList(cities: popularCities.map { $0.name })
                
            }
            .navigationTitle("Weather")
            .sheet(isPresented: $isAddingCity, content: {
                addCitySheet
            })
        }
        .onChange(of: maxCities) { newValue in
            if popularCities.count > newValue {
                popularCities = Array(popularCities.prefix(newValue))
            }
        }
    }
    
    func removeCity(at offsets: IndexSet) {
        popularCities.remove(atOffsets: offsets)
    }
    
    var addCitySheet: some View {
        NavigationView {
            VStack {
                TextField("Enter city name", text: $newCityName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Add City")
            .navigationBarItems(
                leading: Button(action: {
                    isAddingCity = false
                }) {
                    Text("Cancel")
                },
                trailing: Button(action: {
                    addCity()
                    isAddingCity = false
                    newCityName = ""
                }) {
                    Text("Add")
                }
                .disabled(newCityName.isEmpty)
            )
        }
    }
    
    func addCity() {
        let trimmedCityName = newCityName.trimmingCharacters(in: .whitespacesAndNewlines)
        let city = City(name: trimmedCityName)
        
        if popularCities.count >= maxCities {
            // Show error message when maxCities is reached
            // Modify this part according to how you want to display the error message
            print("Error: Max number of cities reached")
        } else {
            popularCities.append(city)
            weatherService.getWeathersByCitiesList(cities: popularCities.map { $0.name })
        }
        
        // Reset the new city name field
        newCityName = ""
    }

    
    func getSortPredicate() -> (City, City) -> Bool {
        switch sortOption {
        case .name:
            return { $0.name < $1.name }
        case .highTemperature:
            return { city1, city2 in
                let forecast1 = weatherService.forecasts[city1.name]
                let forecast2 = weatherService.forecasts[city2.name]
                return forecast1?.high ?? "" < forecast2?.high ?? ""
            }
        case .lowTemperature:
            return { city1, city2 in
                let forecast1 = weatherService.forecasts[city1.name]
                let forecast2 = weatherService.forecasts[city2.name]
                return forecast1?.low ?? "" < forecast2?.low ?? ""
            }
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
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Binding var maxCities: Int // Add maxCities as a binding parameter
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                }
                
                Section(header: Text("Maximum Cities")) {
                    Stepper(value: $maxCities, in: 1...10) {
                        Text("Maximum Cities: \(maxCities)")
                    }
                }
                
                Section {
                    Button(action: {
                        exit(0) // Exit the application
                    }) {
                        Text("Logout")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .navigationTitle("Settings")
        }
    }
}






struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

