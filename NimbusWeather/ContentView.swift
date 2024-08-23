import SwiftUI

struct ContentView: View {
    @StateObject var weatherVM = jsonWebVM(context: PersistenceController.shared.container.viewContext)
    @StateObject var forecastVM = ForecastVM()
    var body: some View {
        NavigationView {
                    TabView {
                        FirstScreen()
                            .tabItem {
                                Label("Weather", systemImage: "mappin")
                            }
                            .environmentObject(weatherVM)
                            .environmentObject(forecastVM)

                         SecondScreen()
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                        .environmentObject(weatherVM)

                        ThirdScreen()
                            .tabItem {
                                Label("TBD", systemImage: "questionmark")
                            }
                    }
                }
    }
}

struct FirstScreen: View {
    @EnvironmentObject var weatherVM: jsonWebVM
    @EnvironmentObject var forecastVM: ForecastVM
    var body: some View {
        VStack(spacing: 20) {
            Text("Nimbus")
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .font(.system(size:36))
                .foregroundStyle(.cyan)
            VStack{
                Text("\(weatherVM.localtime)")
                    .padding(.top, 30.0)
                Text("\(weatherVM.cityName)")
                    
                    .font(.system(size:36))
                    .padding(.top, 10.0)
                
                Text("\(weatherVM.temperature)")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .font(.system(size:36))
                    .padding(0.0)
                Text("\(weatherVM.condition)")
                    .padding(.top, 5.0)
                RemoteImageView(urlString: weatherVM.icon)
                    .frame(width: 50, height: 50)
                Spacer()
                   }.frame(width: 350, height: 300)
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .onAppear {
                    weatherVM.fetchWeather(forCity:weatherVM.cityName)
                }
            

            VStack {
                            ScrollView {
                                VStack(spacing: 20) {
                                    ForEach(forecastVM.forecastDays, id: \.date) { day in
                                        VStack {
                                            Text(day.date)
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .padding(.bottom, 5)

                                            Text("Max: \(day.day.maxtemp_f, specifier: "%.1f")°F")
                                                .font(.subheadline)

                                            Text("Min: \(day.day.mintemp_f, specifier: "%.1f")°F")
                                                .font(.subheadline)

                                            Text("\(day.day.condition.text)")
                                                .font(.subheadline)
                                        }
                                        .frame(width: 200, height: 200)
                                        .background(Color.cyan)
                                        .cornerRadius(10)
                                        .foregroundColor(.white)
                                        
                                    }
                                }
                                .padding(.vertical, 10.0)
                            }
                            .padding(.vertical, 20.0)
                            .frame(height: 300.0)
                            
                        }
                        .frame(width: 350, height: 300)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
        }
        .padding()
        .onAppear {
                    forecastVM.fetchForecast(forCity: weatherVM.cityName)
                }
    }
    
}

struct SecondScreen: View {
    @State private var inputLocation: String = ""
    @State private var selected: String?
        @EnvironmentObject var weatherVM: jsonWebVM
        

        var body: some View {
            VStack {
                TextField("Enter Location", text: $inputLocation)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Search") {
                    weatherVM.fetchWeather(forCity: inputLocation)
                    weatherVM.addSearchedLocation(inputLocation)
                }
                .padding()

                List(weatherVM.searchedLocations, id: \.self) { location in
                                Button(action: {
                                    selected = location
                                    searchAndNavigateBack(for: location)
                                    
                                }) {
                                    Text(location).fontWeight(location == selected ? .bold : .regular)
                                }
                            }
            }
            .padding()
        }
    private func searchAndNavigateBack(for location: String) {
            weatherVM.fetchWeather(forCity: location)
            weatherVM.addSearchedLocation(location)
        }
}
struct ThirdScreen: View {
    @State private var moves = ["","","","","","","","",""]
    @State private var size = [(0..<3),(3..<6),(6..<9)]
    @State private var gameState = false
    var body: some View {
        VStack {
            Text("Weather Tic Tac Toe")
                .alert("Game Over!", isPresented: $gameState) {
                    Button("Reset", role:.destructive, action: reset)
                }
            Spacer()
            ForEach(size, id: \.self) {
                range in
                HStack {
                    ForEach(range, id: \.self) {
                        i in
                        TicTacToeSquare(letter: $moves[i])
                            .simultaneousGesture(TapGesture()
                                .onEnded{_ in
                                    playerTap(index: i)
                                }
                                    )
                    }
                }
            }
            Spacer()
            Button("Reset") {
                reset()
            }
        }
    }
    func reset() {
        
        moves = ["","","","","","","","",""]
    }
    func playerTap(index: Int) {
        if moves[index] == "" {
            moves[index] = "X"
            botMove()
        }
        for letter in ["X", "O"] {
            if checkWinner(list: moves, letter: letter) {
                gameState = true
                break
            }
        }
    }
    func botMove() {
        var availableMoves: [Int] = []
        var movesRemain = 0
        
        for move in moves {
            if move == "" {
                availableMoves.append(movesRemain)
            }
            movesRemain += 1
        }
        if availableMoves.count != 0 {
            moves[availableMoves.randomElement()!] = "O"
        }
    }
}
//struct ThirdScreen: View {
//    @State private var game = TicTacToeGame()
//
//        var body: some View {
//
//            VStack(spacing: 5) {
//                ForEach(0..<3, id: \.self) { row in
//                    HStack(spacing: 5) {
//                        ForEach(0..<3, id: \.self) { column in
//                            TicTacToeSquare(player: game.board[row][column])
//                                .frame(width: 60, height: 60)
//                                .background(Color.gray)
//                                .cornerRadius(10)
//                                .onTapGesture {
//                                    _ = game.makeMove(row: row, column: column)
//                                }
//                        }
//                    }
//                }
//            }
//            .padding()
//        }
//}
struct TicTacToeSquare: View {
    @Binding var letter: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .frame(width:120, height:120)
                .foregroundColor(.gray)
            if letter == "O" {
                Image(systemName: "sun.max")
                    .resizable()
                    .scaledToFit()
            } else if letter == "X" {
                Image(systemName: "cloud")
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}
struct RemoteImageView: View {
    @State private var image: UIImage? = nil
    let urlString: String

    var body: some View {
        Image(uiImage: image ?? UIImage(systemName: "photo")!)
            .resizable()
            .onAppear(perform: loadImage)
    }

    private func loadImage() {
        guard let url = URL(string: "https:\(urlString)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let downloadedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = downloadedImage
                }
            }
        }.resume()
    }
}

#Preview {
    ContentView()
}
