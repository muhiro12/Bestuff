@testable import Bestuff
import Testing

struct ConfigurationServiceTests {
    @Test @MainActor func updateCheck() async throws {
        let service = ConfigurationService()
        try? await service.load()
        _ = service.isUpdateRequired()
    }
}
