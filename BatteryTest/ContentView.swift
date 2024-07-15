//
//  ContentView.swift
//  BatteryTest
//
//  Created by Pasquale Nardiello on 05/07/24.
//

import SwiftUI
import Foundation
import Combine

class BatteryInfoManager: ObservableObject {
    @Published var batteryInfo: BatteryInfo
    
    private var timer: AnyCancellable?
    
    init() {
        self.batteryInfo = getBatteryInfo()
        startUpdating()
    }
    
    func startUpdating() {
        timer = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateBatteryInfo()
            }
    }
    
    func updateBatteryInfo() {
        self.batteryInfo = getBatteryInfo()
    }
}

struct StylishMosaicTileView: View {
    let color: Color
    let title: String
    let value: Int
    let maxValue: Int
    
    private var progress: Double {
        return Double(value) / Double(maxValue)
    }
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 5)
            ZStack {
                Circle()
                    .stroke(lineWidth: 5)
                    .foregroundColor(color.opacity(0.2))
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .foregroundColor(color)
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 130, height: 60)
            Text("\n\(value) / \(maxValue)")
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [color.opacity(0.4), color.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .cornerRadius(25)
                .shadow(color: color.opacity(0.6), radius: 10, x: 0, y: 5)
        )
        .padding(5)
    }
}

struct StylishMosaicView: View {
    let batteryInfo: BatteryInfo
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                StylishMosaicTileView(color: .red, title: "Voltage", value: batteryInfo.voltage, maxValue: 25000)
                StylishMosaicTileView(color: .green, title: "Current Capacity", value: batteryInfo.currentCapacity, maxValue: batteryInfo.designCapacity)
            }
            HStack(spacing: 10) {
                StylishMosaicTileView(color: .cyan, title: "Max Capacity", value: batteryInfo.maxCapacity, maxValue: batteryInfo.designCapacity)
                StylishMosaicTileView(color: .orange, title: "Temperature", value: batteryInfo.temp, maxValue: 50)
            }
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [.black, .gray]), startPoint: .top, endPoint: .bottom)
                .cornerRadius(0)
                .shadow(color: .black.opacity(0.8), radius: 15, x: 0, y: 10)
                .frame(width: 400, height: 400)
        )
    }
}

struct FixedSizeWindowModifier: ViewModifier {
    let width: CGFloat
    let height: CGFloat

    func body(content: Content) -> some View {
        content
            .frame(width: width, height: height)
            .background(WindowAccessor { window in
                window?.styleMask.remove(.resizable)
                window?.setContentSize(NSSize(width: width, height: height))
            })
    }
}

extension View {
    func fixedSizeWindow(width: CGFloat, height: CGFloat) -> some View {
        self.modifier(FixedSizeWindowModifier(width: width, height: height))
    }
}

private struct WindowAccessor: NSViewRepresentable {
    var callback: (NSWindow?) -> Void

    func makeNSView(context: Context) -> NSView {
        let nsView = NSView()
        DispatchQueue.main.async {
            self.callback(nsView.window)
        }
        return nsView
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

struct ContentView: View {
    @StateObject private var batteryInfoManager = BatteryInfoManager()
    var body: some View {
        StylishMosaicView(batteryInfo: batteryInfoManager.batteryInfo)
            .fixedSizeWindow(width: 400, height: 400) // Adjust width and height as needed
            .navigationTitle("Battery Test")
    }
}

/*
@main
struct BatteryTestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}*/

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
