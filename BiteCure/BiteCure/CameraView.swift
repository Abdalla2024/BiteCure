//
//  CameraView.swift
//  BiteCure
//
//  Created by Abdalla Abdelmagid on 7/8/25.
//

import SwiftUI
import VisionKit
import Vision
import UIKit

struct CameraView: View {
    @Binding var scannedItems: [GroceryItem]
    @Environment(\.presentationMode) var presentationMode
    @State private var isProcessing = false
    @State private var showingResults = false
    @State private var currentResult: ScanResult?
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @StateObject private var aiService = AIService()
    
    var body: some View {
        NavigationView {
            VStack {
                if isProcessing {
                    ProcessingView()
                } else {
                    CameraPreview()
                        .overlay(
                            CameraOverlay(),
                            alignment: .center
                        )
                }
                
                // Control buttons
                HStack(spacing: 40) {
                    // Photo Library
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    // Capture button
                    Button(action: captureImage) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                                    .frame(width: 60, height: 60)
                            )
                    }
                    
                    // Flash toggle (placeholder)
                    Button(action: {
                        // TODO: Implement flash toggle
                    }) {
                        Image(systemName: "bolt.slash")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 40)
            }
            .background(Color.black)
            .navigationTitle("Scan Groceries")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showingResults) {
            if let result = currentResult {
                ResultsView(result: result, scannedItems: $scannedItems)
            }
        }
        .onChange(of: selectedImage) { image in
            if let image = image {
                processImage(image)
            }
        }
    }
    
    private func captureImage() {
        // TODO: Implement actual camera capture
        // For now, we'll simulate with a placeholder
        let placeholderImage = UIImage(systemName: "camera") ?? UIImage()
        processImage(placeholderImage)
    }
    
    private func processImage(_ image: UIImage) {
        isProcessing = true
        
        // Perform OCR using Vision framework
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            DispatchQueue.main.async {
                self.isProcessing = false
                
                if let error = error {
                    print("OCR Error: \(error.localizedDescription)")
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    return
                }
                
                let recognizedText = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")
                
                print("Recognized text: \(recognizedText)")
                
                // Process the recognized text with AI
                self.processWithAI(recognizedText: recognizedText, image: image)
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        do {
            try requestHandler.perform([request])
        } catch {
            DispatchQueue.main.async {
                self.isProcessing = false
                print("Failed to perform OCR: \(error.localizedDescription)")
            }
        }
    }
    
    private func processWithAI(recognizedText: String, image: UIImage) {
        Task {
            // Use the AI service to analyze the recognized text
            let result = await aiService.analyzeGroceryText(recognizedText)
            
            DispatchQueue.main.async {
                self.currentResult = result
                self.showingResults = true
            }
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        
        // TODO: Implement actual camera preview
        // For now, show a placeholder
        let label = UILabel()
        label.text = "Camera Preview\n(Implementation needed)"
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update camera preview if needed
    }
}

struct CameraOverlay: View {
    var body: some View {
        Rectangle()
            .stroke(Color.green, lineWidth: 2)
            .frame(width: 250, height: 150)
            .overlay(
                VStack {
                    Text("Position groceries here")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.top, -30)
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "viewfinder")
                            .foregroundColor(.green)
                        Text("Tap to scan")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, -30)
                }
            )
    }
}

struct ProcessingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 50))
                .foregroundColor(.green)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(Animation.linear(duration: 2).repeatForever(autoreverses: false), value: isAnimating)
            
            Text("Processing with AI...")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Analyzing nutritional info and generating recipes")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// Supporting data models
struct ScanResult {
    let recognizedText: String
    let detectedItems: [DetectedItem]
    let nutritionalAnalysis: String
    let recipeSuggestions: [String]
    let totalEstimatedCost: Double
}

struct DetectedItem {
    let name: String
    let confidence: Double
    let estimatedCost: Double
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    CameraView(scannedItems: .constant([]))
} 