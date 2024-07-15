import WidgetKit
import SwiftUI

struct BatteryEntry: TimelineEntry {
    let date: Date
    let batteryInfo: BatteryInfo
}

struct BatteryProvider: TimelineProvider {
    func placeholder(in context: Context) -> BatteryEntry {
        BatteryEntry(date: Date(), batteryInfo: getBatteryInfo())
    }

    func getSnapshot(in context: Context, completion: @escaping (BatteryEntry) -> Void) {
        let entry = BatteryEntry(date: Date(), batteryInfo: getBatteryInfo())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BatteryEntry>) -> Void) {
        var entries: [BatteryEntry] = []
        
        let currentDate = Date()
        for offset in 1..<2 {
            let entryDate = Calendar.current.date(byAdding: .second, value: offset * 5, to: currentDate)!
            let entry = BatteryEntry(date: entryDate, batteryInfo: getBatteryInfo())
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct BatteryWidgetEntryView: View {
    var entry: BatteryProvider.Entry
    
    @Environment(\.colorScheme) var colorScheme
    
    var gradientBackground: LinearGradient {
        if entry.batteryInfo.charging {
            LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(0.5), Color.green.opacity(0.7)]),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        }
        else {
            LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(0.5), Color.cyan.opacity(0.7)]),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        }
    }
    
    var altGradientBackground: LinearGradient {
        if entry.batteryInfo.charging {
            LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(0.5), Color.green.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        else {
            LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(0.5), Color.cyan.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var currPerc: Int {
        Int(Double(entry.batteryInfo.currentCapacity) / Double(entry.batteryInfo.designCapacity) * 100)
    }
    
    var maxPerc: Int {
        Int(Double(entry.batteryInfo.maxCapacity) / Double(entry.batteryInfo.designCapacity) * 100)
    }
    
    @Environment(\.widgetFamily) var widgetFamily
        
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        default:
            largeView
        }
    }
    
    var smallView: some View {
        VStack {
            if entry.batteryInfo.charging {
                SingleRingGaugeView(charge: entry.batteryInfo.charging, maxCapacity: entry.batteryInfo.maxCapacity, designCapacity: entry.batteryInfo.designCapacity, c1: Color.green)
            }
            else {
                SingleRingGaugeView(charge: entry.batteryInfo.charging, maxCapacity: entry.batteryInfo.maxCapacity, designCapacity: entry.batteryInfo.designCapacity, c1: Color.cyan)
            }
        }
        .padding()
        .containerBackground(gradientBackground, for: .widget)  // Widget's semi-transparent background
        .cornerRadius(15)
    }

    var mediumView: some View {
        HStack {
            DoubleRingGaugeView(charge: entry.batteryInfo.charging, currentCapacity: entry.batteryInfo.currentCapacity, maxCapacity: entry.batteryInfo.maxCapacity, designCapacity: entry.batteryInfo.designCapacity, c1: Color.orange, c2: Color.purple)
                            .frame(height: 100)
            VStack {
                Text("Curr. Charge: \(currPerc)%")
                    .font(.body)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Color.orange.opacity(0.5))
                    .cornerRadius(10)
                    .fixedSize()
                Text("Eff. Charge: \(maxPerc)%")
                    .font(.body)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Color.purple.opacity(0.5))
                    .cornerRadius(10)
                    .fixedSize()
                Text("Cycles: \(entry.batteryInfo.cycleCount)")
                    .font(.body)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding()
            .background(altGradientBackground.opacity(0.7))
            .cornerRadius(15)
            .shadow(radius: 10)
        }
        .padding()
        .containerBackground(gradientBackground, for: .widget)  // Widget's semi-transparent background
        .cornerRadius(15)
    }
    
    var largeView: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                ZStack {
                    if entry.batteryInfo.charging {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 50, height: 50)
                            //.shadow(radius: 10)
                    }
                    else {
                        Circle()
                            .fill(Color.cyan)
                            .frame(width: 50, height: 50)
                            //.shadow(radius: 10)
                    }
                    
                    Image(systemName: "bolt.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }
                if entry.batteryInfo.charging{
                    if colorScheme == .dark {
                        Text("         Battery Info for: \n" + entry.batteryInfo.serial)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        //.padding(.leading, 10)
                        //.padding(.horizontal, 6)
                            .padding(.all, 5)
                        //.background(gradientBackground.opacity(0.6))
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(12)
                            .fixedSize()
                    }
                    else {
                        Text("         Battery Info for: \n" + entry.batteryInfo.serial)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.secondary)
                        //.padding(.leading, 10)
                        //.padding(.horizontal, 6)
                            .padding(.all, 5)
                        //.background(gradientBackground.opacity(0.6))
                            .background(.green.opacity(0.2))
                            .cornerRadius(12)
                            .fixedSize()
                    }
                }
                else {
                    if colorScheme == .dark {
                        Text("         Battery Info for: \n" + entry.batteryInfo.serial)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.cyan)
                        //.padding(.leading, 10)
                        //.padding(.horizontal, 6)
                            .padding(.all, 5)
                        //.background(gradientBackground.opacity(0.6))
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(12)
                            .fixedSize()
                    }
                    else {
                        Text("         Battery Info for: \n" + entry.batteryInfo.serial)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.secondary)
                        //.padding(.leading, 10)
                        //.padding(.horizontal, 6)
                            .padding(.all, 5)
                        //.background(gradientBackground.opacity(0.6))
                            .background(.cyan.opacity(0.2))
                            .cornerRadius(12)
                            .fixedSize()
                    }
                }
            }
            VStack(alignment: .leading, spacing: 15) {
                GaugeView(title: "Current Capacity:", value: entry.batteryInfo.currentCapacity, maxValue: entry.batteryInfo.designCapacity, charge: entry.batteryInfo.charging)
                GaugeView(title: "Effective Capacity:", value: entry.batteryInfo.maxCapacity, maxValue: entry.batteryInfo.designCapacity, charge: entry.batteryInfo.charging)
                //GaugeView(title: "Design Capacity", value: entry.batteryInfo.designCapacity, maxValue: entry.batteryInfo.designCapacity)
            }
            .padding()
            .background(altGradientBackground.opacity(0.8))
            .cornerRadius(15)
            .shadow(radius: 10)
            HStack{
                Text("Voltage: \(entry.batteryInfo.voltage) V")
                    .font(.body)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(10)
                    .fixedSize()
                Text("Temp.: \(entry.batteryInfo.temp)°")
                    .font(.body)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(10)
                    .fixedSize()
                Text("Cycles: \(entry.batteryInfo.cycleCount)")
                    .font(.body)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(10)
                    .fixedSize()
            }
            HStack{
                Spacer()
                if maxPerc > 80 {
                    if entry.batteryInfo.charging {
                        Text("Health: Good")
                            .font(.title)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(.green.opacity(0.6))
                            .cornerRadius(10)
                            .fixedSize()
                            .shadow(radius: 10)
                    }
                    else {
                        Text("Health: Good")
                            .font(.title)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(.cyan.opacity(0.6))
                            .cornerRadius(10)
                            .fixedSize()
                            .shadow(radius: 10)
                    }
                }
                else if maxPerc <= 80 && maxPerc > 60 {
                    Text("Health: To check")
                        .font(.title)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(.yellow.opacity(0.6))
                        .cornerRadius(10)
                        .fixedSize()
                        .shadow(radius: 10)
                }
                else {
                    Text("Health: Replace")
                        .font(.title)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(.red.opacity(0.6))
                        .cornerRadius(10)
                        .fixedSize()
                        .shadow(radius: 10)
                }
                Spacer()
            }
        }
        //.widgetBackground(Color.white)
        .padding()
        .containerBackground(gradientBackground, for: .widget)
        .cornerRadius(15)
    }
}

/*
extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}
*/
 
struct GaugeView: View {
    let title: String
    let value: Int
    let maxValue: Int
    let charge: Bool
    
    private var Perc: Int {
        Int(Double(value) / Double(maxValue) * 100)
    }
    
    private var gaugeColor: Color {
            let percentage = (Double(value) / Double(maxValue)) * 100
            switch percentage {
            case 0..<60:
                return .red
            case 60..<80:
                return .yellow
            default:
                if charge {
                    return .green
                }
                else {
                    return .cyan
                }
            }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.body)
                //.foregroundColor(.gray)
            HStack{
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .frame(width: geometry.size.width, height: 25)
                            .foregroundColor(Color.secondary.opacity(0.7))
                        Capsule()
                            .frame(width: geometry.size.width * CGFloat(value) / CGFloat(maxValue), height: 25)
                            .foregroundColor(gaugeColor)
                    }
                }
                if Perc == 100 {
                    Text("MAX")
                        .font(.body)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(gaugeColor.opacity(0.6))
                        .cornerRadius(10)
                        .fixedSize()
                }
                else {
                    Text(String(Perc) + "%")
                        .font(.body)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(gaugeColor.opacity(0.6))
                        .cornerRadius(10)
                        .fixedSize()
                }
            }
            .frame(height: 25)
        }
    }
}

struct ArcGaugeShape: Shape {
    var progress: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.maxY)
        let radius = rect.width / 2
        let startAngle = Angle.degrees(180)
        let endAngle = Angle.degrees(180 + (progress * 180))
        
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        return path.strokedPath(.init(lineWidth: 10, lineCap: .round, lineJoin: .round))
    }
}

struct ArcGaugeView: View {
    let title: String
    let value: Int
    let maxValue: Int
    let lw: Int
    let charge: Bool
    
    private var maxPerc: Int {
        Int(Double(value) / Double(maxValue) * 100)
    }
    
    private var progress: Double {
        return Double(value) / Double(maxValue)
    }
    
    private var gaugeColor: Color {
        let percentage = progress * 100
        switch percentage {
        case 0..<50:
            return .red
        case 50..<75:
            return .yellow
        default:
            return .cyan
        }
    }
    
    var body: some View {
        //VStack() {
            
            GeometryReader { geometry in
                    ArcGaugeShape(progress: 1.0)
                        .stroke(Color.secondary.opacity(0.7), style: StrokeStyle(lineWidth: CGFloat(lw), lineCap: .round))
                    ArcGaugeShape(progress: progress)
                        .stroke(gaugeColor, style: StrokeStyle(lineWidth: CGFloat(lw), lineCap: .round))
                        .shadow(radius: 10)
            }
            .padding(.top, 70)
            //.frame(height: 100)
            ZStack {
                if charge {
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 50, height: 50)
                        //.shadow(radius: 10)
                }
                else {
                    Circle()
                        .fill(Color.cyan)
                        .frame(width: 50, height: 50)
                        //.shadow(radius: 10)
                }
                
                Image(systemName: "bolt.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
            }
            .padding(.bottom, 110)
        /*if maxPerc > 80 {
            Text("Health: Good")
                .font(.body)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(gaugeColor.opacity(0.5))
                .cornerRadius(10)
                .fixedSize()
                .shadow(radius: 10)
        }
        else if maxPerc <= 80 && maxPerc > 60 {
            Text("Health: To check")
                .font(.body)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(gaugeColor.opacity(0.5))
                .cornerRadius(10)
                .fixedSize()
                .shadow(radius: 10)
        }
        else {
            Text("Health: Replace")
                .font(.body)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(gaugeColor.opacity(0.5))
                .cornerRadius(10)
                .fixedSize()
                .shadow(radius: 10)
        }*/
        //}
       //.padding()
    }
}

struct RingShape: Shape {
    var progress: Double
    var lw: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = rect.width / 2
        let startAngle = Angle.degrees(-90)
        let endAngle = Angle.degrees(-90 + (progress * 360))
        
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        return path.strokedPath(.init(lineWidth: CGFloat(lw), lineCap: .round, lineJoin: .round))
    }
}

struct SingleRingGaugeView: View {
    let charge: Bool
    let maxCapacity: Int
    let designCapacity: Int
    let c1: Color
    
    private var maxProgress: Double {
        return Double(maxCapacity) / Double(designCapacity)
    }
    
    var body: some View {
        VStack {
            ZStack {
                RingShape(progress: maxProgress, lw: 7)
                    .stroke(c1, lineWidth: 7)
                    .frame(width: 100, height: 100)
                
                ZStack {
                    if charge {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 50, height: 50)
                            //.shadow(radius: 10)
                    }
                    else {
                        Circle()
                            .fill(Color.cyan)
                            .frame(width: 50, height: 50)
                            //.shadow(radius: 10)
                    }
                    
                    Image(systemName: "bolt.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }
            }
            /*VStack(spacing: 4) {
                Text("Current: \(currentCapacity)")
                    .font(.caption)
                    .foregroundColor(.primary)
                Text("Max: \(maxCapacity)")
                    .font(.caption)
                    .foregroundColor(.primary)
            }*/
        }
        .padding()
    }
}

struct DoubleRingGaugeView: View {
    let charge: Bool
    let currentCapacity: Int
    let maxCapacity: Int
    let designCapacity: Int
    let c1: Color
    let c2: Color
    
    private var currentProgress: Double {
        return Double(currentCapacity) / Double(designCapacity)
    }
    
    private var maxProgress: Double {
        return Double(maxCapacity) / Double(designCapacity)
    }
    
    var body: some View {
        VStack {
            ZStack {
                // Outer ring for currentCapacity
                RingShape(progress: currentProgress, lw: 7)
                    .stroke(c1, lineWidth: 7)
                    .frame(width: 100, height: 100)
                
                // Inner ring for maxCapacity
                RingShape(progress: maxProgress, lw: 4)
                    .stroke(c2, lineWidth: 4)
                    .frame(width: 70, height: 70)
                
                ZStack {
                    if charge {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 50, height: 50)
                            //.shadow(radius: 10)
                    }
                    else {
                        Circle()
                            .fill(Color.cyan)
                            .frame(width: 50, height: 50)
                            //.shadow(radius: 10)
                    }
                    
                    Image(systemName: "bolt.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }
            }
            /*VStack(spacing: 4) {
                Text("Current: \(currentCapacity)")
                    .font(.caption)
                    .foregroundColor(.primary)
                Text("Max: \(maxCapacity)")
                    .font(.caption)
                    .foregroundColor(.primary)
            }*/
        }
        .padding()
    }
}

@main
struct BatteryWidget: Widget {
    let kind: String = "BatteryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BatteryProvider()) { entry in
            BatteryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Battery Test Widget")
        .description("Displays advanced battery informations with fuel gauges.")
        .supportedFamilies([.systemSmall,.systemMedium,.systemLarge])
    }
}
