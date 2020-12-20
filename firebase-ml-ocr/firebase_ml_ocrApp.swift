//
//  firebase_ml_ocrApp.swift
//  firebase-ml-ocr
//
//  Created by yorifuji on 2020/12/19.
//

import SwiftUI
import Firebase

@main
struct firebase_ml_ocrApp: App {
    init() {
      FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
