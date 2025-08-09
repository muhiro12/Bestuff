import EventKit
#if canImport(EventKitUI)
import EventKitUI
import SwiftUI

struct EKEventEditView: UIViewControllerRepresentable {
    final class Coordinator: NSObject, EKEventEditViewDelegate {
        let parent: EKEventEditView
        init(parent: EKEventEditView) { self.parent = parent }

        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            switch action {
            case .canceled:
                parent.onComplete(.canceled(nil))
            case .saved:
                parent.onComplete(.saved(controller.event?.eventIdentifier))
            case .deleted:
                parent.onComplete(.deleted)
            @unknown default:
                parent.onComplete(.canceled(nil))
            }
            controller.dismiss(animated: true)
        }
    }

    enum Result {
        case saved(String?)
        case deleted
        case canceled(String?)
    }

    let store: EKEventStore
    let event: EKEvent
    let onComplete: (Result) -> Void

    func makeCoordinator() -> Coordinator {
        .init(parent: self)
    }

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let controller = EKEventEditViewController()
        controller.eventStore = store
        controller.event = event
        controller.editViewDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_: EKEventEditViewController, context _: Context) {}
}
#endif
