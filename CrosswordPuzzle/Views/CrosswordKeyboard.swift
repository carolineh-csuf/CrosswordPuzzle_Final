//
//  CrosswordKeyboard.swift
//  TestFocus
//
//  Created by Caroline Ha on 4/5/23.
//


import SwiftUI

struct CrosswordKeyboard: UIViewRepresentable {
    @Binding var text: String
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CrosswordKeyboard
        
        init(_ parent: CrosswordKeyboard) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            DispatchQueue.main.async {
                if let last = string.last {
                    if last.isLetter {
                        self.parent.text = String(last).uppercased()
                    }
                } else if string == "" {
                    self.parent.text = " "
                }
            }
            
            return false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextField {
        let textfield = UITextField()
        textfield.delegate = context.coordinator
        
        
        textfield.tintColor = .clear
        textfield.textColor = .clear
        
        textfield.keyboardType = .asciiCapable
        textfield.autocorrectionType = .no
        textfield.spellCheckingType = .no
        textfield.textContentType = .oneTimeCode
       // textfield.keyboardType = .asciiCapable
        
        return textfield
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        
        if (!uiView.isFirstResponder) {
            uiView.becomeFirstResponder()
        }
        
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
}


struct CrosswordKeyboard_Previews: PreviewProvider {
    static var previews: some View {
        CrosswordKeyboard(text: .constant(""))
    }
}
