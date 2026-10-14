//
//  DateFormatterHelper.swift
//  PawPal - Utility Layer
//
//  Centralized date formatting helpers for ISO 8601 strings and user-friendly display dates.
//

import Foundation

/// Helper for converting Dates to ISO 8601 strings for API requests,
/// and converting server timestamps into human-readable strings for the UI.
struct DateFormatterHelper {
    
    /// ISO 8601 formatter used for communicating with the FastAPI backend.
    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    /// Fallback ISO 8601 formatter without fractional seconds.
    private static let isoFormatterStandard: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    /// Converts a Swift Date object to an ISO 8601 string.
    static func toISOString(_ date: Date) -> String {
        return isoFormatter.string(from: date)
    }
    
    /// Parses an ISO 8601 string from the API into a Swift Date.
    static func parseISO(_ string: String) -> Date? {
        if let date = isoFormatter.date(from: string) {
            return date
        }
        return isoFormatterStandard.date(from: string)
    }
    
    /// Formats an ISO string into friendly time (e.g. "Today at 3:30 PM", "Yesterday", or "Oct 14").
    static func formatRelative(_ isoString: String) -> String {
        guard let date = parseISO(isoString) else { return isoString }
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            return "Today, " + timeFormatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            return "Yesterday, " + timeFormatter.string(from: date)
        } else {
            let fullFormatter = DateFormatter()
            fullFormatter.dateStyle = .medium
            fullFormatter.timeStyle = .short
            return fullFormatter.string(from: date)
        }
    }
    
    /// Formats an ISO string to a concise date (e.g. "Apr 10, 2022").
    static func formatShortDate(_ isoString: String) -> String {
        guard let date = parseISO(isoString) else { return isoString }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

