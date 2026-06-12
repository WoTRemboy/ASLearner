//
//  ContentView.swift
//  ASLearner
//
//  Created by Roman Tverdokhleb on 16/12/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()

    var body: some View {
        Group {
            if appViewModel.hasCompletedOnboarding {
                AppTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(appViewModel)
    }
}

#Preview {
    ContentView()
}
