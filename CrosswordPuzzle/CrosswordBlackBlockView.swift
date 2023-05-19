//
//  CrosswordBlackBlockView.swift
//  TestFocus
//
//  Created by csuftitan on 5/3/23.
//

import SwiftUI

struct CrosswordBlackBlockView: View {
    var row: Int
    var col: Int
    //   var value: String
    
    let gridSize: Int
    
    var body: some View {
        //        Text(" ")
        //            .frame(width: getButtonSize(), height: getButtonSize())
        //            .background(.black)
        //            .foregroundColor(.white)
        //            .border(.white)
        
        Image("BlackBlock")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: getButtonSize(), height: getButtonSize())
            .border(.white, width: 1)
    }
    
    private func getButtonSize() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let buttonCount: CGFloat = CGFloat(integerLiteral: gridSize)
        let size = (screenWidth - (2 * 5)) / buttonCount
        return size
    }
}

struct CrosswordBlackBlockView_Previews: PreviewProvider {
    static var previews: some View {
        CrosswordBlackBlockView(row: 0, col: 0, gridSize: 15)
    }
}
