import { describe, it, expect, beforeEach } from "vitest"

describe("Reward Contract", () => {
  let mockTokenBalances: Map<string, number>
  let mockAuthorizedContracts: Map<string, boolean>
  
  beforeEach(() => {
    mockTokenBalances = new Map()
    mockAuthorizedContracts = new Map()
  })
  
  const mockContractCall = (method: string, args: any[], sender: string) => {
    switch (method) {
      case "authorize-contract":
        if (sender !== "CONTRACT_OWNER") return { success: false, error: "Not authorized" }
        mockAuthorizedContracts.set(args[0], true)
        return { success: true }
      case "revoke-contract-authorization":
        if (sender !== "CONTRACT_OWNER") return { success: false, error: "Not authorized" }
        mockAuthorizedContracts.set(args[0], false)
        return { success: true }
      case "mint-tokens":
        const [recipient, amount] = args
        if (!mockAuthorizedContracts.get(sender)) return { success: false, error: "Not authorized" }
        const currentBalance = mockTokenBalances.get(recipient) || 0
        mockTokenBalances.set(recipient, currentBalance + amount)
        return { success: true }
      case "transfer-tokens":
        const [transferAmount, transferSender, transferRecipient] = args
        if (sender !== transferSender) return { success: false, error: "Not authorized" }
        const senderBalance = mockTokenBalances.get(transferSender) || 0
        if (senderBalance < transferAmount) return { success: false, error: "Insufficient balance" }
        mockTokenBalances.set(transferSender, senderBalance - transferAmount)
        const recipientBalance = mockTokenBalances.get(transferRecipient) || 0
        mockTokenBalances.set(transferRecipient, recipientBalance + transferAmount)
        return { success: true }
      case "get-balance":
        return { success: true, value: mockTokenBalances.get(args[0]) || 0 }
      case "is-contract-authorized":
        return { success: true, value: mockAuthorizedContracts.get(args[0]) || false }
      default:
        return { success: false, error: "Method not found" }
    }
  }
  
  it("should authorize a contract", () => {
    const result = mockContractCall("authorize-contract", ["contract1"], "CONTRACT_OWNER")
    expect(result.success).toBe(true)
  })
  
  it("should revoke contract authorization", () => {
    mockContractCall("authorize-contract", ["contract1"], "CONTRACT_OWNER")
    const result = mockContractCall("revoke-contract-authorization", ["contract1"], "CONTRACT_OWNER")
    expect(result.success).toBe(true)
  })
  
  it("should mint tokens", () => {
    mockContractCall("authorize-contract", ["contract1"], "CONTRACT_OWNER")
    const result = mockContractCall("mint-tokens", ["user1", 100], "contract1")
    expect(result.success).toBe(true)
  })
  
  it("should transfer tokens", () => {
    mockContractCall("authorize-contract", ["contract1"], "CONTRACT_OWNER")
    mockContractCall("mint-tokens", ["user1", 100], "contract1")
    const result = mockContractCall("transfer-tokens", [50, "user1", "user2"], "user1")
    expect(result.success).toBe(true)
  })
  
  it("should get balance", () => {
    mockContractCall("authorize-contract", ["contract1"], "CONTRACT_OWNER")
    mockContractCall("mint-tokens", ["user1", 100], "contract1")
    const result = mockContractCall("get-balance", ["user1"], "anyone")
    expect(result.success).toBe(true)
    expect(result.value).toBe(100)
  })
  
  it("should check if a contract is authorized", () => {
    mockContractCall("authorize-contract", ["contract1"], "CONTRACT_OWNER")
    const result = mockContractCall("is-contract-authorized", ["contract1"], "anyone")
    expect(result.success).toBe(true)
    expect(result.value).toBe(true)
  })
})

