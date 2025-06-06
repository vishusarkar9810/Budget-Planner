//
//  AnimationManager.swift
//  Budget Planner
//
//  Created for enhanced onboarding
//

import SwiftUI

/// A utility class to manage animated image sequences
@Observable final class AnimationManager {
    // Animation state
    private(set) var currentFrame: UIImage?
    private(set) var isPlaying = false
    
    // Animation properties
    private var animationFrames: [UIImage] = []
    private var frameCount: Int = 0
    private var currentIndex: Int = 0
    private var timer: Timer?
    private var frameDuration: TimeInterval = 0.05
    
    // MARK: - Public Methods
    
    /// Load animation frames from a sequence of images
    /// - Parameters:
    ///   - baseName: The base name of the image sequence
    ///   - count: The number of images in the sequence
    ///   - format: The format of the images (default: "png")
    func loadAnimation(baseName: String, count: Int, format: String = "png") {
        stop()
        animationFrames = []
        frameCount = 0
        
        for i in 1...count {
            if let image = UIImage(named: "\(baseName)\(i).\(format)") {
                animationFrames.append(image)
                frameCount += 1
            }
        }
        
        if !animationFrames.isEmpty {
            currentFrame = animationFrames[0]
        }
    }
    
    /// Start playing the animation
    /// - Parameter loop: Whether to loop the animation
    func play(loop: Bool = true) {
        guard !animationFrames.isEmpty, timer == nil else { return }
        
        isPlaying = true
        
        // Create a timer to advance frames
        timer = Timer.scheduledTimer(withTimeInterval: frameDuration, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Move to next frame
            self.currentIndex = (self.currentIndex + 1) % self.frameCount
            self.currentFrame = self.animationFrames[self.currentIndex]
            
            // Stop if not looping and we've reached the end
            if !loop && self.currentIndex == self.frameCount - 1 {
                self.stop()
            }
        }
    }
    
    /// Stop the animation
    func stop() {
        timer?.invalidate()
        timer = nil
        isPlaying = false
    }
    
    /// Set the frame rate for the animation
    /// - Parameter fps: Frames per second
    func setFrameRate(fps: Double) {
        frameDuration = 1.0 / fps
        
        // If already playing, restart with new frame rate
        if isPlaying {
            let wasPlaying = isPlaying
            stop()
            if wasPlaying {
                play()
            }
        }
    }
    
    // Clean up when deallocated
    deinit {
        stop()
    }
}

/// A SwiftUI view that displays an animated image sequence
struct AnimatedImageView: View {
    @State private var animationManager = AnimationManager()
    
    let animationBaseName: String
    let frameCount: Int
    let autoPlay: Bool
    let looping: Bool
    let fps: Double
    
    init(
        animationBaseName: String,
        frameCount: Int,
        fps: Double = 24,
        autoPlay: Bool = true,
        looping: Bool = true
    ) {
        self.animationBaseName = animationBaseName
        self.frameCount = frameCount
        self.fps = fps
        self.autoPlay = autoPlay
        self.looping = looping
    }
    
    var body: some View {
        Group {
            if let currentFrame = animationManager.currentFrame {
                Image(uiImage: currentFrame)
                    .resizable()
                    .scaledToFit()
            } else {
                // Placeholder when no animation is loaded
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            // Load and play animation when view appears
            animationManager.loadAnimation(baseName: animationBaseName, count: frameCount)
            animationManager.setFrameRate(fps: fps)
            
            if autoPlay {
                animationManager.play(loop: looping)
            }
        }
        .onDisappear {
            // Stop animation when view disappears
            animationManager.stop()
        }
    }
}

/// A placeholder view for showing animated GIFs (for demo purposes)
struct GIFImageView: View {
    let name: String
    let aspectRatio: CGFloat
    
    init(_ name: String, aspectRatio: CGFloat = 1.0) {
        self.name = name
        self.aspectRatio = aspectRatio
    }
    
    var body: some View {
        // This is a placeholder for actual GIF implementation
        // In a real app, you would use a third-party library or native implementation
        ZStack {
            Image(systemName: "photo.fill")
                .resizable()
                .scaledToFit()
                .opacity(0.1)
            
            VStack {
                Text("GIF Animation")
                    .font(.headline)
                Text(name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
} 