//
//  KeyboardHelper.swift
//  MobileDeveloperChallenge
//
//  Created by Amir Ahmed on 10/08/2024.
//

import Foundation
import UIKit
import SwiftUI

extension KeyboardHelper {
    enum Animation {
        case keyboardWillShow
        case keyboardWillHide
    }

    typealias HandleBlock = (_ animation: Animation, _ keyboardFrame: CGRect, _ duration: TimeInterval) -> Void
}

final class KeyboardHelper {
    private let handleBlock: HandleBlock

    init(handleBlock: @escaping HandleBlock) {
        self.handleBlock = handleBlock
        setupNotification()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupNotification() {
        _ = NotificationCenter.default
            .addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] notification in
                self?.handle(animation: .keyboardWillShow, notification: notification)
            }

        _ = NotificationCenter.default
            .addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] notification in
                self?.handle(animation: .keyboardWillHide, notification: notification)
            }
    }

    private func handle(animation: Animation, notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        handleBlock(animation, keyboardFrame, duration)
    }
}

typealias HandleBlock = (Animation, CGRect, Double) -> Void


class KeyboardObserver: ObservableObject {
    @Published var keyboardFrame: CGRect = .zero
    @Published var isKeyboardVisible: Bool = false
    @Published var animationDuration: Double = 0.0

    private var keyboardHelper: KeyboardHelper?

    init() {
        keyboardHelper = KeyboardHelper { [weak self] animation, keyboardFrame, duration in
            DispatchQueue.main.async {
                self?.keyboardFrame = keyboardFrame
                self?.isKeyboardVisible = (animation == .keyboardWillShow)
                self?.animationDuration = duration
            }
        }
    }
}
