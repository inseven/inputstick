//
//  NSInputView.swift
//  Keyboard
//
//  Created by Jason Barrie Morley on 07/10/2022.
//

import AppKit
import Carbon

class NSInputView: NSView {

    // TODO: These should be unsigned
    // TODO: Should this be an enum?
    struct Event {
        static let null: UInt8 = 0
        static let keyDown: UInt8 = 1
        static let keyUp: UInt8 = 2
        static let disable: UInt8 = 3
        static let enable: UInt8 = 4
    }

    // Mapping table between macOS keycodes and TinyUSB_Mouse_and_Keyboard codes.
    // https://github.com/cyborg5/TinyUSB_Mouse_and_Keyboard/blob/master/TinyUSB_Mouse_and_Keyboard.h
    static let mapping: [Int: UInt8] = [

        // Layout-independent keycodes.
        kVK_Return: 0xB0,
        kVK_Tab: 0xB3,
//        kVK_Space:
        kVK_Delete: 0xB2,
        kVK_Escape: 0xB1,
        kVK_Command: 0x83,
        kVK_Shift: 0x81,
        kVK_CapsLock: 0xC1,
        kVK_Option: 0x82,
        kVK_Control: 0x80,
        kVK_RightCommand: 0x87,
        kVK_RightShift: 0x85,
        kVK_RightOption: 0x86,
        kVK_RightControl: 0x84,
//        kVK_Function:
//        kVK_VolumeUp:
//        kVK_VolumeDown:
//        kVK_Mute:

        kVK_F1: 0xC2,
        kVK_F2: 0xC3,
        kVK_F3: 0xC4,
        kVK_F4: 0xC5,
        kVK_F5: 0xC6,
        kVK_F6: 0xC7,
        kVK_F7: 0xC8,
        kVK_F8: 0xC9,
        kVK_F9: 0xCA,
        kVK_F10: 0xCB,
        kVK_F11: 0xCC,
        kVK_F12: 0xCD,
        kVK_F13: 0xF0,
        kVK_F14: 0xF1,
        kVK_F15: 0xF2,
        kVK_F16: 0xF3,
        kVK_F17: 0xF4,
        kVK_F18: 0xF5,
        kVK_F19: 0xF6,
        kVK_F20: 0xF7,

//        kVK_Help:
        kVK_PageUp: 0xD3,
        kVK_PageDown: 0xD6,
        kVK_ForwardDelete: 0xD4,
        kVK_Home: 0xD2,
        kVK_End: 0xD5,
        kVK_LeftArrow: 0xD8,
        kVK_RightArrow: 0xD7,
        kVK_DownArrow: 0xD9,
        kVK_UpArrow: 0xDA,
    ]

    var scanner = Scanner()

    init(scanner: Scanner) {
        self.scanner = scanner
        super.init(frame: .zero)
        self.wantsLayer = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var acceptsFirstResponder: Bool {
        return true
    }

    override func becomeFirstResponder() -> Bool {
        self.layer?.backgroundColor = .init(red: 1, green: 0, blue: 0, alpha: 1)
        return super.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        self.layer?.backgroundColor = .clear
        return super.resignFirstResponder()
    }

    override func keyDown(with event: NSEvent) {
        if let keyCode = Self.mapping[Int(event.keyCode)] {
            scanner.writeData(data: Data([Event.keyDown, keyCode, Event.null]))
        } else if let character = event.characters?.first,
                  let characterCode = character.asciiValue {
            scanner.writeData(data: Data([Event.keyDown, characterCode, Event.null]))
        }
        super.keyDown(with: event)
    }

    override func keyUp(with event: NSEvent) {
        if let keyCode = Self.mapping[Int(event.keyCode)] {
            scanner.writeData(data: Data([Event.keyUp, keyCode, Event.null]))
        } else if let character = event.characters?.first,
                  let characterCode = character.asciiValue {
            scanner.writeData(data: Data([Event.keyUp, characterCode, Event.null]))
        }
        super.keyUp(with: event)
    }

}