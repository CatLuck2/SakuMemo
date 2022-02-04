//
//  MemoWidget.swift
//  MemoWidget
//
//  Created by Nekokichi on 2022/01/29.
//

import WidgetKit
import SwiftUI
import Intents

/// Provider
struct Provider: IntentTimelineProvider {
    typealias Intent = ConfigurationIntent

    func placeholder(in context: Context) -> MemoEntry {
        MemoEntry.previewData
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (MemoEntry) -> Void) {
        let entry = MemoEntry.previewData
        completion(entry)
    }

    /*
     ”ウィジェットを編集”で、ユーザーが選択した値を表示
     */
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<MemoEntry>) -> Void) {
        var entries: [MemoEntry] = []
        entries.append(MemoEntry(date: Date(), text: configuration.memoType!.displayString))

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

/*
 ウィジェットの表示で扱うオブジェクト
 TimelineEntryでは、dateが必須
 */
/// Entry
struct MemoEntry: TimelineEntry {
    var date: Date
    let text: String
}
extension MemoEntry {
    static let previewData = MemoEntry(
        date: Date(),
        text: "テキスト"
    )
}

/*
 ウィジェットのView
 */
/// View
struct MemoWidgetEntryView: View {
    let memoEntry: MemoEntry

    var body: some View {
        Text(memoEntry.text)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)

    }
}

/// ユーザー設定
@main
struct MemoWidget: Widget {
    let kind: String = "MemoWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            MemoWidgetEntryView(memoEntry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

/// Preview
struct MemoWidget_Previews: PreviewProvider {
    static var previews: some View {
        MemoWidgetEntryView(memoEntry: .previewData)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        MemoWidgetEntryView(memoEntry: .previewData)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
