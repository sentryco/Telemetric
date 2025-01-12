import XCTest
@testable import Telemetric
// This unit test checks the encoding and decoding functionality of CodableAny with various supported types, ensuring that the original and decoded values are equal.
extension TelemetricTests {

    /**
     * Tests the encoding and decoding functionality of `CodableAny`.
     * This test encodes various supported types and ensures that decoding them returns the original values.
     */
    func testCodableAnyEncodingDecoding() throws {
        let testValues: [Any] = [
            true,
            42,
            3.14 as Float,
//            2.71828, // - Fixme: ⚠️️ this has issues try to figure it out later
            "Hello, World!",
            ["key": "value"],
            [
                CodableAny(value: 123),
                CodableAny(value: "test")
            ]
        ]

        for originalValue in testValues {
            let codableAny = CodableAny(value: originalValue)
            let encoder = JSONEncoder()
            let data = try encoder.encode(codableAny)
            let decoder = JSONDecoder()
            let decodedCodableAny = try decoder.decode(CodableAny.self, from: data)
            
            XCTAssertTrue(areEqual(lhs: originalValue, rhs: decodedCodableAny.value), "Values are not equal 👉: \(originalValue) vs 👉 \(decodedCodableAny.value)")
        }
    }
    
    /**
     * Helper method to compare two `Any` values for equality.
     * - Parameters:
     *   - lhs: The left-hand side value.
     *   - rhs: The right-hand side value.
     * - Returns: A Boolean indicating whether the two values are equal.
     */
    private func areEqual(lhs: Any, rhs: Any) -> Bool {
        switch (lhs, rhs) {
        case let (l as Bool, r as Bool):
            return l == r
        case let (l as Int, r as Int):
            return l == r
        case let (l as Float, r as Float):
            return l == r
        case let (l as Double, r as Double):
            return l == r
        case let (l as String, r as String):
            return l == r
        case let (l as [String: String], r as [String: String]):
            return l == r
        case let (l as [CodableAny], r as [CodableAny]):
                // Start of Selection
                if l.count != r.count { return false }
                for (left, right) in zip(l.map { $0.value }, r.map { $0.value }) {
                    if !areEqual(lhs: left, rhs: right) {
                        return false
                    }
                }
                return true
        default:
            return false
        }
    }
    // Test CodableAny with Unsupported Type:
    // Objective: Ensure that CodableAny throws an appropriate error when attempting to encode an unsupported type.
       func testCodableAnyWithUnsupportedType() throws {
         struct UnsupportedType {}
         let unsupportedValue = CodableAny(value: UnsupportedType())
         let encoder = JSONEncoder()
         XCTAssertThrowsError(try encoder.encode(unsupportedValue)) { error in
             XCTAssertTrue(error is EncodingError)
         }
     }
}
