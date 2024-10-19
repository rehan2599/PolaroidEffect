//
//  AdjustmentsView.swift
//  PhotoEditor
//
//  Created by Rehan Khan on 10/14/24.
//

import SwiftUI

struct AdjustmentsView: View {
    @Binding var exposure: Float
    @Binding var brilliance: Float
    @Binding var highlights: Float
    @Binding var shadows: Float
    @Binding var contrast: Float
    @Binding var brightness: Float
    @Binding var blackPoint: Float
    @Binding var saturation: Float
    @Binding var vibrance: Float
    @Binding var warmth: Float
    @Binding var tint: Float
    
    var body: some View {
        ScrollView{
            VStack(spacing: 10) {
                Group{
                    AdjustmentSlider(value: $exposure, name: "Exposure", range: -2...2)
                    
                    AdjustmentSlider(value: $contrast, name: "Contrast", range: -1...1)
                    
                    AdjustmentSlider(value: $highlights, name: "Highlights", range: -1...1)
                    
                    AdjustmentSlider(value: $shadows, name: "Shadows", range: -1...1)
                    
                    AdjustmentSlider(value: $saturation, name: "Saturation", range: -1...1)
                    
                    AdjustmentSlider(value: $vibrance, name: "Vibrance", range: -1...1)
                    
                    AdjustmentSlider(value: $brightness, name: "Brightness", range: -1...1)
                    
                    AdjustmentSlider(value: $brilliance, name: "Brilliance", range: -1...1)
                    
                    AdjustmentSlider(value: $blackPoint, name: "Black Point", range: -1...1)
                    
                    AdjustmentSlider(value: $warmth, name: "Warmth", range: -1...1)
                    
                    AdjustmentSlider(value: $tint, name: "Tint", range: -1...1)
                }
            }
            .padding()
        }
    }
}


struct AdjustmentSlider: View {
    @Binding var value: Float
    let name: String
    let range: ClosedRange<Float>
    
    var body: some View {
        HStack {
            Text(name)
            Slider(value: $value, in: range, step: 0.1)
        }
        .padding(.horizontal)
    }
}
