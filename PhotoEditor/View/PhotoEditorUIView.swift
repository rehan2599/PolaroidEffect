//
//  PhotoEditorUIView.swift
//  PhotoEditor
//
//  Created by Rehan Khan on 10/14/24.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

enum FilterType {
    case original
    case vivid
    case vividWarm
    case crystallize
    case sepiaTone
    
}

struct PhotoEditorUIView: View {
    //Filter
    @State private var image: Image?
    @State private var filterIntensity = 0.0
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var showingFilterSheet = false
    @State private var selectedFilterType: FilterType = .original
    @State private var currentFilter: CIFilter = CIFilter.colorControls()
    
    //Adjustments
    @State private var exposure: Float = 0
    @State private var brilliance: Float = 0
    @State private var highlights: Float = 0
    @State private var shadows: Float = 0
    @State private var contrast: Float = 0
    @State private var brightness: Float = 0
    @State private var blackPoint: Float = 0
    @State private var saturation: Float = 0
    @State private var vibrance: Float = 0
    @State private var warmth: Float = 0
    @State private var tint: Float = 0
    @State private var showingAdjustmentsSheet = false
    
    //General
    let context = CIContext()
    
    var body: some View {
        NavigationStack{
            VStack {
                ZStack{
                    Rectangle()
                        .fill(.secondary)
                        .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height/2.5)
                    Text("Tap to select a picture")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    image?
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                    //select an image
                    showingImagePicker = true
                }
                Spacer()
                HStack{
                    Text("Intensity")
                    Slider(value: $filterIntensity)
                        .onChange(of: filterIntensity) { _ in
                            applyProcessing()
                        }
                }
                .padding(.vertical)
                
                HStack{
                    Button("Change Filter"){
                        showingFilterSheet = true
                    }
                    .padding(.trailing, 10)
                    Button("Adjustments"){
                        
                        showingAdjustmentsSheet = true
                    }
                    Spacer()
                    Button("Save",action: saveImage)
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("PhotoEditor")
            .onChange(of: inputImage) { _ in
                loadImage()
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .confirmationDialog("Select a filter", isPresented: $showingFilterSheet) {
                Button("Original") { setFilter(CIFilter.colorControls(), type: .original) }
                Button("Crystallize"){ setFilter(CIFilter.crystallize(), type: .crystallize) }
                Button("Sepia Tone"){ setFilter(CIFilter.sepiaTone(), type: .sepiaTone) }
                Button("Vivid") { setFilter(vividFilter(), type: .vivid) }
                Button("Vivid Warm") { setFilter(vividWarmFilter(), type: .vividWarm) }
                Button("Cancel", role: .cancel){}
            }
            .sheet(isPresented: $showingAdjustmentsSheet) {
                AdjustmentsView(
                    exposure: $exposure,
                    brilliance: $brilliance,
                    highlights: $highlights,
                    shadows: $shadows,
                    contrast: $contrast,
                    brightness: $brightness,
                    blackPoint: $blackPoint,
                    saturation: $saturation,
                    vibrance: $vibrance,
                    warmth: $warmth,
                    tint: $tint
                )
                .onChange(of: exposure) { _ in applyProcessing() }
                .onChange(of: brilliance) { _ in applyProcessing() }
                .onChange(of: highlights) { _ in applyProcessing() }
                .onChange(of: shadows) { _ in applyProcessing() }
                .onChange(of: contrast) { _ in applyProcessing() }
                .onChange(of: brightness) { _ in applyProcessing() }
                .onChange(of: blackPoint) { _ in applyProcessing() }
                .onChange(of: saturation) { _ in applyProcessing() }
                .onChange(of: vibrance) { _ in applyProcessing() }
                .onChange(of: warmth) { _ in applyProcessing() }
                .onChange(of: tint) { _ in applyProcessing() }
                .presentationDetents([.height(350)])
                
            }
        }
    }
    func loadImage(){
        guard let inputImage = inputImage else{return}
        // Display the original image first
        DispatchQueue.main.async {
            self.image = Image(uiImage: inputImage)
        }

        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func applyProcessing(){
        let inputkeys = currentFilter.inputKeys
        
        if inputkeys.contains(kCIInputIntensityKey){
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputkeys.contains(kCIInputRadiusKey){
            currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey)
        }
        if inputkeys.contains(kCIInputScaleKey){
            currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey )
        }
        guard var outputImage = currentFilter.outputImage else { return }
        
        outputImage = applyExposure(to: outputImage)
        outputImage = applyContrast(to: outputImage)
        outputImage = applyHighlights(to: outputImage)
        outputImage = applyShadows(to: outputImage)
        outputImage = applySaturation(to: outputImage)
        outputImage = applyBrightness(to: outputImage)
        outputImage = applyVibrance(to: outputImage)
        outputImage = applyBrilliance(to: outputImage)
        outputImage = applyBlackPoint(to: outputImage)
        outputImage = applyWarmth(to: outputImage)
        outputImage = applyTint(to: outputImage)
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent){
            let uiImage = UIImage(cgImage: cgimg)
            DispatchQueue.main.async {
                self.image = Image(uiImage: uiImage)
            }
            processedImage = uiImage
        }
    }
    
    func applyExposure(to image: CIImage) -> CIImage {
        let exposureFilter = CIFilter.exposureAdjust()
        exposureFilter.inputImage = image
        exposureFilter.setValue(exposure, forKey: kCIInputEVKey)
        return exposureFilter.outputImage ?? image
    }
    
    func applyContrast(to image: CIImage) -> CIImage {
        let contrastFilter = CIFilter.colorControls()
        contrastFilter.inputImage = image
        contrastFilter.setValue(1 + contrast, forKey: kCIInputContrastKey)
        return contrastFilter.outputImage ?? image
    }
    
    func applyHighlights(to image: CIImage) -> CIImage {
        let highlightFilter = CIFilter.highlightShadowAdjust()
        highlightFilter.inputImage = image
        highlightFilter.setValue(1 + highlights, forKey: "inputHighlightAmount")
        return highlightFilter.outputImage ?? image
    }
    
    func applyShadows(to image: CIImage) -> CIImage {
        let shadowFilter = CIFilter.highlightShadowAdjust()
        shadowFilter.inputImage = image
        shadowFilter.setValue(-shadows, forKey: "inputShadowAmount")
        return shadowFilter.outputImage ?? image
    }
    
    func applySaturation(to image: CIImage) -> CIImage {
        let saturationFilter = CIFilter.colorControls()
        saturationFilter.inputImage = image
        saturationFilter.setValue(1 + saturation, forKey: kCIInputSaturationKey)
        return saturationFilter.outputImage ?? image
    }
    func applyVibrance(to image: CIImage) -> CIImage {
        let vibranceFilter = CIFilter.vibrance()
        vibranceFilter.inputImage = image
        vibranceFilter.setValue(vibrance, forKey: kCIInputAmountKey)
        return vibranceFilter.outputImage ?? image
    }
    
    func applyBrightness(to image: CIImage) -> CIImage {
        let brightnessFilter = CIFilter.colorControls()
        brightnessFilter.inputImage = image
        brightnessFilter.setValue(brightness, forKey: kCIInputBrightnessKey)
        return brightnessFilter.outputImage ?? image
    }
    
    func applyBrilliance(to image: CIImage) -> CIImage {
        let brillianceFilter = CIFilter.colorControls()
        
        // Set the input image
        brillianceFilter.setValue(image, forKey: kCIInputImageKey)
        
        // Apply multiple adjustments based on the brilliance value
        brillianceFilter.setValue(1 + brilliance * 0.1, forKey: kCIInputSaturationKey)
        brillianceFilter.setValue(brilliance * 0.1, forKey: kCIInputBrightnessKey)
        brillianceFilter.setValue(1 + brilliance * 0.05, forKey: kCIInputContrastKey)
        
        // Return the processed image or the original image if the filter fails
        if let brillianceOutput = brillianceFilter.outputImage {
            return brillianceOutput
        } else {
            return image
        }
    }
    
    
    func applyBlackPoint(to image: CIImage) -> CIImage {
        // If blackPoint is 0
        if blackPoint == 0 {
            return image
        }
        
        // Create a color matrix filter
        guard let colorMatrix = CIFilter(name: "CIColorMatrix") else {
            return image
        }
        
        let adjustment = blackPoint * 0.1 // Adjust the multiplier as needed
        
        // Set up the color matrix
        let vector = CIVector(x: 1, y: 0, z: 0, w: 0)
        
        colorMatrix.setValue(image, forKey: kCIInputImageKey)
        colorMatrix.setValue(vector, forKey: "inputRVector")
        colorMatrix.setValue(vector, forKey: "inputGVector")
        colorMatrix.setValue(vector, forKey: "inputBVector")
        colorMatrix.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")
        colorMatrix.setValue(CIVector(x: CGFloat(adjustment), y: CGFloat(adjustment), z: CGFloat(adjustment), w: 0), forKey: "inputBiasVector")
        
        // Apply the color matrix filter
        guard let outputImage = colorMatrix.outputImage else {
            return image
        }
        
        return outputImage
    }
    
    
    func applyWarmth(to image: CIImage) -> CIImage {
        let warmthFilter = CIFilter.temperatureAndTint()
        warmthFilter.inputImage = image
        
        warmthFilter.setValue(CIVector(x: 5000 + CGFloat(warmth) * 1000, y: 0), forKey: "inputNeutral")
        return warmthFilter.outputImage ?? image
    }
    
    func applyTint(to image: CIImage) -> CIImage {
        // Check if the tint is 0
        if tint == 0 {
            return image
        }
        
        let tintFilter = CIFilter.temperatureAndTint()
        tintFilter.inputImage = image
        
        tintFilter.targetNeutral = CIVector(x: 6500, y: CGFloat(tint) * 100) 
        
        return tintFilter.outputImage ?? image
    }
    
    func vividFilter() -> CIFilter {
        return CustomFilter { inputImage in
            guard let inputImage = inputImage else { return inputImage }
            
            let colorControls = CIFilter.colorControls()
            colorControls.setValue(inputImage, forKey: kCIInputImageKey)
            colorControls.setValue(1.2, forKey: kCIInputSaturationKey) // Increase saturation
            colorControls.setValue(0.1, forKey: kCIInputBrightnessKey) // Slightly increase brightness
            colorControls.setValue(1.2, forKey: kCIInputContrastKey)   // Increase contrast
            
            return colorControls.outputImage ?? inputImage
        }
    }
    
    func vividWarmFilter() -> CIFilter {
        return CustomFilter { inputImage in
            guard let inputImage = inputImage else { return inputImage }
            
            // First, apply the vivid filter
            let vividFilter = vividFilter()
            vividFilter.setValue(inputImage, forKey: kCIInputImageKey)
            guard let vividImage = vividFilter.outputImage else { return inputImage }
            
            // Then, apply a warm temperature adjustment
            let temperatureAndTint = CIFilter.temperatureAndTint()
            temperatureAndTint.setValue(vividImage, forKey: kCIInputImageKey)
            temperatureAndTint.setValue(CIVector(x: 6500, y: 0), forKey: "inputNeutral")
            temperatureAndTint.setValue(CIVector(x: 5500 - filterIntensity * 1000, y: filterIntensity * 10), forKey: "inputTargetNeutral")
            
            return temperatureAndTint.outputImage ?? vividImage
        }
    }
    
    
    
    func setFilter(_ filter: CIFilter, type: FilterType) {
        currentFilter = filter
        selectedFilterType = type
        print("Selected filter type: \(selectedFilterType)")
        
        switch selectedFilterType {
        case .original:
            filterIntensity = 0.0
        case .crystallize:
            filterIntensity = 0.1
        case .vivid, .vividWarm, .sepiaTone:
            filterIntensity = 1
        }
        
        loadImage()
    }
    
    
    func saveImage(){
        guard let processedImage = processedImage else {return}
        let imageSaver = ImageSaver()
        imageSaver.successHandler = {
            print("Success")
        }
        imageSaver.errorHandler = {
            print("Oops! \($0.localizedDescription)")
        }
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
}

#Preview {
    PhotoEditorUIView()
}


