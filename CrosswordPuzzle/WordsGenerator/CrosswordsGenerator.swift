//
//  CrosswordsGenerator.swift
//  TestFocus
//
//  Created by Caroline Ha on 4/5/23.
//

import UIKit

open class CrosswordsGenerator {

    // MARK: - Additional types
    
    public struct Word {
        public var word = ""
        public var column = 0
        public var row = 0
        public var direction: WordDirection = .vertical
    }
    
    public enum WordDirection {
        case vertical
        case horizontal
    }
    
    // MARK: - Public properties
    
    open var columns: Int = 0
    open var rows: Int = 0
    open var maxLoops: Int = 4000
    open var words: Array<String> = Array()
    
    open var result: Array<Word> {
        get {
            let sortedresult = resultData.sorted { (resultData1, resultData2) -> Bool in
                if resultData1.row == resultData2.row {
                    return resultData1.column < resultData2.column
                } else {
                    return resultData1.row < resultData2.row
                }
            }
//        print("result array: \(resultData.self)")
//         print("sorted array: \(sortedresult)")
            return sortedresult
//         return resultData
        }
    }
    
    // MARK: - Public additional properties
    
    open var fillAllWords = false
    open var emptySymbol = "-"
    open var debug = true
    open var orientationOptimization = false
    
    // MARK: - Logic properties
    
    fileprivate var grid: Array2D<String>?
    fileprivate var currentWords: Array<String> = Array()
    fileprivate var resultData: Array<Word> = Array()
    
    // MARK: - Initialization
    
    public init() {
    }
    
    public init(columns: Int, rows: Int, maxLoops: Int = 4000, words: Array<String>) {
        self.columns = columns
        self.rows = rows
        self.maxLoops = maxLoops
        self.words = words
    }
    
    // MARK: - Crosswords generation
    
    internal func generate() -> [[BlockState]] {
        
        self.grid = nil
        self.grid = Array2D(columns: columns, rows: rows, defaultValue: emptySymbol)
        
        currentWords.removeAll()
        resultData.removeAll()
        
        words.sort(by: {$0.lengthOfBytes(using: String.Encoding.utf8) > $1.lengthOfBytes(using: String.Encoding.utf8)})
        
//        if debug {
//            print("--- Words ---")
//            print(words)
//        }
        
        for word in words {
            if !currentWords.contains(word) {
                _ = fitAndAdd(word)
            }
        }
        
        var crossWordInput: [[BlockState]] = []
//        if debug {
//            print("--- Result ---")
//            crossWordInput = printGrid()
//        }
        
        if fillAllWords {
            
            var remainingWords = Array<String>()
            for word in words {
                if !currentWords.contains(word) {
                    remainingWords.append(word)
                }
            }
            
            var moreLikely = Set<String>()
            var lessLikely = Set<String>()
            for word in remainingWords {
                var hasSameLetters = false
                for comparingWord in remainingWords {
                    if word != comparingWord {
                        let letters = CharacterSet(charactersIn: comparingWord)
                        let range = word.rangeOfCharacter(from: letters)
                        
                        if let _ = range {
                            hasSameLetters = true
                            break
                        }
                    }
                }
                
                if hasSameLetters {
                    moreLikely.insert(word)
                }
                else {
                    lessLikely.insert(word)
                }
            }
            
            remainingWords.removeAll()
            remainingWords.append(contentsOf: moreLikely)
            remainingWords.append(contentsOf: lessLikely)
            
            for word in remainingWords {
                if !fitAndAdd(word) {
                    fitInRandomPlace(word)
                }
            }
            
            if debug {
                print("--- Fill All Words ---")
                printGrid()
            }

        }
        return crossWordInput
    }
    
    fileprivate func suggestCoord(_ word: String) -> Array<(Int, Int, Int, Int, Int)> {
        
        var coordlist = Array<(Int, Int, Int, Int, Int)>()
        var glc = -1
        
        for letter in word {
            glc += 1
            var rowc = 0
            for row: Int in 0 ..< rows {
                rowc += 1
                var colc = 0
                for column: Int in 0 ..< columns {
                    colc += 1
                    
                    let cell = grid![column, row]
                    if String(letter) == cell {
                        if rowc - glc > 0 {
                            if ((rowc - glc) + word.lengthOfBytes(using: String.Encoding.utf8)) <= rows {
                                coordlist.append((colc, rowc - glc, 1, colc + (rowc - glc), 0))
                            }
                        }
                        
                        if colc - glc > 0 {
                            if ((colc - glc) + word.lengthOfBytes(using: String.Encoding.utf8)) <= columns {
                                coordlist.append((colc - glc, rowc, 0, rowc + (colc - glc), 0))
                            }
                        }
                    }
                }
            }
        }
        
        let newCoordlist = sortCoordlist(coordlist, word: word)
        return newCoordlist
    }
    
    fileprivate func sortCoordlist(_ coordlist: Array<(Int, Int, Int, Int, Int)>, word: String) -> Array<(Int, Int, Int, Int, Int)> {
        
        var newCoordlist = Array<(Int, Int, Int, Int, Int)>()
        
        for var coord in coordlist {
            let column = coord.0
            let row = coord.1
            let direction = coord.2
            coord.4 = checkFitScore(column, row: row, direction: direction, word: word)
            if coord.4 > 0 {
                newCoordlist.append(coord)
            }
        }
        
        newCoordlist.shuffle()
        newCoordlist.sort(by: {$0.4 > $1.4})
        
        return newCoordlist
    }
    
    fileprivate func fitAndAdd(_ word: String) -> Bool {
        
        var fit = false
        var count = 0
        let coordlist = suggestCoord(word)
        
        while !fit && count < maxLoops {
            
            if currentWords.count == 0 {
                let direction = randomValue()
                
                // +1 offset for the first word, so more likely intersections for short words
                let column = 1 + 1
                let row = 1 + 1

                if checkFitScore(column, row: row, direction: direction, word: word) > 0 {
                    fit = true
                    setWord(column, row: row, direction: direction, word: word, force: true)
                }
            }
            else {
                if count >= 0 && count < coordlist.count {
                    let column = coordlist[count].0
                    let row = coordlist[count].1
                    let direction = coordlist[count].2

                    if coordlist[count].4 > 0 {
                        fit = true
                        setWord(column, row: row, direction: direction, word: word, force: true)
                    }
                }
                else {
                    return false
                }
            }
            
            count += 1
        }
        
        return true
    }
    
    fileprivate func fitInRandomPlace(_ word: String) {
        
        let value = randomValue()
        let directions = [value, value == 0 ? 1 : 0]
        var bestScore = 0
        var bestColumn = 0
        var bestRow = 0
        var bestDirection = 0
        
        for direction in directions {
            for i: Int in 1 ..< rows - 1 {
                for j: Int in 1 ..< columns - 1 {
                    if grid![j, i] == emptySymbol {
                        let c = j + 1
                        let r = i + 1
                        let score = checkFitScore(c, row: r, direction: direction, word: word)
                        if score > bestScore {
                            bestScore = score
                            bestColumn = c
                            bestRow = r
                            bestDirection = direction
                        }
                    }
                }
            }
        }
        
        if bestScore > 0 {
            setWord(bestColumn, row: bestRow, direction: bestDirection, word: word, force: true)
        }
    }
    
    fileprivate func checkFitScore(_ column: Int, row: Int, direction: Int, word: String) -> Int {
        
        var c = column
        var r = row
        
        if c < 1 || r < 1 || c >= columns || r >= rows {
            return 0
        }
        
        var count = 1
        var score = 1
        
        for letter in word {
            let activeCell = getCell(c, row: r)
            if activeCell == emptySymbol || activeCell == String(letter) {
                
                if activeCell == String(letter) {
                    score += 1
                }
                
                if direction == 0 {
                    if activeCell != String(letter) {
                        if !checkIfCellClear(c, row: r - 1) {
                            return 0
                        }
                        
                        if !checkIfCellClear(c, row: r + 1) {
                            return 0
                        }
                    }
                    
                    if count == 1 {
                        if !checkIfCellClear(c - 1, row: r) {
                            return 0
                        }
                    }
                    
                    if count == word.lengthOfBytes(using: String.Encoding.utf8) {
                        if !checkIfCellClear(c + 1, row: row) {
                            return 0
                        }
                    }
                }
                else {
                    if activeCell != String(letter) {
                        if !checkIfCellClear(c + 1, row: r) {
                            return 0
                        }
                        
                        if !checkIfCellClear(c - 1, row: r) {
                            return 0
                        }
                    }
                    
                    if count == 1 {
                        if !checkIfCellClear(c, row: r - 1) {
                            return 0
                        }
                    }
                    
                    if count == word.lengthOfBytes(using: String.Encoding.utf8) {
                        if !checkIfCellClear(c, row: r + 1) {
                            return 0
                        }
                    }
                }
                
                if direction == 0 {
                    c += 1
                }
                else {
                    r += 1
                }

                if (c >= columns || r >= rows) {
                    return 0
                }
                
                count += 1
            }
            else {
                return 0
            }
        }
        
        return score
    }
    
    func setCell(_ column: Int, row: Int, value: String) {
        grid![column - 1, row - 1] = value
    }
 
    func getCell(_ column: Int, row: Int) -> String{
        return grid![column - 1, row - 1]
    }
    
    func checkIfCellClear(_ column: Int, row: Int) -> Bool {
        if column > 0 && row > 0 && column < columns && row < rows {
            return getCell(column, row: row) == emptySymbol ? true : false
        }
        else {
            return true
        }
    }
    
    fileprivate func setWord(_ column: Int, row: Int, direction: Int, word: String, force: Bool = false) {
        
        if force {
            let w = Word(word: word, column: column, row: row, direction: (direction == 0 ? .horizontal : .vertical))
            resultData.append(w)
            
            currentWords.append(word)
            
            var c = column
            var r = row
            
            for letter in word {
                setCell(c, row: r, value: String(letter))
                if direction == 0 {
                    c += 1
                }
                else {
                    r += 1
                }
            }
        }
    }
    
    // MARK: - Public info methods
    
    open func maxColumn() -> Int {
        var column = 0
        for i in 0 ..< rows {
            for j in 0 ..< columns {
                if grid![j, i] != emptySymbol {
                    if j > column {
                        column = j
                    }
                }
            }
        }
        return column + 1
    }
    
    open func maxRow() -> Int {
        var row = 0
        for i in 0 ..< rows {
            for j in 0 ..< columns {
                if grid![j, i] != emptySymbol {
                    if i > row {
                        row = i
                    }
                }
            }
        }
        return row + 1
    }
    
    open func lettersCount() -> Int {
        var count = 0
        for i in 0 ..< rows {
            for j in 0 ..< columns {
                if grid![j, i] != emptySymbol {
                    count += 1
                }
            }
        }
        return count
    }
    
    // MARK: - Misc
    
    fileprivate func randomValue() -> Int {
        if orientationOptimization {
            return UIDevice.current.orientation.isLandscape ? 1 : 0
        }
        else {
            return randomInt(0, max: 1)
        }
    }
    
    fileprivate func randomInt(_ min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    // MARK: - Debug
    
    func printGrid() -> [[BlockState]] {
        
        var returnWord:[[BlockState]] = []
     //   var displayWordArray:[[String]] = [] //C.HA added
        for i in 0 ..< rows {
            var s = ""
            var temp:[String] = []
            for j in 0 ..< columns {
                s += grid![j, i]
                temp.append(grid![j,i]) //C.HA added
            }
             print(s)
        }
       
        let wordCoordinateArray:[[(Int,Int,Character,BlockState.CharDirection,WordDirection)]] = getWordBlocksCoordinate()
        
     //   print("wordCoordinateArray: \(wordCoordinateArray)")
        
        //init [[BlockState]] object
        for row in 0..<columns {
            var tempRow: [BlockState] = []
            for col in 0..<columns {
                tempRow.append(.init(answerContent: "-", inputContent: "", textColor: .black, isSelected: false, bgColor: .white, rowIndex: row, colIndex: col, tip: [.horizontal: -1, .vertical: -1], answerHint: [.horizontal:" ", .vertical: " "], charDirection: .horizontal, revealed: false))
            }
            returnWord.append(tempRow)
        }
        var tip = 0
        for wordRow in wordCoordinateArray {
            let tipCoordinateX = wordRow[0].0
            let tipCoordinateY = wordRow[0].1
            for tuple in wordRow {
                let coordinateX = tuple.0 - 1
                let coordinateY = tuple.1 - 1
                let answerContent = tuple.2
            
                returnWord[coordinateX][coordinateY].answerContent = "\(answerContent)"
       //         returnWord[coordinateX][coordinateY].charDirection = tuple.3
                
                if tuple.0 == tipCoordinateX && tuple.1 == tipCoordinateY {
                    tip += 1
                    if tuple.3 == .horizontal {
                        returnWord[coordinateX][coordinateY].tip[.horizontal] = tip //tip set up
                                       } else {
                        returnWord[coordinateX][coordinateY].tip[.vertical] = tip  //tip set up
                    }
                }
                
                if tuple.4 == .horizontal {
                    returnWord[tuple.0 - 1][tuple.1 - 1].answerHint[.horizontal] = (String(tip))//Hint set up
                } else {
                    returnWord[tuple.0 - 1][tuple.1 - 1].answerHint[.vertical] = (String(tip))//Hint set up
                }
            }
        }
        
        let duplicateBlocks:[(Int,Int,Character,BlockState.CharDirection,WordDirection)] = getCrossingCharactor(wordsBlocks: wordCoordinateArray)
      //  print("duplicateBlocks are \(duplicateBlocks)")
        
        //update crossing blocks char direction
        duplicateBlocks.forEach {
            returnWord[$0.0 - 1][$0.1 - 1].charDirection = .both
        }
        
//        returnWord.forEach {
//            print("generated state is \($0)")
//        }
        return returnWord //C.HA added
    }
    
    // MARK: - Get Coordinate of every Charactor in the WordList
    
    func getWordBlocksCoordinate() -> [[(Int,Int,Character,BlockState.CharDirection,WordDirection)]] {
            var tempWordsBlocks:[[(Int,Int,Character,BlockState.CharDirection,WordDirection)]] = []
                    
            for word in result {
                var selectedBlocks:[(Int,Int,
                                    Character,BlockState.CharDirection,WordDirection)] = []
                var selectedBlock:(Int,Int,Character,BlockState.CharDirection,WordDirection) = (0,0,Character("-"),.vertical,.vertical)
                
                if word.direction == .vertical {
                    selectedBlock.1 = word.column
                    
                    for (charIndex, char) in word.word.enumerated() {
                        selectedBlock.2 = char
                        selectedBlock.0 = word.row + charIndex
                     //   selectedBlock.4 = word.direction
                        selectedBlocks.append(selectedBlock)
                    }
                } else {
                    selectedBlock.0 = word.row
                    selectedBlock.3 = .horizontal
                     for (charIndex, char) in word.word.enumerated() {
                        selectedBlock.2 = char
                        selectedBlock.1 = word.column + charIndex
                        selectedBlock.4 = word.direction
                        selectedBlocks.append(selectedBlock)
                    }
                }
    
                tempWordsBlocks.append(selectedBlocks)
            }
  //          print("selectedWordsBlocks is \(tempWordsBlocks)")
        
            return tempWordsBlocks
        }
    
    // MARK: - Get Direction of crossing Charactor in the WordList
    
    func getCrossingCharactor(wordsBlocks: [[(Int,Int,Character,BlockState.CharDirection,WordDirection)]]) -> [(Int,Int,Character,BlockState.CharDirection,WordDirection)] {
        
        var duplicates: [(Int,Int,Character,BlockState.CharDirection,WordDirection)] = []
        
        var blockInfoSet: Set<BlockInfo> = []

        for rows in wordsBlocks {
            for block in rows {
                let tempBlockInfo: BlockInfo = .init(row: block.0, col: block.1)
        
                if blockInfoSet.contains(tempBlockInfo) {
                    duplicates.append(block)
                } else {
                    blockInfoSet.insert(tempBlockInfo)
                }
            }
        }
        return duplicates
    }
    
    public struct BlockInfo: Hashable {
        let row: Int
        let col: Int
    }
}
