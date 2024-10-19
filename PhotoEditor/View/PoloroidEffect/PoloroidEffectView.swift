//
//  PoloroidEffectView.swift
//  PhotoEditor
//
//  Created by Rehan Khan on 10/18/24.
//


//import SwiftUI
//import CoreImage
//import CoreImage.CIFilterBuiltins
//
//struct PolaroidEffectView: View {
//    @State private var image: Image?
//    @State private var inputImage: UIImage?
//    @State private var processedImage: UIImage?
//    @State private var grainIntensity = 0.0
//    @State private var scratchIntensity = 0.0
//    @State private var showingImagePicker = false
//    
//    let context = CIContext()
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                ZStack {
//                    Rectangle()
//                        .fill(Color.secondary)
//                        .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height / 2.5)
//                    if image != nil {
//                        image?
//                            .resizable()
//                            .scaledToFit()
//                    } else {
//                        Text("Tap to select a picture")
//                            .foregroundColor(.white)
//                            .font(.headline)
//                    }
//                }
//                .onTapGesture {
//                    showingImagePicker = true
//                }
//                
//                VStack(spacing: 20) {
//                    // Grain Intensity Slider
//                    VStack {
//                        Text("Grain Intensity: \(Int(grainIntensity))")
//                        Slider(value: $grainIntensity, in: 0...100)
//                            .onChange(of: grainIntensity) { _ in
//                                applyProcessing()
//                            }
//                    }
//                    
//                    // Scratch Intensity Slider
//                    VStack {
//                        Text("Scratch Intensity: \(Int(scratchIntensity))")
//                        Slider(value: $scratchIntensity, in: 0...100)
//                            .onChange(of: scratchIntensity) { _ in
//                                applyProcessing()
//                            }
//                    }
//                }
//                .padding()
//                
//                Button("Save", action: saveImage)
//                    .padding()
//            }
//            .padding()
//            .navigationTitle("Polaroid Effect")
//            .sheet(isPresented: $showingImagePicker) {
//                ImagePicker(image: $inputImage)
//            }
//            .onChange(of: inputImage) { _ in loadImage() }
//        }
//    }
//    
//    func loadImage() {
//        guard let inputImage = inputImage else { return }
//        image = Image(uiImage: inputImage)
//        applyProcessing()
//    }
//    
//    
//    func applyProcessing() {
//        guard let inputImage = inputImage else { return }
//        
//        let beginImage = CIImage(image: inputImage)
//        
//        // Desaturate
//        let desaturateFilter = CIFilter.colorControls()
//        desaturateFilter.inputImage = beginImage
//        desaturateFilter.saturation = 0.7 // Adjust this value to control desaturation
//        
//        // Sepia tone
//        let sepiaFilter = CIFilter.sepiaTone()
//        sepiaFilter.inputImage = desaturateFilter.outputImage
//        sepiaFilter.intensity = 0.5 // Reduced intensity for a subtle effect
//        
//        // Color adjustment (warming)
//        let colorAdjust = CIFilter.colorControls()
//        colorAdjust.inputImage = sepiaFilter.outputImage
//        colorAdjust.brightness = 0.05
//        colorAdjust.contrast = 1.1
//        colorAdjust.saturation = 1.1
//        
//        // Apply grain with improved scaling
//           let noiseFilter = CIFilter.randomGenerator()
//           let noiseImage = noiseFilter.outputImage!
//           
//           // Improved scaling for grain intensity
//           let scaledIntensity = pow(CGFloat(grainIntensity) / 100, 1.5) // Cubic scaling for more noticeable steps
//           let fineGrain = CIVector(x: 0, y: scaledIntensity, z: 0, w: 0)
//           
//           let colorMatrixFilter = CIFilter.colorMatrix()
//           colorMatrixFilter.inputImage = noiseImage
//           colorMatrixFilter.rVector = CIVector(x: 0, y: 1, z: 0, w: 0)
//           colorMatrixFilter.gVector = CIVector(x: 0, y: 1, z: 0, w: 0)
//           colorMatrixFilter.bVector = CIVector(x: 0, y: 1, z: 0, w: 0)
//           colorMatrixFilter.aVector = fineGrain
//           
//           let whiteSpecks = colorMatrixFilter.outputImage!
//           let speckCompositor = CIFilter.sourceOverCompositing()
//           speckCompositor.inputImage = whiteSpecks
//           speckCompositor.backgroundImage = colorAdjust.outputImage
//        
////        // Apply grain
////        let noiseFilter = CIFilter.randomGenerator()
////        let noiseImage = noiseFilter.outputImage!
////        
////        let whitenVector = CIVector(x: 0, y: 1, z: 0, w: 0)
////        let fineGrain = CIVector(x: 0, y: CGFloat(grainIntensity / 100), z: 0, w: 0)
////        let colorMatrixFilter = CIFilter.colorMatrix()
////        colorMatrixFilter.inputImage = noiseImage
////        colorMatrixFilter.rVector = whitenVector
////        colorMatrixFilter.gVector = whitenVector
////        colorMatrixFilter.bVector = whitenVector
////        colorMatrixFilter.aVector = fineGrain
////        
////        let whiteSpecks = colorMatrixFilter.outputImage!
////        let speckCompositor = CIFilter.sourceOverCompositing()
////        speckCompositor.inputImage = whiteSpecks
////        speckCompositor.backgroundImage = colorAdjust.outputImage
//        
//        // Apply scratches only if scratchIntensity > 0
//        var scratchedImage = speckCompositor.outputImage!
//        if scratchIntensity > 0 {
//            let scratchesFilter = CIFilter.randomGenerator()
//            let scratchesImage = scratchesFilter.outputImage!.transformed(by: CGAffineTransform(scaleX: 1.0 + CGFloat(scratchIntensity / 50), y: 25))
//
//            let darkenVector = CIVector(x: CGFloat((100 - scratchIntensity) / 25), y: 0, z: 0, w: 0)
//            let darkenBias = CIVector(x: 0, y: 1, z: 1, w: 1)
//            let darkeningFilter = CIFilter.colorMatrix()
//            darkeningFilter.inputImage = scratchesImage
//            darkeningFilter.rVector = darkenVector
//            darkeningFilter.gVector = CIVector(x: 0, y: 0, z: 0, w: 0)
//            darkeningFilter.bVector = CIVector(x: 0, y: 0, z: 0, w: 0)
//            darkeningFilter.aVector = CIVector(x: 0, y: 0, z: 0, w: 0)
//            darkeningFilter.biasVector = darkenBias
//
//            let randomScratches = darkeningFilter.outputImage!
//            let grayscaleFilter = CIFilter.minimumComponent()
//            grayscaleFilter.inputImage = randomScratches
//            let darkScratches = grayscaleFilter.outputImage!
//
//            let oldFilmCompositor = CIFilter.multiplyCompositing()
//            oldFilmCompositor.inputImage = darkScratches
//            oldFilmCompositor.backgroundImage = speckCompositor.outputImage
//            
//            scratchedImage = oldFilmCompositor.outputImage!
//        }
//        
//        // Apply vignette
//        let vignetteFilter = CIFilter.vignette()
//        vignetteFilter.inputImage = scratchedImage
//        vignetteFilter.intensity = 0.5
//        vignetteFilter.radius = 1.5
//        
//        // Final composite
//        guard let outputImage = vignetteFilter.outputImage?.cropped(to: beginImage!.extent) else { return }
//        
//        // Add white border
//        let borderWidth: CGFloat = 20
//        let imageWithBorder = outputImage.applyingFilter("CIAffineClamp")
//        let finalImage = imageWithBorder.cropped(to: CGRect(x: -borderWidth,
//                                                            y: -borderWidth,
//                                                            width: outputImage.extent.width + borderWidth * 2,
//                                                            height: outputImage.extent.height + borderWidth * 2))
//        
//        if let cgimg = context.createCGImage(finalImage, from: finalImage.extent) {
//            let uiImage = UIImage(cgImage: cgimg)
//            processedImage = uiImage
//            image = Image(uiImage: uiImage)
//        }
//    }
//    
//    func saveImage() {
//        guard let processedImage = processedImage else { return }
//        
//        let imageSaver = ImageSaver()
//        imageSaver.successHandler = { print("Success!") }
//        imageSaver.errorHandler = { print("Oops: \($0.localizedDescription)") }
//        imageSaver.writeToPhotoAlbum(image: processedImage)
//    }
//}

import SwiftUI

struct PolaroidEffectView: View {
    @StateObject private var viewModel = PolaroidEffectViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.secondary)
                        .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height / 2.5)
                    if let processedImage = viewModel.polaroidImage.processedImage {
                        Image(uiImage: processedImage)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Text("Tap to select a picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .onTapGesture {
                    viewModel.showingImagePicker = true
                }
                
                VStack(spacing: 20) {
                    // Grain Intensity Slider
                    VStack {
                        Text("Grain Intensity: \(Int(viewModel.polaroidImage.grainIntensity))")
                        Slider(value: $viewModel.polaroidImage.grainIntensity, in: 0...100)
                            .onChange(of: viewModel.polaroidImage.grainIntensity) { _ in
                                viewModel.applyProcessing()
                            }
                    }
                    
                    // Scratch Intensity Slider
                    VStack {
                        Text("Scratch Intensity: \(Int(viewModel.polaroidImage.scratchIntensity))")
                        Slider(value: $viewModel.polaroidImage.scratchIntensity, in: 0...100)
                            .onChange(of: viewModel.polaroidImage.scratchIntensity) { _ in
                                viewModel.applyProcessing()
                            }
                    }
                }
                .padding()
                
                Button("Save", action: viewModel.saveImage)
                    .padding()
            }
            .padding()
            .navigationTitle("Polaroid Effect")
            .sheet(isPresented: $viewModel.showingImagePicker) {
                ImagePicker(image: $viewModel.polaroidImage.originalImage)
            }
            .onChange(of: viewModel.polaroidImage.originalImage) { _ in viewModel.loadImage() }
            .alert("Save Successful", isPresented: $viewModel.showingSaveSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your image has been saved to the photo album.")
            }
            .alert("Save Failed", isPresented: $viewModel.showingSaveErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("\($viewModel.saveErrorMessage)")
            }
        }
    }
}


#Preview {
    PolaroidEffectView()
}
