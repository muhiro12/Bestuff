import Foundation
import SwiftData

enum SampleDataSeeder {
    static func seed(context: ModelContext) {
        for data in SampleData.stuffs {
            var tagModels: [Tag] = []
            for label in data.labels {
                tagModels.append(Tag.findOrCreate(name: label, in: context, type: .label))
            }
            if let period = data.period {
                tagModels.append(Tag.findOrCreate(name: period, in: context, type: .period))
            }
            for resource in data.resources {
                tagModels.append(Tag.findOrCreate(name: resource, in: context, type: .resource))
            }
            let occurredAt = Calendar.current.date(byAdding: .day, value: data.occurredOffsetDays, to: .now) ?? .now
            let model = StuffService.create(
                context: context,
                title: data.title,
                note: data.note,
                occurredAt: occurredAt,
                tags: tagModels
            )
            model.update(score: data.score, isCompleted: data.isCompleted, lastFeedback: data.lastFeedback, source: data.source)
        }
    }
}
