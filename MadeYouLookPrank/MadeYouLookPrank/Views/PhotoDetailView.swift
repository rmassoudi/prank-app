import SwiftUI
import UIKit

struct PhotoDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: CaptureStore
    let photo: CapturedPhoto

    @State private var shareItems: [Any] = []
    @State private var showShareSheet = false
    @State private var showDeleteConfirmation = false
    @State private var statusMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                ZStack {
                    Color.black

                    if let image = UIImage(contentsOfFile: store.photoURL(for: photo).path) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Text("Photo unavailable")
                            .foregroundStyle(.white)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .padding(.horizontal, 16)

                Text(photo.displayTimestamp)
                    .font(.headline)

                if let statusMessage {
                    Text(statusMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 12) {
                    Button {
                        shareItems = [store.photoURL(for: photo)]
                        showShareSheet = true
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        saveToPhotos()
                    } label: {
                        Label("Save", systemImage: "photo.badge.plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal, 16)

                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(.horizontal, 16)

                Spacer(minLength: 0)
            }
            .navigationTitle("Capture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ActivityView(activityItems: shareItems)
            }
            .confirmationDialog(
                "Delete this photo?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    deletePhoto()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private func saveToPhotos() {
        Task {
            do {
                try await PhotoLibraryExporter.export(photoURLs: [store.photoURL(for: photo)])
                await MainActor.run {
                    statusMessage = "Saved to Photos."
                }
            } catch {
                await MainActor.run {
                    statusMessage = error.localizedDescription
                }
            }
        }
    }

    private func deletePhoto() {
        do {
            try store.delete(photo)
            dismiss()
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}

