//
//  ContentView.swift
//  BiteCure
//
//  Created by Abdalla Abdelmagid on 7/8/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showingCamera = false
    @State private var showingSettings = false
    @State private var scannedItems: [GroceryItem] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("BiteCure")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("AI-Powered Grocery Scanner")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                // Features
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "doc.text.viewfinder", title: "Smart OCR", description: "Scan grocery receipts and labels")
                    FeatureRow(icon: "chart.bar.fill", title: "Nutritional Info", description: "Get detailed nutrition facts")
                    FeatureRow(icon: "dollarsign.circle", title: "Cost Tracking", description: "Track spending and estimates")
                    FeatureRow(icon: "book.closed", title: "Recipe Ideas", description: "AI-powered recipe suggestions")
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Main Action Button
                Button(action: {
                    showingCamera = true
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                        Text("Scan Groceries")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.green, .blue]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(28)
                }
                .padding(.horizontal, 20)
                
                // Recent Scans
                if !scannedItems.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Scans")
                            .font(.headline)
                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(scannedItems.prefix(5)) { item in
                                    RecentItemCard(item: item)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("")
            .navigationBarHidden(false)
            .navigationBarItems(
                trailing: Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gear")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            )
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(scannedItems: $scannedItems)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct RecentItemCard: View {
    let item: GroceryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
            
            Text("$\(item.estimatedCost, specifier: "%.2f")")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .frame(width: 80, height: 60)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// Data Models
struct GroceryItem: Identifiable {
    let id = UUID()
    let name: String
    let estimatedCost: Double
    let nutritionalInfo: NutritionalInfo?
    let scannedText: String
    let timestamp: Date
}

struct NutritionalInfo {
    let calories: Int?
    let protein: Double?
    let carbs: Double?
    let fat: Double?
    let fiber: Double?
    let sugar: Double?
}

#Preview {
    ContentView()
}
