import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

class PolaroidEffectViewModel: ObservableObject {
    @Published var polaroidImage = PolaroidImage()
    @Published var showingImagePicker = false
    @Published var showingSaveSuccessAlert = false
    @Published var showingSaveErrorAlert = false
    @Published var saveErrorMessage = ""
    
    private let context = CIContext()
    
    func loadImage() {
        guard let inputImage = polaroidImage.originalImage else { return }
        applyProcessing()
    }
    
    func applyProcessing() {
        guard let inputImage = polaroidImage.originalImage else { return }
        
        let beginImage = CIImage(image: inputImage)
        
        // Desaturate
        let desaturateFilter = CIFilter.colorControls()
        desaturateFilter.inputImage = beginImage
        desaturateFilter.saturation = 0.7
        
        // Sepia tone
        let sepiaFilter = CIFilter.sepiaTone()
        sepiaFilter.inputImage = desaturateFilter.outputImage
        sepiaFilter.intensity = 0.5
        
        // Color adjustment (warming)
        let colorAdjust = CIFilter.colorControls()
        colorAdjust.inputImage = sepiaFilter.outputImage
        colorAdjust.brightness = 0.05
        colorAdjust.contrast = 1.1
        colorAdjust.saturation = 1.1
        
        // Apply grain
        let noiseFilter = CIFilter.randomGenerator()
        let noiseImage = noiseFilter.outputImage!
        
        let scaledIntensity = pow(CGFloat(polaroidImage.grainIntensity) / 100, 1.5)
        let fineGrain = CIVector(x: 0, y: scaledIntensity, z: 0, w: 0)
        
        let colorMatrixFilter = CIFilter.colorMatrix()
        colorMatrixFilter.inputImage = noiseImage
        colorMatrixFilter.rVector = CIVector(x: 0, y: 1, z: 0, w: 0)
        colorMatrixFilter.gVector = CIVector(x: 0, y: 1, z: 0, w: 0)
        colorMatrixFilter.bVector = CIVector(x: 0, y: 1, z: 0, w: 0)
        colorMatrixFilter.aVector = fineGrain
        
        let whiteSpecks = colorMatrixFilter.outputImage!
        let speckCompositor = CIFilter.sourceOverCompositing()
        speckCompositor.inputImage = whiteSpecks
        speckCompositor.backgroundImage = colorAdjust.outputImage
        
        // Apply scratches
        var scratchedImage = speckCompositor.outputImage!
        if polaroidImage.scratchIntensity > 0 {
            let scratchesFilter = CIFilter.randomGenerator()
            let scratchesImage = scratchesFilter.outputImage!.transformed(by: CGAffineTransform(scaleX: 1.0 + CGFloat(polaroidImage.scratchIntensity / 50), y: 25))
            
            let darkenVector = CIVector(x: CGFloat((100 - polaroidImage.scratchIntensity) / 25), y: 0, z: 0, w: 0)
            let darkenBias = CIVector(x: 0, y: 1, z: 1, w: 1)
            let darkeningFilter = CIFilter.colorMatrix()
            darkeningFilter.inputImage = scratchesImage
            darkeningFilter.rVector = darkenVector
            darkeningFilter.gVector = CIVector(x: 0, y: 0, z: 0, w: 0)
            darkeningFilter.bVector = CIVector(x: 0, y: 0, z: 0, w: 0)
            darkeningFilter.aVector = CIVector(x: 0, y: 0, z: 0, w: 0)
            darkeningFilter.biasVector = darkenBias
            
            let randomScratches = darkeningFilter.outputImage!
            let grayscaleFilter = CIFilter.minimumComponent()
            grayscaleFilter.inputImage = randomScratches
            let darkScratches = grayscaleFilter.outputImage!
            
            let oldFilmCompositor = CIFilter.multiplyCompositing()
            oldFilmCompositor.inputImage = darkScratches
            oldFilmCompositor.backgroundImage = speckCompositor.outputImage
            
            scratchedImage = oldFilmCompositor.outputImage!
        }
        
        // Apply vignette
        let vignetteFilter = CIFilter.vignette()
        vignetteFilter.inputImage = scratchedImage
        vignetteFilter.intensity = 0.5
        vignetteFilter.radius = 1.5
        
        // Final composite
        guard let outputImage = vignetteFilter.outputImage?.cropped(to: beginImage!.extent) else { return }
        
        // Add white border
        let borderWidth: CGFloat = 20
        let imageWithBorder = outputImage.applyingFilter("CIAffineClamp")
        let finalImage = imageWithBorder.cropped(to: CGRect(x: -borderWidth,
                                                            y: -borderWidth,
                                                            width: outputImage.extent.width + borderWidth * 2,
                                                            height: outputImage.extent.height + borderWidth * 2))
        
        if let cgimg = context.createCGImage(finalImage, from: finalImage.extent) {
            polaroidImage.processedImage = UIImage(cgImage: cgimg)
        }
    }
    
    func saveImage() {
        guard let processedImage = polaroidImage.processedImage else { return }
        let imageSaver = ImageSaver()
        imageSaver.successHandler = {
            DispatchQueue.main.async {
                self.showingSaveSuccessAlert = true
            }
        }
        imageSaver.errorHandler = { error in
            DispatchQueue.main.async {
                self.saveErrorMessage = error.localizedDescription
                self.showingSaveErrorAlert = true
            }
        }
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
    
}
