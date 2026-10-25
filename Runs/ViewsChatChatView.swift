//
//  ChatView.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var conversations: [Conversation]
    
    @State private var showNewMessage = false
    
    var body: some View {
        NavigationStack {
            List {
                if conversations.isEmpty {
                    ContentUnavailableView(
                        "No Messages",
                        systemImage: "message",
                        description: Text("Start a conversation with friends")
                    )
                } else {
                    ForEach(conversations) { conversation in
                        NavigationLink {
                            ConversationDetailView(conversation: conversation)
                        } label: {
                            ConversationRow(conversation: conversation)
                        }
                    }
                }
            }
            .navigationTitle("Chat")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewMessage = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showNewMessage) {
                NewConversationView()
            }
        }
    }
}

// MARK: - Conversation Row

struct ConversationRow: View {
    let conversation: Conversation
    
    var body: some View {
        HStack {
            // Avatar
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: conversation.type == .dm ? "person.fill" : "person.2.fill")
                        .foregroundStyle(.blue)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.name ?? "Chat")
                    .font(.headline)
                
                Text("Last message preview...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("2:30 PM")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                // Unread badge
                Circle()
                    .fill(.orange)
                    .frame(width: 20, height: 20)
                    .overlay {
                        Text("3")
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                    }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Conversation Detail

struct ConversationDetailView: View {
    let conversation: Conversation
    
    @Environment(\.modelContext) private var modelContext
    @Query private var allMessages: [Message]
    
    @State private var messageText = ""
    
    var messages: [Message] {
        allMessages
            .filter { $0.conversationID == conversation.id }
            .sorted { $0.createdAt < $1.createdAt }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            // Message input
            HStack {
                TextField("Message", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(messageText.isEmpty ? .gray : .orange)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
            .background(Color(.systemGray6))
        }
        .navigationTitle(conversation.name ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let message = Message(
            conversationID: conversation.id,
            senderID: UUID(), // Mock current user ID
            body: messageText
        )
        
        modelContext.insert(message)
        messageText = ""
        
        try? modelContext.save()
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser = Bool.random() // Mock
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                if let body = message.body {
                    Text(body)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isFromCurrentUser ? Color.orange : Color(.systemGray5))
                        .foregroundStyle(isFromCurrentUser ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Text(message.createdAt, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            if !isFromCurrentUser {
                Spacer()
            }
        }
    }
}

// MARK: - New Conversation

struct NewConversationView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Text("Select friends to start a chat")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ChatView()
        .modelContainer(for: [Conversation.self, Message.self], inMemory: true)
}
