import Foundation

struct SportModel: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String

    static let samples = [
        SportModel(name: "Running", icon: "figure.run", description: "Build a steady rhythm, one kilometre at a time."),
        SportModel(name: "Cycling", icon: "figure.outdoor.cycle", description: "Explore new routes and enjoy the ride."),
        SportModel(name: "Strength", icon: "figure.strengthtraining.traditional", description: "Feel stronger with simple, focused sessions.")
    ]
}
