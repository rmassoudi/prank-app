import SwiftUI
import UIKit

struct RevealView: View {
    @EnvironmentObject private var store: CaptureStore
    let photo: CapturedPhoto
    let onDone: () -> Void

    @State private var showGallery = false
    @State private var revealScale = 0.72
    @State private var flashOpacity = 0.86
    @State private var shake = false

    var body: some View {
        ZStack {
            capturedImage
                .ignoresSafeArea()

            Color.black.opacity(0.25)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Spacer()

                Text("MADE YOU LOOK!")
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.6), radius: 12, y: 4)
                    .scaleEffect(revealScale)
                    .rotationEffect(.degrees(shake ? -2.8 : 2.8))

                Text("This is a prank app - caught you snooping!")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.65), radius: 10, y: 3)
                    .padding(.horizontal, 24)

                Text(photo.displayTimestamp)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.top, 4)

                Button(action: onDone) {
                    Text("Got Me!")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.92, green: 0.14, blue: 0.28))
                .padding(.horizontal, 28)
                .padding(.top, 18)
                .padding(.bottom, 34)
            }

            Color.white
                .opacity(flashOpacity)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            hiddenGalleryHotspot
        }
        .onAppear(perform: runRevealAnimation)
        .sheet(isPresented: $showGallery) {
            GalleryView()
        }
    }

    private var capturedImage: some View {
        Group {
            if let image = UIImage(contentsOfFile: store.photoURL(for: photo).path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [.black, Color(red: 0.35, green: 0.05, blue: 0.12)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .overlay {
                    Text("Photo unavailable")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private var hiddenGalleryHotspot: some View {
        VStack {
            HStack {
                Color.clear
                    .frame(width: 88, height: 88)
                    .contentShape(Rectangle())
                    .onTapGesture(count: 3) {
                        showGallery = true
                    }
                    .onLongPressGesture(minimumDuration: 3) {
                        showGallery = true
                    }
                Spacer()
            }
            Spacer()
        }
        .ignoresSafeArea()
    }

    private func runRevealAnimation() {
        withAnimation(.easeOut(duration: 0.42)) {
            flashOpacity = 0
            revealScale = 1.0
        }

        withAnimation(
            .easeInOut(duration: 0.08)
            .repeatCount(8, autoreverses: true)
        ) {
            shake.toggle()
        }
    }
}

