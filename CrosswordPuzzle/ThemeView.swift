//
//  ThemeView.swift
//  TestFocus
//
//  Created by csuftitan on 5/18/23.
//

import SwiftUI

struct ThemeView: View {
    @Binding var words: [String]
    @Binding var wordsDictionary: [String : String]
    @Binding var isThemeSelected: Bool
    @Binding var selectedTheme: String
    
    let themes = [["Theme 1", "Theme 2"], ["Theme 3", "Theme 4"]]
    
    let imageName = ["square.grid.3x3.topleft.filled",
                     "square.grid.3x3.topmiddle.filled",
                     "square.grid.3x3.topright.filled",
                     "square.grid.3x3.middleleft.filled",
                     "square.grid.3x3.middle.filled",
                     "square.grid.3x3.middleright.filled",
                     "square.grid.3x3.bottomright.filled",
                     "square.grid.3x3.bottomleft.filled",
                     "square.grid.3x3.bottommiddle.filled"
    ].shuffled()
    
    let theme1words = ["saffron", "pumpernickel", "leaven", "coda", "paladin", "syncopation", "albatross", "harp", "piston", "caramel", "coral", "dawn", "pitch", "fjord", "lip", "lime", "mist", "plague", "yarn", "snicker"]
    
    let theme1wordsDictionary = [
        "saffron" : "Yellow shade; Expensive spice",
        "pumpernickel" : "Type of bread; Alternative to white; Good bread for a sandwich",
        "leaven" : "Raising agent; Ferment; Infuse",
        "coda" : "Musical finale",
        "paladin" : "Old TV's \"knight without armor in a savage land; Legendary attendant of Charlemagne",
        "syncopation" : " Offbeat musical rhythm",
        "albatross" : "Burden to bear; Largest-wingspan bird",
        "harp" : "Orchestra instrument; Stringed instrument",
        "piston" : "Kind of ring; Car engine part; Detroit athlete",
        "caramel" : "Chewy sweet; Sundae topping; Kind of apple",
        "coral" : "Shade of red; Reef material;Jewelry material;Atoll component",
        "dawn" : "Daybreak; Arise; Haggard novel; First light",
        "pitch" : "Throw, as a baseball; Take the mound; Singer's concern",
        "fjord" : "Long, narrow inlet; Sea arm; Scandinavian inlet",
        "lip" : "Spout; Impudent talk; Impertinence",
        "lime": "Tropical fruit; Green shade",
        "mist": "Rainbow maker; Fog; Moisture",
        "plague": "Epidemic; Blight; One of 10 in Exodus",
        "yarn": "Sweater material; Fish story; Fabrication",
        "snicker" : "Smothered laugh"
    ]
    
    var body: some View {
        Section {
            VStack {
                ForEach(themes, id: \.self) { row in
                    HStack() {
                        ForEach(row, id: \.self) { theme in
                            Button(action: {
                                isThemeSelected = true
                                selectedTheme = theme
                                switch theme {
                                case "Theme 1":
                                    words = theme1words
                                    wordsDictionary = theme1wordsDictionary
                                case "Theme 2":
                                    words = theme1words
                                    wordsDictionary = theme1wordsDictionary
                                case "Theme 3":
                                    words = theme1words
                                    wordsDictionary = theme1wordsDictionary
                                case "Theme 4":
                                    words = theme1words
                                    wordsDictionary = theme1wordsDictionary
                                default:
                                    words = theme1words
                                    wordsDictionary = theme1wordsDictionary
                                }
                                //   isButtonAnimating.toggle()
                            }) {
                                VStack {
                                    Image(systemName: imageName.randomElement() ?? "square.grid.3x3.topleft.filled")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100,height: 100)
                                    // .background(.red)
                                        .padding()
                                    
                                    Text("\(theme)")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.vertical)
                                        .frame(maxWidth: .infinity)
                                        .background(selectedTheme == theme ? .yellow : .lightBackground)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                //  .background(.red)
                                .overlay(RoundedRectangle(cornerRadius: 10) .stroke(selectedTheme == theme ? .yellow : .lightBackground))
                            }
                            
                        }
                    }
                }
            }
        }
    }
}

//struct ThemeView_Previews: PreviewProvider {
//    static var previews: some View {
//        ThemeView()
//    }
//}
