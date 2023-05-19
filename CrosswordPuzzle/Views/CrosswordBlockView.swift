//
//  CrosswordBlockView.swift
//  TestFocus
//
//  Created by Caroline Ha on 5/3/23.
//

import SwiftUI

struct CrosswordBlockView: View {
    // var index: Int
    var row: Int
    var col: Int
    //    var tip = -1
    
    @Binding var selectedRow: Int
    @Binding var selectedCol: Int
    @Binding var blockState: [[BlockState]]
    @Binding var direction: CrosswordsGenerator.WordDirection
    @Binding var newHorizontalTip: Int
    @Binding var newVerticalTip: Int
    @Binding var wordArray: [WordArray]
    @Binding var isShowError: Bool
    
    let gridSize: Int
    var body: some View {
        
        ZStack {
            HStack(spacing: 0) {
                Text(blockState[row][col].tip[.horizontal] == -1 && blockState[row][col].tip[.vertical] == -1 ? " " :
                        (direction == .horizontal ?
                         (blockState[row][col].tip[.horizontal] != -1 ? String(blockState[row][col].tip[.horizontal]!) : String(blockState[row][col].tip[.vertical]!)
                         )
                         :(blockState[row][col].tip[.vertical] != -1 ?
                           String(blockState[row][col].tip[.vertical]!) :
                            String(blockState[row][col].tip[.horizontal]!)
                          )
                        )
                )
                .font(.caption)
                .frame(width: getButtonSize()*0.4, height: getButtonSize()*0.4)
                //  .background(.red)    //test frame overlay
                .cornerRadius(20)
                .foregroundColor(.red)
                .fontWeight(.bold)
                .minimumScaleFactor(0.6)
                .position()
                
                Spacer()
            }
            .offset(x: 0, y: 1)
            
            ZStack{
                Text(blockState[row][col].inputContent)
                    .foregroundColor(blockState[row][col].textColor)
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(width: getButtonSize()*0.5,height: getButtonSize()*0.5)
                // .background(.yellow)
                    .minimumScaleFactor(0.50)
            }
        }
        .padding()
        .foregroundColor(.black)
        .frame(width: getButtonSize(), height: getButtonSize())
        .background(blockState[row][col].bgColor)
        .border(blockState[row][col].isSelected ? .yellow : .black, width: blockState[row][col].isSelected ? 3 : 0.5)
        .onTapGesture {
            withAnimation {
                //set seletedBlock Index
                selectedRow = row
                selectedCol = col
                
                //clear previous states
                for (row, rowBlock) in blockState.enumerated() {
                    for (col, _) in rowBlock.enumerated() {
                        blockState[row][col].bgColor = .white
                        blockState[row][col].isSelected = false
                    }
                }
                
                //set selected blocks states to be highlight
                blockState[row][col].isSelected = true
                
                //get Tip based on seletedBlock for update blocks
                guard blockState[selectedRow][selectedCol].answerHint[.horizontal] != nil else { return }
                newHorizontalTip = Int(blockState[selectedRow][selectedCol].answerHint[.horizontal]!) ?? 0
                
                guard blockState[selectedRow][selectedCol].answerHint[.vertical] != nil else { return }
                newVerticalTip = Int(blockState[selectedRow][selectedCol].answerHint[.vertical]!) ?? 0
           //     print("Block[\(selectedRow)][\(selectedCol)] Tapped, Tip is horizontal: \(newHorizontalTip), vertical: \(newVerticalTip)")
                
                if newHorizontalTip != 0 || newVerticalTip != 0 {  //Index should within the range
                    
                    //update block bgcolor  - for single direction
                    if blockState[row][col].charDirection != .both {
                        
                    //    print("singal CharDirection block bgColor update")
                        
                        // which direction need to be update
                        let direction: BlockState.CharDirection = direction == .horizontal ? .horizontal : .vertical
                        
                        if direction == .horizontal && newHorizontalTip != 0 {
                            
                            for (row, rowBlock) in blockState.enumerated() {
                                for (col, _) in rowBlock.enumerated() {
                                    blockState[row][col].bgColor = .white
                                    
                                    if blockState[row][col].answerHint[.horizontal] == String(newHorizontalTip) {
                                        blockState[row][col].bgColor = .cyan
                                    }
                                }
                            }
                            
                        }
                        if direction == .vertical && newVerticalTip != 0 {
                            for (row, rowBlock) in blockState.enumerated() {
                                for (col, _) in rowBlock.enumerated() {
                                    blockState[row][col].bgColor = .white
                                    
                                    if blockState[row][col].answerHint[.vertical] == String(newVerticalTip) {
                                        blockState[row][col].bgColor = .cyan
                                    }
                                }
                            }
                        }
                    }
                    
                    //update bgColor - for both direction
                    if blockState[row][col].charDirection == .both {
                        
                     //   print("both CharDirection block bgColor update")
                        
                        if direction == .horizontal {
                            for (col, _) in blockState[row].enumerated() {
                                if blockState[row][col].answerHint[.horizontal] == String(newHorizontalTip) {
                                    blockState[row][col].bgColor = .cyan
                                }
                            }
                        }
                        
                        if direction == .vertical {
                            for (row, rowBlock) in blockState.enumerated() {
                                for (_, _) in rowBlock.enumerated() {
                                    if blockState[row][col].answerHint[.vertical] == String(newVerticalTip) {
                                        blockState[row][selectedCol].bgColor = .cyan
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: blockState[row][col].inputContent) { _ in
          //  showRevealedBlocks()
            
        //    print("blockState char changed \(blockState[row][col].inputContent)")
            
            checkAnswer(row: row, col: col, inputContent: blockState[row][col].inputContent)
            
            blockState[selectedRow][selectedCol].isSelected = false
            
            //auto cursor
            if direction == .vertical {
                selectedRow += 1
                if blockState[selectedRow][selectedCol].answerContent == "-" {
                    selectedRow -= 1
                }
                blockState[selectedRow][selectedCol].isSelected = true
            }
            
            if direction == .horizontal {
                selectedCol += 1
                if blockState[selectedRow][selectedCol].answerContent == "-" {
                    selectedCol -= 1
                }
                blockState[selectedRow][selectedCol].isSelected = true
            }
        }
        //.onAppear {
        //  checkAnswer(row: selectedRow, col: selectedCol)
        // }
    }
    
    private func checkAnswer(row: Int,col: Int, inputContent: String) {
     //   print("checkAnswer called, showError: \(isShowError)")
        if isShowError {
            if blockState[row][col].inputContent != "" {
                if inputContent != blockState[row][col].answerContent.uppercased() {
                    blockState[row][col].textColor = .red
                }
            }
        }
    }
    
    private func getButtonSize() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let buttonCount: CGFloat = CGFloat(integerLiteral: gridSize)
        let size = (screenWidth - (2 * 5)) / buttonCount
        return size
    }

}

struct CrosswordBlockView_Previews: PreviewProvider {
    
    static var previews: some View {
        let block: [[BlockState]] = [[
            .init(answerContent: "c", inputContent: "A", textColor: .black, isSelected: true, bgColor: .white, rowIndex: 0, colIndex: 0, tip: [.horizontal: -1 , .vertical: 1], answerHint: [.horizontal:"", .vertical: "1"], charDirection: .horizontal, revealed: false)
        ]]
        CrosswordBlockView(
            row: 0,
            col: 0,
            selectedRow: .constant(0),
            selectedCol: .constant(0),
            blockState: .constant(block),
            direction: .constant(CrosswordsGenerator.WordDirection.horizontal),
            newHorizontalTip: .constant(-1),
            newVerticalTip: .constant(1),
            wordArray: .constant([WordArray(content: CrosswordsGenerator.Word(word: "cat", column: 13, row: 1, direction: CrosswordsGenerator.WordDirection.vertical), tip: 1)]), isShowError: .constant(true),
                           gridSize: 10)
    }
}
