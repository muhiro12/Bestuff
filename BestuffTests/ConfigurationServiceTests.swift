@testable import Bestuff
import Testing

@MainActor
struct ConfigurationServiceTests {
    @Test func updateCheck() async throws {
        let service = ConfigurationService()
        try? await service.load()
        _ = service.isUpdateRequired()
    }
}
