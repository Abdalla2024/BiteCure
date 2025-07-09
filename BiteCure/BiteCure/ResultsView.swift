//
//  ResultsView.swift
//  BiteCure
//
//  Created by Abdalla Abdelmagid on 7/8/25.
//

import SwiftUI

struct ResultsView: View {
    let result: ScanResult
    @Binding var scannedItems: [GroceryItem]
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with total cost
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Scan Results")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("\(result.detectedItems.count) items detected")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Total Cost")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("$\(result.totalEstimatedCost, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.gray.opacity(0.1))
                
                // Tab selection
                Picker("View", selection: $selectedTab) {
                    Text("Items").tag(0)
                    Text("Nutrition").tag(1)
                    Text("Recipes").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Content based on selected tab
                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedTab {
                        case 0:
                            DetectedItemsView(items: result.detectedItems)
                        case 1:
                            NutritionView(analysis: result.nutritionalAnalysis)
                        case 2:
                            RecipesView(recipes: result.recipeSuggestions)
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                // Action buttons
                HStack(spacing: 16) {
                    Button("Scan Again") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(25)
                    
                    Button("Save Items") {
                        saveItems()
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.green)
                    .cornerRadius(25)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func saveItems() {
        for detectedItem in result.detectedItems {
            let groceryItem = GroceryItem(
                name: detectedItem.name,
                estimatedCost: detectedItem.estimatedCost,
                nutritionalInfo: nil, // TODO: Parse nutritional info per item
                scannedText: result.recognizedText,
                timestamp: Date()
            )
            scannedItems.append(groceryItem)
        }
        presentationMode.wrappedValue.dismiss()
    }
}

struct DetectedItemsView: View {
    let items: [DetectedItem]
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(items.indices, id: \.self) { index in
                let item = items[index]
                
                HStack(spacing: 16) {
                    // Item icon
                    Image(systemName: iconForItem(item.name))
                        .font(.title2)
                        .foregroundColor(.green)
                        .frame(width: 40, height: 40)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(20)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text("Confidence: \(Int(item.confidence * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("$\(item.estimatedCost, specifier: "%.2f")")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Spacer()
                    
                    // Confidence indicator
                    Circle()
                        .fill(confidenceColor(item.confidence))
                        .frame(width: 12, height: 12)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
        }
    }
    
    private func iconForItem(_ name: String) -> String {
        let lowercaseName = name.lowercased()
        
        if lowercaseName.contains("apple") || lowercaseName.contains("fruit") {
            return "apple.logo"
        } else if lowercaseName.contains("milk") || lowercaseName.contains("dairy") {
            return "drop.fill"
        } else if lowercaseName.contains("bread") || lowercaseName.contains("grain") {
            return "leaf.fill"
        } else if lowercaseName.contains("meat") || lowercaseName.contains("protein") {
            return "flame.fill"
        } else {
            return "cart.fill"
        }
    }
    
    private func confidenceColor(_ confidence: Double) -> Color {
        if confidence > 0.8 {
            return .green
        } else if confidence > 0.6 {
            return .yellow
        } else {
            return .red
        }
    }
}

struct NutritionView: View {
    let analysis: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Nutritional highlights
            VStack(alignment: .leading, spacing: 16) {
                Text("Nutritional Analysis")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(analysis)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            // Mock nutritional facts (in a real app, this would come from the AI)
            VStack(alignment: .leading, spacing: 16) {
                Text("Estimated Nutrition Facts")
                    .font(.title3)
                    .fontWeight(.bold)
                
                VStack(spacing: 12) {
                    NutritionRow(label: "Calories", value: "285", unit: "kcal")
                    NutritionRow(label: "Protein", value: "12.5", unit: "g")
                    NutritionRow(label: "Carbohydrates", value: "45.2", unit: "g")
                    NutritionRow(label: "Fat", value: "8.1", unit: "g")
                    NutritionRow(label: "Fiber", value: "6.8", unit: "g")
                    NutritionRow(label: "Sugar", value: "22.4", unit: "g")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            // Health insights
            VStack(alignment: .leading, spacing: 16) {
                Text("Health Insights")
                    .font(.title3)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 8) {
                    HealthInsightRow(icon: "checkmark.circle.fill", color: .green, text: "Good source of fiber")
                    HealthInsightRow(icon: "exclamationmark.triangle.fill", color: .orange, text: "Moderate sugar content")
                    HealthInsightRow(icon: "heart.fill", color: .red, text: "Heart-healthy potassium")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }
}

struct NutritionRow: View {
    let label: String
    let value: String
    let unit: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(value) \(unit)")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
    }
}

struct HealthInsightRow: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(color)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct RecipesView: View {
    let recipes: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recipe Suggestions")
                .font(.title3)
                .fontWeight(.bold)
            
            LazyVStack(spacing: 12) {
                ForEach(recipes.indices, id: \.self) { index in
                    let recipe = recipes[index]
                    
                    HStack(spacing: 16) {
                        Image(systemName: "book.closed.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                            .frame(width: 40, height: 40)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(20)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(recipe)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Uses your scanned ingredients")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // TODO: Open recipe details
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
            }
            
            // AI-generated recipe note
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.body)
                        .foregroundColor(.purple)
                    
                    Text("AI-Generated Suggestions")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.purple)
                }
                
                Text("These recipes are tailored to your scanned items and nutritional preferences.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.purple.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

#Preview {
    ResultsView(
        result: ScanResult(
            recognizedText: "Sample recognized text",
            detectedItems: [
                DetectedItem(name: "Banana", confidence: 0.95, estimatedCost: 1.29),
                DetectedItem(name: "Apple", confidence: 0.88, estimatedCost: 2.49),
                DetectedItem(name: "Milk", confidence: 0.92, estimatedCost: 3.99)
            ],
            nutritionalAnalysis: "High in potassium, vitamin C, and fiber. Good for heart health and digestion.",
            recipeSuggestions: [
                "Banana Apple Smoothie",
                "Creamy Fruit Parfait",
                "Healthy Breakfast Bowl"
            ],
            totalEstimatedCost: 7.77
        ),
        scannedItems: .constant([])
    )
} 