//
//  NimbusWeatherApp.swift
//  NimbusWeather
//
//  Created by Saad Kadhi on 11/21/23.
//

import SwiftUI
import CoreData

@main
struct NimbusWeatherApp: App {
    let persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "SearchedLocations")
            container.loadPersistentStores { storeDescription, error in
                if let error = error as NSError? {
                    fatalError("Error \(error)")
                }
            }
            return container
        }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
