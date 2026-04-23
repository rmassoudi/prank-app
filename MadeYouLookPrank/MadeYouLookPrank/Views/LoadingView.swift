import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.98, blue: 0.96), .white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 22) {
                FlameIconView()
                    .frame(width: 112, height: 112)
                    .shadow(color: Color(red: 0.95, green: 0.15, blue: 0.24).opacity(0.22), radius: 24, y: 14)

                ProgressView()
                    .tint(Color(red: 0.92, green: 0.14, blue: 0.28))

                Text("Loading FlameMatch...")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    LoadingView()
}

