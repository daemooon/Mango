import SwiftUI

struct MGConfigurationView: View {
    
    @AppStorage("\(MGKernel.xray.rawValue.uppercased())_CURRENT", store: .shared) private var current: String = ""

    @EnvironmentObject private var tunnel: MGPacketTunnelManager
    @EnvironmentObject private var configurationListManager: MGConfigurationListManager
    
    @State private var isPresented = false
    
    var body: some View {
        LabeledContent {
            Button("切换") {
                isPresented.toggle()
            }
            .sheet(isPresented: $isPresented) {
                MGConfigurationListView(current: $current)
            }
        } label: {
            Label {
                Text(title)
                    .lineLimit(1)
            } icon: {
                Image(systemName: "doc.plaintext")
            }
        }
        .onAppear {
            configurationListManager.reload()
        }
    }
    
    private var title: String {
        guard let configuration = configurationListManager.configurations.first(where: { $0.id == current }) else {
            return "未选择"
        }
        return configuration.attributes.alias
    }
}
