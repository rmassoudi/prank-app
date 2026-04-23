import SwiftUI

/// Original Tinder-style-adjacent flame mark for this prank app.
/// This is not the Tinder logo and should not be used to impersonate Tinder.
struct FlameIconView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(.white)

            Circle()
                .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)

            FlameShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.47, blue: 0.20),
                            Color(red: 0.92, green: 0.13, blue: 0.30),
                            Color(red: 0.72, green: 0.05, blue: 0.22)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(18)

            InnerFlameShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.88, blue: 0.36),
                            Color(red: 1.0, green: 0.45, blue: 0.18)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .padding(34)
                .offset(y: 8)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct FlameShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let p = { (x: CGFloat, y: CGFloat) in
            CGPoint(x: rect.minX + rect.width * x, y: rect.minY + rect.height * y)
        }

        path.move(to: p(0.50, 0.95))
        path.addCurve(to: p(0.27, 0.68), control1: p(0.35, 0.88), control2: p(0.24, 0.80))
        path.addCurve(to: p(0.39, 0.37), control1: p(0.29, 0.55), control2: p(0.39, 0.47))
        path.addCurve(to: p(0.47, 0.07), control1: p(0.39, 0.25), control2: p(0.48, 0.15))
        path.addCurve(to: p(0.73, 0.49), control1: p(0.67, 0.20), control2: p(0.76, 0.34))
        path.addCurve(to: p(0.90, 0.35), control1: p(0.81, 0.46), control2: p(0.87, 0.40))
        path.addCurve(to: p(0.50, 0.95), control1: p(1.00, 0.66), control2: p(0.82, 0.90))
        path.closeSubpath()
        return path
    }
}

struct InnerFlameShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let p = { (x: CGFloat, y: CGFloat) in
            CGPoint(x: rect.minX + rect.width * x, y: rect.minY + rect.height * y)
        }

        path.move(to: p(0.50, 0.92))
        path.addCurve(to: p(0.32, 0.62), control1: p(0.38, 0.82), control2: p(0.31, 0.73))
        path.addCurve(to: p(0.46, 0.21), control1: p(0.34, 0.45), control2: p(0.48, 0.36))
        path.addCurve(to: p(0.71, 0.62), control1: p(0.64, 0.38), control2: p(0.73, 0.48))
        path.addCurve(to: p(0.50, 0.92), control1: p(0.69, 0.78), control2: p(0.62, 0.87))
        path.closeSubpath()
        return path
    }
}

#Preview {
    FlameIconView()
        .frame(width: 180, height: 180)
        .padding()
        .background(Color(.systemGroupedBackground))
}

