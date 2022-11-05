//
//  Qurankz.swift
//  Qurankz
//
//  Created by Daulet Ashikbayev on 01.11.2022.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> PrayerTimeEntry {
        PrayerTimeEntry(prayerType: .maghrib, date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (PrayerTimeEntry) -> ()) {
        let entry = PrayerTimeEntry(prayerType: .dhuhr, date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [PrayerTimeEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        //TODO: Provide times for upcoming 3 days
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = PrayerTimeEntry(prayerType: .fajr, date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

enum PrayerTimeType: String {
    case fajr = "Fajr", sunrise, dhuhr, asr, maghrib, isha
}

struct PrayerTimeEntry: TimelineEntry {
    let prayerType: PrayerTimeType
    let date: Date
    let configuration: ConfigurationIntent
}

struct QurankzEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry

    var body: some View {
        switch widgetFamily {
        case .accessoryInline:
            Gauge(value: 0.7) {
                Text(entry.date, format: .dateTime.year())
            }
            .gaugeStyle(.accessoryLinear)
            
        case .accessoryRectangular:
            Gauge(value: 0.7) {
                Text(entry.date, format: .dateTime.day())
            }
            .gaugeStyle(.accessoryLinear)
            Text("\(entry.prayerType.rawValue)")
            
        default:
            Text("Not implemented")
        }
    }
}

@main
struct Qurankz: Widget {
    let kind: String = "Qurankz"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            QurankzEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.accessoryInline, .accessoryCircular, .accessoryRectangular])
    }
}

struct Qurankz_Previews: PreviewProvider {
    static var previews: some View {
        QurankzEntryView(entry: PrayerTimeEntry(prayerType: .fajr, date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .accessoryInline))
            .previewDisplayName("Inline")
        
        QurankzEntryView(entry: PrayerTimeEntry(prayerType: .maghrib, date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            .previewDisplayName("Rectangular")
    }
}
