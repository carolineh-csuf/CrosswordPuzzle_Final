//
//  GridView.swift
//  TestFocus
//
//  Created by csuftitan on 5/18/23.
//

import SwiftUI

struct GridView: View {
    @Binding var isSizeSelected: Bool
    @Binding var selectedSize: Int
    
    let sizes = [10,13,15]
    
    var body: some View {
        Section {
            HStack(spacing: 10){
                ForEach(sizes, id: \.self) { size in
                    
                    Button(action: {
                        isSizeSelected = true
                       // selectedSize = size
                        switch size {
                        case 10:
                            selectedSize = 10
                        case 13:
                            selectedSize = 13
                        case 15:
                            selectedSize = 15
                        default:
                            selectedSize = 15
                        }
                        
                    }) {
                        VStack {
                            Image(systemName: "squareshape.split.3x3")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100,height: 100)
                                .padding(.horizontal)
                                .padding(.top)
                            
                            Text("\(size) X \(size)")
                            // .padding()
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical)
                                .frame(maxWidth: .infinity)
                                .background(selectedSize == size ? .yellow : .lightBackground)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        // .background(.red)
                        
                        .overlay(RoundedRectangle(cornerRadius: 10) .stroke(selectedSize == size ? .yellow : .lightBackground))
                        //  }
                    }
                }
                
            }
        }
    }
}
