import { describe, it, expect, beforeEach } from "vitest"

describe("Waste Tracking Contract", () => {
  let mockStorage: Map<string, any>
  
  beforeEach(() => {
    mockStorage = new Map()
  })
  
  const mockContractCall = (method: string, args: any[], sender: string) => {
    switch (method) {
      case "record-waste":
        const [amount] = args
        const currentRecord = mockStorage.get(sender) || { "total-waste": 0, "last-update": 0 }
        mockStorage.set(sender, {
          "total-waste": currentRecord["total-waste"] + amount,
          "last-update": 100, // Mock block height
        })
        return { success: true }
      case "reduce-waste":
        const [reduceAmount] = args
        const record = mockStorage.get(sender) || { "total-waste": 0, "last-update": 0 }
        if (record["total-waste"] < reduceAmount) {
          return { success: false, error: "Invalid amount" }
        }
        mockStorage.set(sender, {
          "total-waste": record["total-waste"] - reduceAmount,
          "last-update": 100, // Mock block height
        })
        return { success: true }
      case "get-waste-record":
        return { success: true, value: mockStorage.get(args[0]) || { "total-waste": 0, "last-update": 0 } }
      default:
        return { success: false, error: "Method not found" }
    }
  }
  
  it("should record waste", () => {
    const result = mockContractCall("record-waste", [100], "user1")
    expect(result.success).toBe(true)
  })
  
  it("should reduce waste", () => {
    mockContractCall("record-waste", [100], "user1")
    const result = mockContractCall("reduce-waste", [50], "user1")
    expect(result.success).toBe(true)
  })
  
  it("should not reduce waste more than recorded", () => {
    mockContractCall("record-waste", [100], "user1")
    const result = mockContractCall("reduce-waste", [150], "user1")
    expect(result.success).toBe(false)
  })
  
  it("should get waste record", () => {
    mockContractCall("record-waste", [100], "user1")
    const result = mockContractCall("get-waste-record", ["user1"], "anyone")
    expect(result.success).toBe(true)
    expect(result.value["total-waste"]).toBe(100)
  })
})

