//
//  LiveInspectorView.swift
//  PawPal - View Layer
//
//  Live Activity & Payload Inspector.
//  Provides real-time inspection of API calls, responses, event triggers, and JSON payloads.
//

import SwiftUI

/// View displaying live networking events, payloads, and simulated event telemetry.
struct LiveInspectorView: View {
    @ObservedObject var inspectorVM = LiveInspectorViewModel.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var expandedLogId: String? = nil
    @State private var copiedLogId: String? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Filter Bar
                categoryFilterBar
                
                // Content List or Empty State
                if inspectorVM.filteredLogs.isEmpty {
                    emptyLogsView
                } else {
                    logListView
                }
            }
            .inlineTitle("Live Activity & Payload Inspector")
            .toolbar {
                ToolbarItem(placement: .leadingPlacement) {
                    Button(role: .destructive, action: {
                        inspectorVM.clearLogs()
                    }) {
                        Label("Clear", systemImage: "trash")
                    }
                    .disabled(inspectorVM.logs.isEmpty)
                }
                
                ToolbarItem(placement: .trailingPlacement) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Filter Bar
    
    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(InspectorLogCategory.allCases) { category in
                    Button(action: {
                        inspectorVM.selectedCategory = category
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: category.iconName)
                            Text(category.rawValue)
                        }
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(inspectorVM.selectedCategory == category ? Color.orange : Color.chipBackground)
                        .foregroundColor(inspectorVM.selectedCategory == category ? .white : .primary)
                        .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(Color.surfaceBackground)
        .overlay(Divider(), alignment: .bottom)
    }
    
    // MARK: - Empty State
    
    private var emptyLogsView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "terminal")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No Logs Recorded Yet")
                .font(.headline)
            Text("Perform actions in PawPal (log a walk, add a reminder, or save a tip) to inspect real-time payloads.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }
    
    // MARK: - Log List
    
    private var logListView: some View {
        List {
            ForEach(inspectorVM.filteredLogs) { log in
                VStack(alignment: .leading, spacing: 8) {
                    // Header Row
                    HStack(alignment: .top) {
                        Image(systemName: log.category.iconName)
                            .foregroundColor(log.isSuccess ? .orange : .red)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(log.title)
                                .font(.subheadline.weight(.semibold))
                            
                            HStack(spacing: 6) {
                                if let method = log.method {
                                    Text(method)
                                        .font(.caption2.bold())
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.15))
                                        .foregroundColor(.blue)
                                        .cornerRadius(4)
                                }
                                
                                if let status = log.statusCode {
                                    Text("\(status)")
                                        .font(.caption2.bold())
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background((200...299).contains(status) ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                                        .foregroundColor((200...299).contains(status) ? .green : .red)
                                        .cornerRadius(4)
                                }
                                
                                Text(log.formattedTime)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        // Expand / Collapse Chevron
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if expandedLogId == log.id {
                                    expandedLogId = nil
                                } else {
                                    expandedLogId = log.id
                                }
                            }
                        }) {
                            Image(systemName: expandedLogId == log.id ? "chevron.up.circle.fill" : "chevron.down.circle")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.borderless)
                    }
                    
                    // Expanded JSON Payload View
                    if expandedLogId == log.id {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Payload Inspector")
                                    .font(.caption.bold())
                                    .foregroundColor(.secondary)
                                Spacer()
                                
                                // Copy Button
                                Button(action: {
                                    #if canImport(UIKit)
                                    UIPasteboard.general.string = log.payloadJSON
                                    #elseif canImport(AppKit)
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(log.payloadJSON, forType: .string)
                                    #endif
                                    copiedLogId = log.id
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        if copiedLogId == log.id { copiedLogId = nil }
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: copiedLogId == log.id ? "checkmark" : "doc.on.doc")
                                        Text(copiedLogId == log.id ? "Copied" : "Copy Payload")
                                    }
                                    .font(.caption2.bold())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.orange.opacity(0.15))
                                    .foregroundColor(.orange)
                                    .cornerRadius(6)
                                }
                                .buttonStyle(.borderless)
                            }
                            
                            // Code Block Box
                            ScrollView(.horizontal, showsIndicators: true) {
                                Text(log.payloadJSON)
                                    .font(.system(.caption, design: .monospaced))
                                    .padding(10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .background(Color.inputBackground)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.separatorColor, lineWidth: 0.5)
                            )
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .appListStyle()
    }
}
