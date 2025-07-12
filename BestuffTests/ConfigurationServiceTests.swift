@testable import Bestuff
import Testing

struct ConfigurationServiceTests {
    @Test func updateCheck() async throws {
        let service = ConfigurationService()
        try? await service.load()
        _ = service.isUpdateRequired()
    }
}
