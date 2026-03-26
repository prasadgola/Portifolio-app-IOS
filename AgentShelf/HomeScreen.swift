import SwiftUI

struct HomeScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.amber)
                            .frame(width: 80, height: 80)
                        Text("AG")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Text("AgentShelf")
                        .font(.title.bold())
                    Text("AI-Powered Digital Twin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)

                // Feature cards
                VStack(spacing: 16) {
                    FeatureCard(
                        icon: "mic.fill",
                        title: "Voice Chat",
                        description: "Talk to the AI in real-time using your voice.",
                        color: .orange
                    )
                    FeatureCard(
                        icon: "bubble.left.fill",
                        title: "Text Chat",
                        description: "Chat with the AI assistant via text messages.",
                        color: .blue
                    )
                    FeatureCard(
                        icon: "person.fill",
                        title: "About",
                        description: "What Basavaprasad can do?",
                        color: .purple
                    )
                }
                .padding(.horizontal)

                Text("Powered by Google Gemini")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 40)
            }
        }
        .navigationTitle("AgentSelf")
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}
