//
//  RootView.swift
//  TestFocus
//
//  Created by Caroline Ha on 5/2/23.
//

import SwiftUI

struct RootView: View {

//    @State var words = ["saffron", "pumpernickel", "leaven", "coda", "paladin", "syncopation", "albatross", "harp", "piston", "caramel", "coral", "dawn", "pitch", "fjord", "lip", "lime", "mist", "plague", "yarn", "snicker"]
//    @State var wordsDictionary = [
//        "saffron" : "Yellow shade; Expensive spice",
//        "pumpernickel" : "Type of bread; Alternative to white; Good bread for a sandwich",
//        "leaven" : "Raising agent; Ferment; Infuse",
//        "coda" : "Musical finale",
//        "paladin" : "Old TV's \"knight without armor in a savage land; Legendary attendant of Charlemagne",
//        "syncopation" : " Offbeat musical rhythm",
//        "albatross" : "Burden to bear; Largest-wingspan bird",
//        "harp" : "Orchestra instrument; Stringed instrument",
//        "piston" : "Kind of ring; Car engine part; Detroit athlete",
//        "caramel" : "Chewy sweet; Sundae topping; Kind of apple",
//        "coral" : "Shade of red; Reef material;Jewelry material;Atoll component",
//        "dawn" : "Daybreak; Arise; Haggard novel; First light",
//        "pitch" : "Throw, as a baseball; Take the mound; Singer's concern",
//        "fjord" : "Long, narrow inlet; Sea arm; Scandinavian inlet",
//        "lip" : "Spout; Impudent talk; Impertinence",
//        "lime": "Tropical fruit; Green shade",
//        "mist": "Rainbow maker; Fog; Moisture",
//        "plague": "Epidemic; Blight; One of 10 in Exodus",
//        "yarn": "Sweater material; Fish story; Fabrication",
//        "snicker" : "Smothered laugh"
//    ]
    
    @State private var showInfo = false
    @State private var showThemeView = false
    @State private var showGridView = false
    @State private var isThemeSelected = false
    @State private var isGridSelected = false
    @State private var selectedSize = 0
    @State private var selectedTheme = ""
    @State private var words = [""]
    @State private var wordsDictionary = ["" : ""]
    
    @State private var isShowTimer = false
    @State private var isShowError = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                HStack {
                    Text("Select")
                    Text("Theme")
                        .foregroundColor(isThemeSelected ? .white : .yellow)
                    Text("and")
                    Text("Size")
                        .foregroundColor(isGridSelected ? .white : .yellow)
                }
                .font(.largeTitle)
                
                Divider()
                
                if showThemeView {
                    ThemeView(words: $words, wordsDictionary: $wordsDictionary, isThemeSelected: $isThemeSelected, selectedTheme: $selectedTheme)
                } else if showGridView {
                    GridView(isSizeSelected: $isGridSelected, selectedSize: $selectedSize)
                }
                Spacer()
            }
            .padding(.bottom, 20)
            .navigationTitle("Crossword Packs")
            .background(.darkBackground)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    //   ToolbarItem(placement: .bottomBar) {
                    HStack{
                        Button(action: {
                            self.showInfo = true
                        }) {
                            VStack {
                                Image(systemName: "info.bubble")
                                Text("Info")
                                    .font(.headline)
                                // .background(.lightBackground)
                            }
                        }
                        .alert(isPresented: $showInfo) {
                            Alert(title: Text("Game Info"), message: Text(
                                """
            Developer:     Caroline Ha
            Class:         CPSC411 - 02
            Instructor:    Professor McCarthy
            Commited Date: May 19th.2023
            """
                            ).font(.title), dismissButton: .default(Text("OK")))
                        }
                        
                        Menu {
                            Toggle(isShowTimer ? "Show Timer is ON" : "Show Timer is OFF", isOn: $isShowTimer)
                                .padding()
                            
                            Toggle(isShowError ? "Show Error is ON" : "Show Error is OFF", isOn: $isShowError)
                                .padding()
                            
                            
                        }label: {
                            Image(systemName: "gearshape.2.fill")
                            Text("Setting")
                                .font(.headline)
                        }
                        
                        Button(action: {
                            showThemeView = true
                            showGridView = false
                        }){
                            VStack {
                                Image(systemName: "flag.checkered.2.crossed")
                                    .foregroundColor(showThemeView ? .yellow : .blue)
                                Text("Theme")
                                    .font(.headline)
                                    .foregroundColor(showThemeView ? .yellow : .blue)
                                // .background(.lightBackground)
                            }
                        }
                        
                        Button(action: {
                            showThemeView = false
                            showGridView = true
                        }) {
                            VStack {
                                Image(systemName: "square.grid.3x3.fill")
                                    .foregroundColor(showGridView ? .yellow : .blue)
                                Text("Size")
                                    .font(.headline)
                                    .foregroundColor(showGridView ? .yellow : .blue)
                                // .background(.lightBackground)
                            }
                        }
                        
                        NavigationLink {
                            ContentView(gridSize: $selectedSize, isShowTimer: $isShowTimer, isShowError:  $isShowError, words: $words, wordsDictionary: $wordsDictionary).navigationBarBackButtonHidden(true)
                        } label: {
                            VStack {
                                Image(systemName: "arrowtriangle.right.circle.fill")
                                Text("Start")
                                    .font(.headline)
                                //  .background(.lightBackground)
                                
                            }
                        }
                        // .disabled(!isGridSelected)
                        .disabled(!isThemeSelected || !isGridSelected)
                        .opacity(!isThemeSelected || !isGridSelected ? 0.4 : 1.0)
                      
                    }
                }
            }
            .background(.lightBackground)
            
        }
        .onAppear {
            showThemeView = true
            showGridView = false
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}

