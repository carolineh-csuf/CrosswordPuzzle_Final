//
//  Crossword.swift
//  TestFocus
//
//  Created by Caroline Ha on 4/5/23.
//

import SwiftUI
import UIKit

struct BlockState : Equatable {
    enum CharDirection : Hashable {
        case horizontal
        case vertical
        case both
    }
    
    var answerContent: String
    var inputContent: String
    var textColor: Color
    var isSelected: Bool
    var bgColor: Color
    let rowIndex: Int
    let colIndex: Int
    var tip:[CrosswordsGenerator.WordDirection: Int] //word direction dictionary
    var answerHint: [CrosswordsGenerator.WordDirection: String] //word direction dictionary
    var charDirection: CharDirection
    var revealed: Bool
}

struct CrosswordView: View {
    @Environment(\.presentationMode) var presentationMode

    let gridSize: Int
    
    @Binding var wordDictionary: [String: String]
    @Binding var wordArray: [WordArray]
    @Binding var blockTextStruct: [[BlockState]]
    @Binding var isShowTimer: Bool
    @Binding var isShowError: Bool
    
    
    
    @State var selectedRow = 0
    @State var selectedCol = 0
    @State private var direction: CrosswordsGenerator.WordDirection = .horizontal
    @State private var newHorizontalTip: Int = 0
    {
        didSet{
            //   print(" newHorizontal tip is \(newHorizontalTip)")
        }
    }
    @State private var newVerticalTip: Int = 0
    {
        didSet{
            //    print(" newVertical tip is \(newVerticalTip)")
        }
    }
    @State private var isShowingPopup = false
    {
        didSet{
            //     print(" isShowingPopup is \(isShowingPopup)")
        }
    }
    
    var selectedBinding: Binding<String> {
        Binding<String>(
            get: {
                blockTextStruct[selectedRow][selectedCol].inputContent
            },
            set: {
                blockTextStruct[selectedRow][selectedCol].inputContent = $0
            }
        )
    }
    
    @State private var seconds: Int = 0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    
    @State private var isShowGameOverAlert = false
    
    var body: some View {
        
        ZStack {
            CrosswordKeyboard(text: selectedBinding)
            
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "timer")
                            .font(.system(size: 20))
                            .padding(.leading)
                        
                        Text(isShowTimer ? (formatter.string(from: TimeInterval(seconds)) ?? "00:00:00") : "Timer is Off")
                            .font(.system(size: 15, weight: .bold))
                            .onReceive(timer) { _ in
                                seconds += 1
                            }
                        
                    }
                    .frame(maxWidth:.infinity, alignment:.leading)
                    .opacity(isShowTimer ? 1.0 : 0.2)
                    
                    
                    NavigationLink(destination: RootView().navigationBarBackButtonHidden(true),
                                   label: {
                        Image(systemName: "restart.circle")
                            .font(.system(size: 20))
                            .padding(0)
                        
                    })
                    
                    Button(action: {
                        clearErrorBlock()
                    }) {
                        VStack {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 20))
                                .padding(0)
                        }
                    }
                    
                    Button(action: {
                        self.isShowingPopup.toggle()
                    }) {
                        VStack {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 20))
                                .padding(.trailing)
                        }
                    }
                }
                .frame(maxWidth: .infinity,alignment: .trailing)
                
                VStack(spacing: 0) {
                    ForEach(Array(blockTextStruct.enumerated()), id: \.offset) { (rowIndex, row) in
                        HStack(spacing:0) {
                            ForEach(Array(row.enumerated()), id: \.offset) { (columnIndex, value) in
                                if value.answerContent == "-" {
                                    createBlackBlock(rowIndex, columnIndex)
                                } else {
                                    createBlock(rowIndex, columnIndex, tip: -1)
                                }
                            }
                        }
                        
                    }
                }
                .onChange(of: blockTextStruct) { newValue in
                    checkGameStatus()
                    for (row, rowBlock) in blockTextStruct.enumerated() {
                        for (col, _) in rowBlock.enumerated() {
                            if blockTextStruct[row][col].revealed == true {
                                blockTextStruct[row][col].bgColor = .yellow
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .alert(isPresented: $isShowGameOverAlert) {
                    Alert(
                        title: Text("Game Over"),
                        // message: Text(isShowGameOverAlert),
                        dismissButton: .default(Text("Reset"), action: {
                            isShowGameOverAlert = false
                            presentationMode.wrappedValue.dismiss()
                        })
                    )
                }
                
            }
        }
        .onAppear {
            //set up direction based on the first word direction
            direction = wordArray[0].content.direction
            
            //update block status - bgcolor and highlight
            for (row, rowBlock) in blockTextStruct.enumerated() {
                for (col, _) in rowBlock.enumerated() {
                    
                    if blockTextStruct[row][col].tip[direction] == 1 {
                        selectedRow = row
                        selectedCol = col
                        blockTextStruct[row][col].isSelected = true
                    }
                    
                    if blockTextStruct[row][col].answerHint[direction] == "1" {
                        blockTextStruct[row][col].bgColor = .cyan
                    }
                }
            }
        }
        
        HStack {
            Button(action: {
                print("Button Prevs Tapped")
                newHorizontalTip = Int(blockTextStruct[selectedRow][selectedCol].answerHint[.horizontal]!) ?? 0
                newVerticalTip = Int(blockTextStruct[selectedRow][selectedCol].answerHint[.vertical]!) ?? 0
                
                var newTipCoordinateX: Int = 0
                var newTipCoordinateY: Int = 0
                
                if newHorizontalTip == 0 && newVerticalTip == 0 {
                    print("Error, Block horizontalTip is \(newHorizontalTip) verticalTip is \(newVerticalTip)")
                    return
                } else if newHorizontalTip > wordArray.count || newVerticalTip > wordArray.count {
                    print("Error, Tip out of wordArray range: horizontal is \(newHorizontalTip), vertical is \(newVerticalTip)")
                    return
                } else {
                    var newTip: Int = 0
                    if newHorizontalTip < newVerticalTip && newHorizontalTip != 0 {
                        newTip = newHorizontalTip
                    }
                    
                    if newHorizontalTip < newVerticalTip && newHorizontalTip == 0 {
                        newTip = newVerticalTip
                    }
                    
                    if newVerticalTip < newHorizontalTip && newVerticalTip != 0 {
                        newTip = newVerticalTip
                    }
                    
                    if newVerticalTip < newHorizontalTip && newVerticalTip == 0 {
                        newTip = newHorizontalTip
                    }
                    
                    newTip -= 1
                    
                    if blockTextStruct[selectedRow][selectedCol].charDirection == .both {
                        if direction == .horizontal {
                            newTip = newHorizontalTip
                        } else {
                            newTip = newVerticalTip
                        }
                        newTip -= 1
                    }
                    
                    if newTip == 0 {
                        print("has reach to the begining of the wordArray")
                        return
                    } else {
                        while direction != wordArray[newTip - 1].content.direction && newTip > 0 {
                            newTip -= 1
                            
                            //get current direction first index
                            var firstIndex: Int = 0
                            if let index = wordArray.firstIndex(where: { $0.content.direction == direction }) {
                                firstIndex = index
                                print("firstIndex in \(direction) is \(firstIndex)")
                            }
                            
                            
                            if  newTip == 1 && wordArray[0].content.direction != direction || newTip < wordArray[firstIndex].tip {
                                print("has reach the end of current direction word list")
                                return
                            }
                        }
                    }
                    //var wordIndex: Int = newTip
                    
                    // get before update the newTip , it will be the index of next newTip
                    newTipCoordinateX = wordArray[newTip - 1].content.row
                    newTipCoordinateY = wordArray[newTip - 1].content.column
                    
                    print("word index is \(newTip - 1), and previous \(wordArray[newTip - 1].tip)[\(newTipCoordinateX)][\(newTipCoordinateY)] is found")
                    
                    
                    for (row, rowBlock) in blockTextStruct.enumerated() {
                        for (col, _) in rowBlock.enumerated() {
                            
                            blockTextStruct[row][col].isSelected = false
                            blockTextStruct[row][col].bgColor = .white
                            
                            if direction == .horizontal {
                                if blockTextStruct[row][col].answerHint[.horizontal] == String(wordArray[newTip - 1].tip) {
                                    
                                    blockTextStruct[row][col].bgColor = .cyan
                                }
                            } else {
                                if blockTextStruct[row][col].answerHint[.vertical] == String(wordArray[newTip - 1].tip) {
                                    blockTextStruct[row][col].bgColor = .cyan
                                }
                            }
                            
                            if row == (newTipCoordinateX - 1) && col == (newTipCoordinateY - 1) {
                                blockTextStruct[row][col].isSelected = true
                            }
                            
                            
                        }
                    }
                    
                    selectedRow = newTipCoordinateX - 1
                    selectedCol = newTipCoordinateY - 1
                    
                    //update Tip
                    newHorizontalTip =     Int(blockTextStruct[selectedRow][selectedCol].answerHint[.horizontal]!) ?? 0
                    newVerticalTip = Int(blockTextStruct[selectedRow][selectedCol].answerHint[.vertical]!) ?? 0
                    
                }
            }) {
                VStack {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.system(size: 32))
                        .padding(.leading)
                }
            }
            
            if isShowingPopup {
                ZStack {
                    Color.yellow
                        .onTapGesture {
                            self.isShowingPopup = false
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .cornerRadius(10)
                    
                    //  VStack {
                    HStack {
                        Button(action: {
                            revealOneBlock()
                        }) {
                            Text("Reveal One")
                                .foregroundColor(Color.white)
                                .font(.system(size: 15, weight:.heavy))
                                .frame(width: 100,height: 32)
                                .background(Color.black)
                            //  .border(Color.black,width:1)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding()
                        }
                        .padding(5)
                        
                        Button(action: {
                            revealEntryBlocks()
                        }) {
                            Text("Reveal Entry")
                                .foregroundColor(Color.white)
                                .font(.system(size: 15, weight:.heavy))
                                .frame(width: 100,height: 32)
                                .background(Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding()
                        }
                        .padding(5)
                        Button(action: {
                            revealAllBlocks()
                        }) {
                            Text("Reveal All")
                                .foregroundColor(Color.white)
                                .font(.system(size: 15, weight:.heavy))
                                .frame(width: 100,height: 32)
                                .background(Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding()
                        }
                        .padding(5)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                
                Button(action: {
                    //direction button toggle
                    direction = direction == .horizontal ? .vertical : .horizontal
                    
                    for (row, rowBlock) in blockTextStruct.enumerated() {
                        for (col, _) in rowBlock.enumerated() {
                            blockTextStruct[row][col].bgColor = .white
                        }
                    }
                    
                    // find current seletected Block tip
                    guard blockTextStruct[selectedRow][selectedCol].answerHint[.horizontal] != nil else { return }
                    let horizontalTip = blockTextStruct[selectedRow][selectedCol].answerHint[.horizontal]
                    
                    guard blockTextStruct[selectedRow][selectedCol].answerHint[.vertical] != nil else { return }
                    let verticalTip = blockTextStruct[selectedRow][selectedCol].answerHint[.vertical]
                    
                    print("current block answerHint is horizontalTip: \(String(describing: horizontalTip)), verticalTip: \(String(describing: verticalTip))")
                    
                    // block with singal direction
                    if blockTextStruct[selectedRow][selectedCol].charDirection != .both {
                        
                        //update blocks status by selected direction
                        if direction == .horizontal && horizontalTip != " " {
                            for (col, _) in blockTextStruct[selectedRow].enumerated() {
                                if  blockTextStruct[selectedRow][col].answerHint[.horizontal] == horizontalTip {
                                    blockTextStruct[selectedRow][col].bgColor = .cyan
                                }
                            }
                        }
                        
                        if direction == .vertical && verticalTip != " " {
                            for (row, _) in blockTextStruct.enumerated() {
                                if blockTextStruct[row][selectedCol].answerHint[.vertical] == verticalTip {
                                    blockTextStruct[row][selectedCol].bgColor = .cyan
                                }
                            }
                        }
                        
                    }
                    
                    //block with both direction
                    if blockTextStruct[selectedRow][selectedCol].charDirection == .both {
                        //update blocks status by selected direction
                        if direction == .horizontal {
                            for (col, _) in blockTextStruct[selectedRow].enumerated() {
                                if  blockTextStruct[selectedRow][col].answerHint[.horizontal] == horizontalTip {
                                    blockTextStruct[selectedRow][col].bgColor = .cyan
                                }
                            }
                        }
                        
                        if direction == .vertical {
                            for (row, _) in blockTextStruct.enumerated() {
                                if blockTextStruct[row][selectedCol].answerHint[.vertical] == verticalTip {
                                    blockTextStruct[row][selectedCol].bgColor = .cyan
                                }
                            }
                        }
                    }
                }) {
                    Text(direction == .horizontal ? "Horizontal -  \(getHint(blockTextStruct[selectedRow][selectedCol].answerHint[.horizontal]!))"
                         :
                        "Vertical - \(getHint(blockTextStruct[selectedRow][selectedCol].answerHint[.vertical]!))"
                    )
                    .foregroundColor(.black)
                    .lineLimit(3)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.mint)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .onAppear {
                    direction = wordArray[0].content.direction == .horizontal ? .horizontal : .vertical
                }
            }
            
            VStack(spacing: 32) {
                Button(action: {
                    print("Button Next Tapped")
                    newHorizontalTip = Int(blockTextStruct[selectedRow][selectedCol].answerHint[.horizontal]!) ?? 0
                    newVerticalTip = Int(blockTextStruct[selectedRow][selectedCol].answerHint[.vertical]!) ?? 0
                    
                    var newTipCoordinateX: Int = 0
                    var newTipCoordinateY: Int = 0
                    
                    if newHorizontalTip == 0 && newVerticalTip == 0 {
                        print("Error, Block horizontalTip is \(newHorizontalTip) verticalTip is \(newVerticalTip)")
                        return
                    } else if newHorizontalTip > wordArray.count || newVerticalTip > wordArray.count {
                        print("Error, Tip out of wordArray range: horizontal is \(newHorizontalTip), vertical is \(newVerticalTip)")
                        return
                    } else {
                        var newTip: Int = 0
                        if newHorizontalTip < newVerticalTip && newHorizontalTip != 0 {
                            newTip = newHorizontalTip
                        }
                        
                        if newHorizontalTip < newVerticalTip && newHorizontalTip == 0 {
                            newTip = newVerticalTip
                        }
                        
                        if newVerticalTip < newHorizontalTip && newVerticalTip != 0 {
                            newTip = newVerticalTip
                        }
                        
                        if newVerticalTip < newHorizontalTip && newVerticalTip == 0 {
                            newTip = newHorizontalTip
                        }
                        
                        if blockTextStruct[selectedRow][selectedCol].charDirection == .both {
                            if direction == .vertical {
                                newTip = newVerticalTip
                            } else {
                                newTip = newHorizontalTip
                            }
                        }
                        
                        if newTip > wordArray.count - 1 {
                            print("has reach to the end of the wordArray")
                            return
                        } else {
                            while direction != wordArray[newTip].content.direction && newTip < (wordArray.count - 1) {
                                newTip += 1
                                
                                //get current direction last index
                                var lastIndex: Int = 0
                                
                                if let index = wordArray.lastIndex(where: { $0.content.direction == direction }) {
                                    lastIndex = index
                                    print("LastIndex in \(direction) is \(lastIndex)")
                                }
                                
                                if  newTip == wordArray.count - 1 && wordArray[newTip].content.direction != direction || newTip > wordArray[lastIndex].tip {
                                    print("has reach the end of current direction word list")
                                    return
                                }
                            }
                        }
                        
                        // get before update the newTip , it will be the index of next newTip
                        newTipCoordinateX = wordArray[newTip].content.row
                        newTipCoordinateY = wordArray[newTip].content.column
                        
                        print("word index is \(newTip), and next \(wordArray[newTip].tip)[\(newTipCoordinateX)][\(newTipCoordinateY)] is found")
                        
                        
                        for (row, rowBlock) in blockTextStruct.enumerated() {
                            for (col, _) in rowBlock.enumerated() {
                                
                                blockTextStruct[row][col].isSelected = false
                                blockTextStruct[row][col].bgColor = .white
                                
                                if direction == .horizontal {
                                    if blockTextStruct[row][col].answerHint[.horizontal] == String(wordArray[newTip].tip) {
                                        
                                        blockTextStruct[row][col].bgColor = .cyan
                                    }
                                } else {
                                    if blockTextStruct[row][col].answerHint[.vertical] == String(wordArray[newTip].tip) {
                                        blockTextStruct[row][col].bgColor = .cyan
                                    }
                                }
                                
                                if row == (newTipCoordinateX - 1) && col == (newTipCoordinateY - 1) {
                                    blockTextStruct[row][col].isSelected = true
                                }
                                
                                
                            }
                        }
                        
                        selectedRow = newTipCoordinateX - 1
                        selectedCol = newTipCoordinateY - 1
                        
                        //update Tip
                        newHorizontalTip =     Int(blockTextStruct[selectedRow][selectedCol].answerHint[.horizontal]!) ?? 0
                        newVerticalTip = Int(blockTextStruct[selectedRow][selectedCol].answerHint[.vertical]!) ?? 0
                        
                    }
                    
                }) {
                    VStack {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 32))
                            .padding(.trailing)
                    }
                }
            }
        }
        Spacer()
    }
    
    func createBlock(_ row: Int,_ col: Int, tip: Int = -1) -> CrosswordBlockView {
        
        return CrosswordBlockView(
            row: row,
            col: col,
            selectedRow: $selectedRow,
            selectedCol: $selectedCol,
            blockState: $blockTextStruct,
            direction: $direction,
            newHorizontalTip: $newHorizontalTip,
            newVerticalTip: $newVerticalTip,
            wordArray: $wordArray, isShowError: $isShowError,
            gridSize: gridSize
        )
    }
    
    func createBlackBlock(_ row: Int, _ col: Int) -> CrosswordBlackBlockView {
        // CrosswordBlackBlock(row: row, col: col, value: value)  // debug for create black block from wordlist
        CrosswordBlackBlockView(row: row, col: col, gridSize: gridSize)
    }
    
    func setTip(_ rowIndex: Int,_ colIndex: Int, _ wordArray: Array<CrosswordsGenerator.Word>, _ tip: Int = -1) -> Int {
        
        for (index, word) in wordArray.enumerated() {
            if rowIndex == ( word.row - 1 ) && colIndex == ( word.column - 1 ) {
                //    print("\(word) is at index \(index)")  //debug tip value
                return index + 1
            }
        }
        return -1
    }
    
    func checkGameStatus() {
        for (row, rowBlock) in blockTextStruct.enumerated() {
            for (col, _) in rowBlock.enumerated() {
                if blockTextStruct[row][col].inputContent == "" {
                    return isShowGameOverAlert = false
                }
            }
        }
        isShowGameOverAlert = true
    }
    
    func clearErrorBlock() {
        for (row, rowBlock) in blockTextStruct.enumerated() {
            for (col, _) in rowBlock.enumerated() {
                if blockTextStruct[row][col].inputContent != "" && blockTextStruct[row][col].inputContent != blockTextStruct[row][col].answerContent.uppercased() {
                //if blockTextStruct[row][col].textColor == .red {
                    blockTextStruct[row][col].inputContent = ""
                }
            }
        }
    }
    
    func getHint(_ tip: String) -> String {
     //   print("getHint func called: tip is \(tip)")
        for (_, element)  in wordArray.enumerated() {
            if String(element.tip) == tip {
                let word = element.content.word
              //  print("word is \(word)")
                if let hint = wordDictionary[word] {
                    return hint
                }
            }
        }
        return "No Hint in Current Direction"
    }
    
    func revealOneBlock() {
        if blockTextStruct[selectedRow][selectedCol].inputContent != blockTextStruct[selectedRow][selectedCol].answerContent.uppercased() {
            blockTextStruct[selectedRow][selectedCol].inputContent
            = blockTextStruct[selectedRow][selectedCol].answerContent.uppercased()
            blockTextStruct[selectedRow][selectedCol].bgColor = .yellow
            blockTextStruct[selectedRow][selectedCol].revealed = true
        }
    }
    
    func revealEntryBlocks() {
        for (row, rowBlock) in blockTextStruct.enumerated() {
            for (col, _) in rowBlock.enumerated() {
                if direction == .horizontal {
                    let currentTip =  blockTextStruct[selectedRow][selectedCol].answerHint[.horizontal]
                    if blockTextStruct[row][col].answerHint[.horizontal] == currentTip {
                        
                        if blockTextStruct[row][col].inputContent != blockTextStruct[row][col].answerContent.uppercased() {
                            blockTextStruct[row][col].inputContent = blockTextStruct[row][col].answerContent.uppercased()
                            
                            blockTextStruct[row][col].bgColor = .yellow
                            blockTextStruct[selectedRow][selectedCol].revealed = true
                        }
                    }
                } else {
                    let currentTip =  blockTextStruct[selectedRow][selectedCol].answerHint[.vertical]
                    if blockTextStruct[row][col].answerHint[.vertical] == currentTip {
                        if blockTextStruct[row][col].inputContent != blockTextStruct[row][col].answerContent {
                            blockTextStruct[row][col].inputContent = blockTextStruct[row][col].answerContent.uppercased()
                            
                            blockTextStruct[row][col].bgColor = .yellow
                            blockTextStruct[selectedRow][selectedCol].revealed = true
                        }
                    }
                }
            }
        }
    }
    
    func revealAllBlocks() {
        for (row, rowBlock) in blockTextStruct.enumerated() {
            for (col, _) in rowBlock.enumerated() {
                if blockTextStruct[row][col].inputContent != blockTextStruct[row][col].answerContent.uppercased() {
                    if blockTextStruct[row][col].inputContent == "" {
                        blockTextStruct[row][col].inputContent = blockTextStruct[row][col].answerContent.uppercased()
                        blockTextStruct[row][col].bgColor = .yellow
                        blockTextStruct[selectedRow][selectedCol].revealed = true
                    }
                }
            }
        }
    }
}

struct CrosswordView_Previews: PreviewProvider {
    static var previews: some View {
        let block: [[BlockState]] = [[
            .init(answerContent: "c", inputContent: "A", textColor: .black, isSelected: true, bgColor: .white, rowIndex: 0, colIndex: 0, tip: [.horizontal: -1 , .vertical: 1], answerHint: [.horizontal:"", .vertical: "1"], charDirection: .horizontal, revealed: false)
        ]]
        
        CrosswordView(gridSize: 15,
                      wordDictionary: .constant([:]),
                      wordArray: .constant([WordArray(content: CrosswordsGenerator.Word(word: "pumpernickel", column: 2, row: 2, direction: CrosswordsGenerator.WordDirection.vertical), tip: 1), WordArray(content: CrosswordsGenerator.Word(word: "piston", column: 2, row: 2, direction: CrosswordsGenerator.WordDirection.horizontal), tip: 2), WordArray(content: CrosswordsGenerator.Word(word: "lip", column: 7, row: 4, direction: CrosswordsGenerator.WordDirection.vertical), tip: 3), WordArray(content: CrosswordsGenerator.Word(word: "paladin", column: 2, row: 5, direction: CrosswordsGenerator.WordDirection.horizontal), tip: 4), WordArray(content: CrosswordsGenerator.Word(word: "snicker", column: 1, row: 8, direction: CrosswordsGenerator.WordDirection.horizontal), tip: 5), WordArray(content: CrosswordsGenerator.Word(word: "caramel", column: 2, row: 10, direction: CrosswordsGenerator.WordDirection.horizontal), tip: 6), WordArray(content: CrosswordsGenerator.Word(word: "albatross", column: 1, row: 13, direction: CrosswordsGenerator.WordDirection.horizontal), tip: 7)]), blockTextStruct: .constant(block),
                      isShowTimer: .constant(true),
                      isShowError: .constant(true)
        )
    }
}
