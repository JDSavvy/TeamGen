import SwiftUI

// MARK: - Player Loading State View
/// Modern loading state view with subtle animation for player management
struct PlayerLoadingStateView: View {
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Modern loading indicator with subtle animation
            ZStack {
                Circle()
                    .stroke(DesignSystem.Colors.primary.opacity(DesignSystem.VisualConsistency.opacityIconBackground), lineWidth: DesignSystem.VisualConsistency.borderBold)
                    .frame(width: DesignSystem.ComponentSize.loadingIndicatorStandard, height: DesignSystem.ComponentSize.loadingIndicatorStandard)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primary.opacity(DesignSystem.VisualConsistency.opacityLoading)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: DesignSystem.VisualConsistency.borderBold, lineCap: .round)
                    )
                    .frame(width: DesignSystem.ComponentSize.loadingIndicatorStandard, height: DesignSystem.ComponentSize.loadingIndicatorStandard)
                    .rotationEffect(.degrees(rotationAngle))
                    .onAppear {
                        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                            rotationAngle = 360
                        }
                    }
            }
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Loading Players")
                    .font(DesignSystem.Typography.loadingStateTitle)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                Text("Fetching your player roster")
                    .font(DesignSystem.Typography.loadingStateSubtitle)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DesignSystem.Spacing.xxxl)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading players")
        .accessibilityHint("Please wait while your player roster is being loaded")
    }
}

// MARK: - Preview
#if DEBUG
struct PlayerLoadingStateView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerLoadingStateView()
    }
}
#endif 