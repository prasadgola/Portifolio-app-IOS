import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct TextChatScreen: View {
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Chat messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            if messages.isEmpty {
                                VStack(spacing: 8) {
                                    Spacer().frame(height: 100)
                                    Text("Chat with AgentShelf")
                                        .foregroundColor(.white)
                                        .font(.system(size: 22, weight: .bold))
                                    Text("Ask me anything!")
                                        .foregroundColor(.white.opacity(0.5))
                                        .font(.system(size: 14))
                                }
                                .frame(maxWidth: .infinity)
                            }

                            ForEach(messages) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
                            }

                            if isLoading {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .tint(.white)
                                        .scaleEffect(0.8)
                                    Text("Thinking...")
                                        .foregroundColor(.white.opacity(0.5))
                                        .font(.system(size: 14))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 4)
                                .id("loading")
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                    .onChange(of: messages.count) { _, _ in
                        if let lastId = messages.last?.id {
                            withAnimation {
                                proxy.scrollTo(lastId, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: isLoading) { _, newValue in
                        if newValue {
                            withAnimation {
                                proxy.scrollTo("loading", anchor: .bottom)
                            }
                        }
                    }
                }

                // Input bar
                HStack(spacing: 8) {
                    TextField("Type a message...", text: $inputText)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .foregroundColor(.white)
                        .submitLabel(.send)
                        .onSubmit { sendMessage() }

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.black)
            }
            .background(Color.black)
            .navigationTitle("AgentSelf")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, !isLoading else { return }

        inputText = ""
        messages.append(ChatMessage(text: text, isUser: true))
        isLoading = true

        Task {
            let reply = await sendToBackend(message: text)
            await MainActor.run {
                messages.append(ChatMessage(text: reply, isUser: false))
                isLoading = false
            }
        }
    }

    private func sendToBackend(message: String) async -> String {
        guard let url = URL(string: "https://basavaprasad-digital-twin-882178443942.us-central1.run.app/chat") else {
            return "Error: Invalid URL"
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let body: [String: Any] = ["message": message]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            return "Error: Failed to encode message"
        }
        request.httpBody = httpBody

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return "Error: Server returned an error"
            }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let responseText = json["response"] as? String {
                return responseText
            }
            return "No response"
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: UIScreen.main.bounds.width * 0.25) }

            Text(message.text)
                .font(.system(size: 15))
                .lineSpacing(6)
                .foregroundColor(message.isUser ? .black : .white)
                .padding(12)
                .background(
                    message.isUser
                        ? Color.white
                        : Color.white.opacity(0.1)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )

            if !message.isUser { Spacer(minLength: UIScreen.main.bounds.width * 0.25) }
        }
    }
}
