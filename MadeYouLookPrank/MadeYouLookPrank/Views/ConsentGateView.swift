import SwiftUI

struct ConsentGateView: View {
    let errorMessage: String?
    let onStart: () -> Void

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer(minLength: 24)

                FlameIconView()
                    .frame(width: 104, height: 104)

                VStack(spacing: 12) {
                    Text("FlameMatch")
                        .font(.largeTitle.bold())

                    Text("Prank mode captures one selfie after you tap Start, shows it back to you, and stores it locally on this iPhone.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 28)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.callout)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                }

                Button(action: onStart) {
                    Text("Start")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.92, green: 0.14, blue: 0.28))
                .padding(.horizontal, 28)

                Text("No uploads. No cloud. Owner gallery is stored on-device only.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer(minLength: 24)
            }
        }
    }
}

#Preview {
    ConsentGateView(errorMessage: nil, onStart: {})
}

