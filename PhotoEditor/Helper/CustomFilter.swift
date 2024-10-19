//
//  CustomFilter.swift
//  PhotoEditor
//
//  Created by Rehan Khan on 10/14/24.
//

import SwiftUI
import CoreImage

class CustomFilter: CIFilter {
    var inputImage: CIImage?
    let kernel: (CIImage?) -> CIImage?
    
    init(kernel: @escaping (CIImage?) -> CIImage?) {
        self.kernel = kernel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var outputImage: CIImage? {
        return kernel(inputImage)
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == kCIInputImageKey {
            inputImage = value as? CIImage
        }
    }
}
