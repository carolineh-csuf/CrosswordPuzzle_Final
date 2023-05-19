//
//  ContentView.swift
//  TestFocus
//
//  Created by Caroline Ha on 4/5/23.
//

import SwiftUI

struct WordArray {
    public var content: CrosswordsGenerator.Word
    public var tip: Int
}

struct ContentView: View {
    @Binding var gridSize: Int
    @Binding var isShowTimer: Bool
    @Binding var isShowError: Bool
    @Binding var words: [String]
    @Binding var wordsDictionary: [String : String]
    
    @State var wordArray: [WordArray] = []
    
    @State var blockTextStruct: [[BlockState]] = [[
        .init(answerContent: "-", inputContent: "", textColor: .black, isSelected: false, bgColor: .white, rowIndex: 0, colIndex: 0, tip: [.horizontal: -1 , .vertical: -1], answerHint: [.horizontal:"", .vertical: ""], charDirection: .horizontal, revealed: false)
    ]]
    
    var body: some View {
        
        CrosswordView(gridSize: gridSize, wordDictionary: $wordsDictionary, wordArray: $wordArray, blockTextStruct: $blockTextStruct, isShowTimer: $isShowTimer, isShowError: $isShowError)
            .onAppear {
                let crosswordsGenerator = CrosswordsGenerator(columns: gridSize, rows: gridSize, words: words)
                
                crosswordsGenerator.generate()
                _ = crosswordsGenerator.result
                
                blockTextStruct = crosswordsGenerator.printGrid()
                //  wordCount = crosswordsGenerator.result.count
                
                var tip: Int = 1
                for result in crosswordsGenerator.result {
                    wordArray.append(.init(content: result, tip: tip))
                    tip += 1
                }
            //    print("input sortedWordArray is \(wordArray)")
                
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(gridSize: Binding.constant(15), isShowTimer: .constant(true), isShowError: .constant(true), words: .constant([]), wordsDictionary: .constant([:]))
    }
}
