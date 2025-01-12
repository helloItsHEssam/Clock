//
//  ContentView.swift
//  Clock
//
//  Created by HEssam on 1/13/25.
//

import SwiftUI

struct ContentView: View {
    
    @State var isMovingToCenter: [Bool] = Array(repeating: false, count: 12)
    @State var rotationDegrees: [Double] = Array(stride(from: 0, to: 360, by: 30))
    @State var rotationIndexes: [Int] = Array(0..<12)
    @State var distanceIndexes: [Int] = Array(0..<12)
    
    private let maxRadius: CGFloat = 330
    private let stepDistance: CGFloat = 30
    
    var body: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { index in
                Rectangle()
                    .fill(.orange)
                    .frame(width: 30, height: 30)
                    .rotationEffect(.degrees(rotationDegrees[index]))
                    .offset(
                        x: (maxRadius - calculateOffsets(for: distanceIndexes[index])) * cos(CGFloat(-rotationIndexes[index]) * 30 * .pi / 180),
                        y: (maxRadius - calculateOffsets(for: distanceIndexes[index])) * sin(CGFloat(rotationIndexes[index]) * 30 * .pi / 180)
                    )
                    .onTapGesture {
                        loopingAnimation()
                    }
            }
            
        }
        .rotationEffect(.degrees(270))
    }
    
    private func calculateOffsets(for index: Int) -> CGFloat {
        isMovingToCenter[index] ? maxRadius - CGFloat(index) * stepDistance : 0
    }
    
    func animateForward(atIndex currentIndex: Int, completion: @escaping () -> Void) {
        withAnimation(.easeInOut(duration: 0.3)) {
            isMovingToCenter[currentIndex] = true
            let newDegree = rotationDegrees[currentIndex] + stepDistance
            let newIndex = rotationIndexes[currentIndex] + 1
            rotationDegrees[0...currentIndex] = ArraySlice(repeating: newDegree, count: currentIndex + 1)
            rotationIndexes[0...currentIndex] = ArraySlice(repeating: newIndex, count: currentIndex + 1)
        } completion: {
            completion()
        }
    }
    
    func animateBackward(atIndex currentIndex: Int, completion: @escaping () -> Void) {
        withAnimation(.easeIn(duration: 0.3)) {
            isMovingToCenter[currentIndex] = false
            let newDegree = currentIndex == 11 ? 0 : rotationDegrees[currentIndex] + stepDistance
            let newIndex = 12 - (currentIndex + 1)
            
            for i in 0...currentIndex {
                rotationDegrees[i] = newDegree
                rotationIndexes[i] = newIndex
            }
        } completion: {
            completion()
        }
    }
    
    func loopForwardAnimation(firstIndex: Int, completion: @escaping () -> Void) {
        animateForward(atIndex: firstIndex) {
            if firstIndex + 1 < 12 {
                loopForwardAnimation(firstIndex: firstIndex + 1, completion: completion)
            } else {
                completion()
            }
        }
    }
    
    func loopBackwardAnimation(firstIndex: Int, completion: @escaping () -> Void) {
        animateBackward(atIndex: firstIndex) {
            if firstIndex - 1 >= 0 {
                loopBackwardAnimation(firstIndex: firstIndex - 1, completion: completion)
            } else {
                completion()
            }
        }
    }
    
    func loopingAnimation() {
        loopForwardAnimation(firstIndex: 0) {
            rotationDegrees = Array(repeating: 0, count: 12)
            loopBackwardAnimation(firstIndex: 11) {
                rotationDegrees = Array(stride(from: 0, to: 360, by: 30))
                rotationIndexes = Array(0..<12)
                loopingAnimation()
            }
        }
    }
}

#Preview {
    ContentView()
}
