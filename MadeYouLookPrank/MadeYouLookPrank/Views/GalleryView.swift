import SwiftUI
import UIKit

struct GalleryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: CaptureStore
    @State private var selectedPhoto: CapturedPhoto?
    @State private var shareItems: [Any] = []
    @State private var showShareSheet = false
    @State private var showClearConfirmation = false
    @State private var statusMessage: String?

    private let columns = [
        GridItem(.adaptive(minimum: 112), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if store.photos.isEmpty {
                    ContentUnavailableView(
                        "No captures yet",
                        systemImage: "photo.on.rectangle.angled",
                        description: Text("Captured prank selfies will appear here.")
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(store.photos) { photo in
                                GalleryPhotoCell(photo: photo)
                                    .onTapGesture {
                                        selectedPhoto = photo
                                    }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Owner Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            shareAll()
                        } label: {
                            Label("Share All", systemImage: "square.and.arrow.up")
                        }
                        .disabled(store.photos.isEmpty)

                        Button {
                            saveAllToPhotos()
                        } label: {
                            Label("Save All to Photos", systemImage: "photo.badge.plus")
                        }
                        .disabled(store.photos.isEmpty)

                        Button(role: .destructive) {
                            showClearConfirmation = true
                        } label: {
                            Label("Clear All", systemImage: "trash")
                        }
                        .disabled(store.photos.isEmpty)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("Gallery actions")
                }
            }
            .safeAreaInset(edge: .bottom) {
                if let statusMessage {
                    Text(statusMessage)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 14)
                        .background(.thinMaterial, in: Capsule())
                        .padding(.bottom, 8)
                }
            }
            .sheet(item: $selectedPhoto) { photo in
                PhotoDetailView(photo: photo)
                    .environmentObject(store)
            }
            .sheet(isPresented: $showShareSheet) {
                ActivityView(activityItems: shareItems)
            }
            .confirmationDialog(
                "Clear all captured photos?",
                isPresented: $showClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All", role: .destructive) {
                    clearAll()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This removes every locally stored prank photo from this app.")
            }
        }
    }

    private func shareAll() {
        shareItems = store.allPhotoURLs()
        showShareSheet = !shareItems.isEmpty
    }

    private func saveAllToPhotos() {
        Task {
            do {
                try await PhotoLibraryExporter.export(photoURLs: store.allPhotoURLs())
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

    private func clearAll() {
        do {
            try store.clearAll()
            statusMessage = "Gallery cleared."
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}

private struct GalleryPhotoCell: View {
    @EnvironmentObject private var store: CaptureStore
    let photo: CapturedPhoto

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(.secondarySystemBackground))

                if let image = UIImage(contentsOfFile: store.photoURL(for: photo).path) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(photo.displayTimestamp)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .contentShape(Rectangle())
    }
}

