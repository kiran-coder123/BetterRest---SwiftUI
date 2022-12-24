//
//  ContentView.swift
//  SleepCalculatorApp
//
//  Created by Kiran Sonne on 21/11/22.
//

import CoreML
import SwiftUI


struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var  sleepAmount = 8.0
    @State private var  coffeAmount = 1
    @State var cupSize = [1, 2, 3, 4,5,6,7,8,9,10]
    
    @State var selectedCup = 1
    @State private var titleAlert = ""
    @State private var messageAlert = ""
    @State private var showingAlert = false
    
   static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
        
    }
    var body: some View {
        NavigationView {
            Form {
                 
                Section {
                Text("when do you want to wake up?")
                    .font(.headline)
                DatePicker("please enter a time",selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                }
               Section {
                Text("Desired amount of sleep")
                    .font(.headline)
                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                Section {
                Text("Daily Coffe Intake")
                    .font(.headline)
                    .bold()
                    
                    //MARK: Using Picker
                    Picker("select a cup of Cofffe ", selection: $selectedCup){
                        ForEach(cupSize,id: \.self) { cup in
                            Text("\(cup)")
                        }
                    }
                    .pickerStyle(.menu)
                    
                    //MARK: Using Stepper
                    
                    
//                 Stepper(coffeAmount == 1 ? "1 Cup" : "\(coffeAmount) cups", value: $coffeAmount, in: 1...20)
                }
                    .alert(titleAlert, isPresented: $showingAlert) {
                        Button("Ok") { }
                    } message: {
                        Text(messageAlert)
                    }
            }
            .navigationTitle("Better Rest")
            .toolbar {
                Button("Calculate", action: calculateBedTime)
                    .foregroundColor(.blue)
                    .font(.headline)
                    
            }
        }
        
    }
    func calculateBedTime(){
        
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            titleAlert = "Your Ideal bedtime "
            messageAlert = sleepTime.formatted(date: .omitted, time: .shortened)
            
            showingAlert = true
        } catch   {
             titleAlert = "Error"
            messageAlert = "Sorry, there was a problem calculating your bedtime."
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    
    }
}
