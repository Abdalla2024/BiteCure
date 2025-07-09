//
//  AIService.swift
//  BiteCure
//
//  Created by Abdalla Abdelmagid on 7/8/25.
//

import Foundation
import UIKit

class AIService: ObservableObject {
    private let openAIEndpoint = "https://api.openai.com/v1/chat/completions"
    
    private var openAIAPIKey: String {
        return UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
    }
    
    struct OpenAIRequest: Codable {
        let model: String
        let messages: [OpenAIMessage]
        let temperature: Double
        let max_tokens: Int
    }
    
    struct OpenAIMessage: Codable {
        let role: String
        let content: String
    }
    
    struct OpenAIResponse: Codable {
        let choices: [OpenAIChoice]
    }
    
    struct OpenAIChoice: Codable {
        let message: OpenAIMessage
    }
    
    struct GroceryAnalysis: Codable {
        let detectedItems: [DetectedGroceryItem]
        let nutritionalAnalysis: String
        let recipeSuggestions: [String]
        let totalEstimatedCost: Double
        let healthInsights: [String]
    }
    
    struct DetectedGroceryItem: Codable {
        let name: String
        let confidence: Double
        let estimatedCost: Double
        let category: String
        let nutritionalInfo: ItemNutrition?
    }
    
    struct ItemNutrition: Codable {
        let calories: Int?
        let protein: Double?
        let carbs: Double?
        let fat: Double?
        let fiber: Double?
        let sugar: Double?
    }
    
    func analyzeGroceryText(_ recognizedText: String) async -> ScanResult {
        // If API key is not set, return mock data
        if openAIAPIKey.isEmpty {
            return createMockResult(from: recognizedText)
        }
        
        do {
            let analysis = try await callOpenAI(with: recognizedText)
            return convertToScanResult(analysis, originalText: recognizedText)
        } catch {
            print("AI Service Error: \(error.localizedDescription)")
            return createMockResult(from: recognizedText)
        }
    }
    
    private func callOpenAI(with text: String) async throws -> GroceryAnalysis {
        guard let url = URL(string: openAIEndpoint) else {
            throw AIServiceError.invalidURL
        }
        
        let prompt = createPrompt(for: text)
        
        let request = OpenAIRequest(
            model: "gpt-3.5-turbo",
            messages: [
                OpenAIMessage(role: "system", content: "You are a nutrition expert and grocery analyst. Analyze the provided grocery text and return a JSON response with detected items, nutritional analysis, and recipe suggestions."),
                OpenAIMessage(role: "user", content: prompt)
            ],
            temperature: 0.7,
            max_tokens: 1500
        )
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Bearer \(openAIAPIKey)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        guard let content = response.choices.first?.message.content else {
            throw AIServiceError.invalidResponse
        }
        
        // Parse the JSON response from OpenAI
        let jsonData = content.data(using: .utf8) ?? Data()
        let analysis = try JSONDecoder().decode(GroceryAnalysis.self, from: jsonData)
        
        return analysis
    }
    
    private func createPrompt(for text: String) -> String {
        return """
        Analyze this grocery-related text and provide a JSON response with the following structure:
        
        {
            "detectedItems": [
                {
                    "name": "Item name",
                    "confidence": 0.95,
                    "estimatedCost": 2.49,
                    "category": "fruit/vegetable/dairy/meat/grain/other",
                    "nutritionalInfo": {
                        "calories": 100,
                        "protein": 5.0,
                        "carbs": 20.0,
                        "fat": 2.0,
                        "fiber": 3.0,
                        "sugar": 15.0
                    }
                }
            ],
            "nutritionalAnalysis": "Overall nutritional summary",
            "recipeSuggestions": ["Recipe 1", "Recipe 2", "Recipe 3"],
            "totalEstimatedCost": 15.47,
            "healthInsights": ["Health insight 1", "Health insight 2"]
        }
        
        Text to analyze: \(text)
        
        Please provide realistic cost estimates based on average US grocery prices, accurate nutritional information, and creative recipe suggestions that use the detected items.
        """
    }
    
    private func convertToScanResult(_ analysis: GroceryAnalysis, originalText: String) -> ScanResult {
        let detectedItems = analysis.detectedItems.map { item in
            DetectedItem(
                name: item.name,
                confidence: item.confidence,
                estimatedCost: item.estimatedCost
            )
        }
        
        return ScanResult(
            recognizedText: originalText,
            detectedItems: detectedItems,
            nutritionalAnalysis: analysis.nutritionalAnalysis,
            recipeSuggestions: analysis.recipeSuggestions,
            totalEstimatedCost: analysis.totalEstimatedCost
        )
    }
    
    private func createMockResult(from text: String) -> ScanResult {
        // Enhanced mock data based on recognized text
        let mockItems = extractMockItems(from: text)
        let totalCost = mockItems.reduce(0) { $0 + $1.estimatedCost }
        
        return ScanResult(
            recognizedText: text,
            detectedItems: mockItems,
            nutritionalAnalysis: generateMockNutritionalAnalysis(for: mockItems),
            recipeSuggestions: generateMockRecipes(for: mockItems),
            totalEstimatedCost: totalCost
        )
    }
    
    private func extractMockItems(from text: String) -> [DetectedItem] {
        let lowercaseText = text.lowercased()
        var items: [DetectedItem] = []
        
        // Simple keyword matching for demo purposes
        let foodKeywords = [
            ("apple", 2.49, 0.88),
            ("banana", 1.29, 0.95),
            ("milk", 3.99, 0.92),
            ("bread", 2.79, 0.85),
            ("chicken", 5.99, 0.78),
            ("rice", 3.49, 0.82),
            ("tomato", 2.99, 0.87),
            ("cheese", 4.49, 0.80),
            ("egg", 2.99, 0.90),
            ("yogurt", 1.99, 0.85)
        ]
        
        for (keyword, cost, confidence) in foodKeywords {
            if lowercaseText.contains(keyword) {
                items.append(DetectedItem(
                    name: keyword.capitalized,
                    confidence: confidence,
                    estimatedCost: cost
                ))
            }
        }
        
        // If no items found, add some default items
        if items.isEmpty {
            items = [
                DetectedItem(name: "Mixed Groceries", confidence: 0.70, estimatedCost: 12.99),
                DetectedItem(name: "Fresh Produce", confidence: 0.65, estimatedCost: 8.49)
            ]
        }
        
        return items
    }
    
    private func generateMockNutritionalAnalysis(for items: [DetectedItem]) -> String {
        let itemNames = items.map { $0.name.lowercased() }
        
        if itemNames.contains("banana") || itemNames.contains("apple") {
            return "High in potassium, vitamin C, and fiber. Great for heart health and digestion. Natural sugars provide quick energy."
        } else if itemNames.contains("milk") || itemNames.contains("cheese") {
            return "Rich in calcium and protein. Good for bone health and muscle development. Contains essential vitamins A and D."
        } else if itemNames.contains("chicken") || itemNames.contains("egg") {
            return "Excellent source of lean protein and essential amino acids. Supports muscle building and repair."
        } else {
            return "Balanced mix of nutrients including carbohydrates, proteins, and healthy fats. Provides sustained energy and essential vitamins."
        }
    }
    
    private func generateMockRecipes(for items: [DetectedItem]) -> [String] {
        let itemNames = items.map { $0.name.lowercased() }
        
        if itemNames.contains("banana") && itemNames.contains("milk") {
            return ["Banana Smoothie", "Overnight Oats", "Banana Pancakes"]
        } else if itemNames.contains("apple") {
            return ["Apple Crisp", "Waldorf Salad", "Apple Cinnamon Oatmeal"]
        } else if itemNames.contains("chicken") {
            return ["Grilled Chicken Salad", "Chicken Stir Fry", "Chicken Soup"]
        } else if itemNames.contains("rice") {
            return ["Fried Rice", "Rice Bowl", "Stuffed Peppers"]
        } else {
            return ["Quick Stir Fry", "Hearty Soup", "Nutritious Salad"]
        }
    }
}

// Enhanced barcode scanner service
class BarcodeService: ObservableObject {
    func lookupProduct(barcode: String) async -> ProductInfo? {
        // In a real app, this would call a product database API like OpenFoodFacts
        // For demo purposes, return mock data
        
        let mockProducts = [
            "123456789": ProductInfo(
                name: "Organic Bananas",
                brand: "Fresh & Easy",
                price: 1.29,
                nutrition: NutritionalInfo(
                    calories: 105,
                    protein: 1.3,
                    carbs: 27.0,
                    fat: 0.4,
                    fiber: 3.1,
                    sugar: 14.4
                )
            ),
            "987654321": ProductInfo(
                name: "Whole Milk",
                brand: "Dairy Farm",
                price: 3.99,
                nutrition: NutritionalInfo(
                    calories: 150,
                    protein: 8.0,
                    carbs: 12.0,
                    fat: 8.0,
                    fiber: 0.0,
                    sugar: 12.0
                )
            )
        ]
        
        return mockProducts[barcode]
    }
}

struct ProductInfo {
    let name: String
    let brand: String
    let price: Double
    let nutrition: NutritionalInfo
}

enum AIServiceError: Error {
    case invalidURL
    case invalidResponse
    case networkError
    case decodingError
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid API response"
        case .networkError:
            return "Network error occurred"
        case .decodingError:
            return "Failed to decode response"
        }
    }
} 