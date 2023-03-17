//
//  ContentView.swift
//  betterRest
//
//  Created by Kamil Wójcicki on 10/03/2023.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmont = 8.0
    @State private var coffeAmount = 1
    
    @State private var allertTitle = ""
    @State private var allertMessage = ""
    @State private var showingAllert = false
    
    static var defaultWakeTime: Date{
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    var body: some View {
        NavigationView{
            Form{
                VStack(alignment: .leading, spacing: 0){
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                VStack(alignment: .leading, spacing: 0){
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmont.formatted()) hours", value: $sleepAmont, in: 4...12, step: 0.25)
                }
                VStack(alignment: .leading, spacing: 0){
                    Text("Daily coffee intake")
                        .font(.headline)
                    Stepper(coffeAmount == 1 ? "1 cup" : "\(coffeAmount) cups", value: $coffeAmount, in: 1...20)
                }
            }
            .navigationTitle("BetterRest")
            .toolbar{
                Button("Calculate", action: calculateBedtime)
            }
            .alert(allertTitle, isPresented: $showingAllert){
                Button("OK"){}
            }message: {
                Text(allertMessage)
            }
        }
    }
    func calculateBedtime(){
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmont, coffee: Double(coffeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            allertTitle = "Your ideal bedtime is..."
            allertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        }catch{
            allertTitle = "Error"
            allertMessage = "Sorry there was a problem calculating your bed time."
        }
        showingAllert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
