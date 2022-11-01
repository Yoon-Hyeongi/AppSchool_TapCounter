//
//  TapCounterApp.swift
//  TapCounter
//
//  Created by 윤현기 on 2022/11/01.
//

import SwiftUI

@main
struct TapCounterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(timerData: TimerData())
        }
    }
}
