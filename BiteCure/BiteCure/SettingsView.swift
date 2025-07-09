//
//  SettingsView.swift
//  BiteCure
//
//  Created by Abdalla Abdelmagid on 7/8/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var apiKey = ""
    @State private var dietaryPreferences = DietaryPreferences()
    @State private var notificationsEnabled = true
    @State private var showingAPIKeyInfo = false
    @State private var showingDeleteConfirmation = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("AI Integration")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("OpenAI API Key")
                            .font(.headline)
                        
                        SecureField("Enter your OpenAI API key", text: $apiKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: {
                            showingAPIKeyInfo = true
                        }) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                                Text("How to get API key")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                Section(header: Text("Dietary Preferences")) {
                    Toggle("Vegetarian", isOn: $dietaryPreferences.vegetarian)
                    Toggle("Vegan", isOn: $dietaryPreferences.vegan)
                    Toggle("Gluten-Free", isOn: $dietaryPreferences.glutenFree)
                    Toggle("Dairy-Free", isOn: $dietaryPreferences.dairyFree)
                    Toggle("Keto", isOn: $dietaryPreferences.keto)
                    Toggle("Low-Carb", isOn: $dietaryPreferences.lowCarb)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Allergies")
                            .font(.headline)
                        
                        TextField("Enter allergies (comma-separated)", text: $dietaryPreferences.allergies)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    
                    if notificationsEnabled {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notification Types")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Toggle("Recipe Suggestions", isOn: $dietaryPreferences.recipeNotifications)
                            Toggle("Nutrition Reminders", isOn: $dietaryPreferences.nutritionReminders)
                            Toggle("Grocery Deals", isOn: $dietaryPreferences.dealNotifications)
                        }
                    }
                }
                
                Section(header: Text("App Preferences")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Currency")
                            .font(.headline)
                        
                        Picker("Currency", selection: $dietaryPreferences.currency) {
                            Text("USD ($)").tag("USD")
                            Text("EUR (€)").tag("EUR")
                            Text("GBP (£)").tag("GBP")
                            Text("CAD (C$)").tag("CAD")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Default Store")
                            .font(.headline)
                        
                        TextField("Enter your usual grocery store", text: $dietaryPreferences.defaultStore)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                Section(header: Text("Data Management")) {
                    Button("Export Scan History") {
                        // TODO: Implement export functionality
                    }
                    .foregroundColor(.blue)
                    
                    Button("Clear All Data") {
                        showingDeleteConfirmation = true
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Privacy Policy") {
                        // TODO: Open privacy policy
                    }
                    .foregroundColor(.blue)
                    
                    Button("Terms of Service") {
                        // TODO: Open terms of service
                    }
                    .foregroundColor(.blue)
                    
                    Button("Contact Support") {
                        // TODO: Open support
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(
                trailing: Button("Done") {
                    saveSettings()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            loadSettings()
        }
        .alert("API Key Information", isPresented: $showingAPIKeyInfo) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("To use AI features, you'll need an OpenAI API key. Visit platform.openai.com to create an account and generate your API key. The key will be stored securely on your device.")
        }
        .alert("Clear All Data", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will permanently delete all your scanned items and settings. This action cannot be undone.")
        }
    }
    
    private func loadSettings() {
        // Load settings from UserDefaults
        apiKey = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
        dietaryPreferences = DietaryPreferences.load()
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notifications_enabled")
    }
    
    private func saveSettings() {
        // Save settings to UserDefaults
        UserDefaults.standard.set(apiKey, forKey: "openai_api_key")
        UserDefaults.standard.set(notificationsEnabled, forKey: "notifications_enabled")
        dietaryPreferences.save()
    }
    
    private func clearAllData() {
        // Clear all app data
        UserDefaults.standard.removeObject(forKey: "openai_api_key")
        UserDefaults.standard.removeObject(forKey: "notifications_enabled")
        DietaryPreferences.clear()
        // TODO: Clear CoreData if implemented
    }
}

struct DietaryPreferences {
    var vegetarian = false
    var vegan = false
    var glutenFree = false
    var dairyFree = false
    var keto = false
    var lowCarb = false
    var allergies = ""
    var currency = "USD"
    var defaultStore = ""
    var recipeNotifications = true
    var nutritionReminders = true
    var dealNotifications = false
    
    static func load() -> DietaryPreferences {
        let defaults = UserDefaults.standard
        var preferences = DietaryPreferences()
        
        preferences.vegetarian = defaults.bool(forKey: "pref_vegetarian")
        preferences.vegan = defaults.bool(forKey: "pref_vegan")
        preferences.glutenFree = defaults.bool(forKey: "pref_gluten_free")
        preferences.dairyFree = defaults.bool(forKey: "pref_dairy_free")
        preferences.keto = defaults.bool(forKey: "pref_keto")
        preferences.lowCarb = defaults.bool(forKey: "pref_low_carb")
        preferences.allergies = defaults.string(forKey: "pref_allergies") ?? ""
        preferences.currency = defaults.string(forKey: "pref_currency") ?? "USD"
        preferences.defaultStore = defaults.string(forKey: "pref_default_store") ?? ""
        preferences.recipeNotifications = defaults.bool(forKey: "pref_recipe_notifications")
        preferences.nutritionReminders = defaults.bool(forKey: "pref_nutrition_reminders")
        preferences.dealNotifications = defaults.bool(forKey: "pref_deal_notifications")
        
        return preferences
    }
    
    func save() {
        let defaults = UserDefaults.standard
        
        defaults.set(vegetarian, forKey: "pref_vegetarian")
        defaults.set(vegan, forKey: "pref_vegan")
        defaults.set(glutenFree, forKey: "pref_gluten_free")
        defaults.set(dairyFree, forKey: "pref_dairy_free")
        defaults.set(keto, forKey: "pref_keto")
        defaults.set(lowCarb, forKey: "pref_low_carb")
        defaults.set(allergies, forKey: "pref_allergies")
        defaults.set(currency, forKey: "pref_currency")
        defaults.set(defaultStore, forKey: "pref_default_store")
        defaults.set(recipeNotifications, forKey: "pref_recipe_notifications")
        defaults.set(nutritionReminders, forKey: "pref_nutrition_reminders")
        defaults.set(dealNotifications, forKey: "pref_deal_notifications")
    }
    
    static func clear() {
        let defaults = UserDefaults.standard
        let keys = [
            "pref_vegetarian", "pref_vegan", "pref_gluten_free", "pref_dairy_free",
            "pref_keto", "pref_low_carb", "pref_allergies", "pref_currency",
            "pref_default_store", "pref_recipe_notifications", "pref_nutrition_reminders",
            "pref_deal_notifications"
        ]
        
        keys.forEach { defaults.removeObject(forKey: $0) }
    }
}

#Preview {
    SettingsView()
} 