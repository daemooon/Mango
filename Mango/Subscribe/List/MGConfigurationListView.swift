import SwiftUI

struct MGConfigurationListView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var tunnel: MGPacketTunnelManager
    @EnvironmentObject private var configurationListManager: MGConfigurationListManager
    
    @State private var isDownloadViewPresented = false
    
    let current: Binding<String>
    
    var body: some View {
        NavigationStack {
            List(configurationListManager.configurations) { configuration in
                Button {
                    guard current.wrappedValue != configuration.id else {
                        return
                    }
                    current.wrappedValue = configuration.id
                    dismiss()
                    guard let status = tunnel.status, status == .connected else {
                        return
                    }
                    tunnel.stop()
                    Task(priority: .userInitiated) {
                        do {
                            try await Task.sleep(for: .milliseconds(500))
                            try await tunnel.start()
                        } catch {}
                    }
                } label: {
                    HStack(alignment: .center, spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(configuration.attributes.alias)
                                .lineLimit(1)
                                .foregroundColor(.primary)
                                .fontWeight(.medium)
                            Text(configuration.attributes.leastUpdated.formatted(.relative(presentation: .named)))
                                .lineLimit(1)
                                .foregroundColor(.secondary)
                                .font(.callout)
                                .fontWeight(.light)
                        }
                        Spacer()
                        if configurationListManager.downloadingConfigurationIDs.contains(configuration.id) {
                            ProgressView()
                        }
                        if current.wrappedValue == configuration.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                                .fontWeight(.medium)
                        }
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button("??????", role: .destructive) {
                        do {
                            try configurationListManager.delete(configuration: configuration)
                            if configuration.id == current.wrappedValue {
                                current.wrappedValue = ""
                            }
                            MGNotification.send(title: "", subtitle: "", body: "\"\(configuration.attributes.alias)\"????????????")
                        } catch {
                            MGNotification.send(title: "", subtitle: "", body: "\"\(configuration.attributes.alias)\"????????????, ??????: \(error.localizedDescription)")
                        }
                    }
                    .disabled(configurationListManager.downloadingConfigurationIDs.contains(configuration.id))
                    
//                    Button("?????????") {
//                        self.subscribeName = item.extend.alias
//                        self.subscribeItem = item
//                        self.isRenameAlertPresented.toggle()
//                    }
//                    .tint(.yellow)
//                    .disabled(configurationListManager.downloadingConfigurationIDs.contains(configuration.id))
                    
                    Button("??????") {
                        Task(priority: .userInitiated) {
                            do {
                                try await configurationListManager.update(configuration: configuration)
                                MGNotification.send(title: "", subtitle: "", body: "\"\(configuration.attributes.alias)\"????????????")
                            } catch {
                                MGNotification.send(title: "", subtitle: "", body: "\"\(configuration.attributes.alias)\"????????????, ??????: \(error.localizedDescription)")
                            }
                        }
                    }
                    .tint(.green)
                    .disabled(configuration.attributes.source.isFileURL || configurationListManager.downloadingConfigurationIDs.contains(configuration.id))
                }
            }
            .navigationTitle(Text("????????????"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button {
                    isDownloadViewPresented.toggle()
                } label: {
                    Image(systemName: "plus")
                        .fontWeight(.medium)
                }
            }
            .sheet(isPresented: $isDownloadViewPresented) {
                MGConfigurationDownloadView()
            }
        }
    }
}
