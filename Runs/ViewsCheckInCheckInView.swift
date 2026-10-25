//
//  CheckInView.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import SwiftUI
import SwiftData
import VisionKit
import Vision

struct CheckInView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var courts: [Court]
    
    @State private var showScanner = false
    @State private var selectedCourt: Court?
    @State private var checkInStatus: CheckInStatus = .playing
    @State private var partySize = 1
    @State private var showStatusPicker = false
    @State private var errorMessage: String?
    
    // Mock current user ID (replace with real auth)
    let currentUserID = UUID()
    
    var nearbyCourts: [Court] {
        // In production, filter by location
        courts.prefix(5).map { $0 }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 60))
                        .foregroundStyle(.orange)
                    
                    Text("Check In")
                        .font(.title.bold())
                    
                    Text("Scan the QR code at the court\nor select a nearby court")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // QR Scanner button
                Button {
                    showScanner = true
                } label: {
                    Label("Scan QR Code", systemImage: "qrcode.viewfinder")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                
                // Divider
                HStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                    Text("OR")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                }
                .padding(.horizontal)
                
                // Nearby courts
                VStack(alignment: .leading, spacing: 12) {
                    Text("Nearby Courts")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if nearbyCourts.isEmpty {
                        ContentUnavailableView(
                            "No courts nearby",
                            systemImage: "basketball",
                            description: Text("Move closer to a court or scan the QR code")
                        )
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(nearbyCourts) { court in
                                    NearbyCourtRow(court: court) {
                                        selectedCourt = court
                                        showStatusPicker = true
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Check In")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showScanner) {
                QRScannerView { qrData in
                    handleQRScan(qrData)
                }
            }
            .sheet(isPresented: $showStatusPicker) {
                if let court = selectedCourt {
                    CheckInConfirmationView(
                        court: court,
                        status: $checkInStatus,
                        partySize: $partySize
                    ) {
                        performCheckIn(court: court)
                    }
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleQRScan(_ qrData: String) {
        // Parse QR code and find court
        // Format: runs://checkin?court=<courtId>&sig=<hmac>
        guard let url = URL(string: qrData),
              url.scheme == "runs",
              url.host == "checkin",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let courtIDString = components.queryItems?.first(where: { $0.name == "court" })?.value,
              let courtID = UUID(uuidString: courtIDString) else {
            errorMessage = "Invalid QR code"
            return
        }
        
        if let court = courts.first(where: { $0.id == courtID }) {
            selectedCourt = court
            showStatusPicker = true
        } else {
            errorMessage = "Court not found"
        }
    }
    
    private func performCheckIn(court: Court) {
        let checkIn = CheckIn(
            userID: currentUserID,
            courtID: court.id,
            status: checkInStatus,
            partySize: partySize,
            method: .qr
        )
        
        modelContext.insert(checkIn)
        
        do {
            try modelContext.save()
            showStatusPicker = false
            selectedCourt = nil
        } catch {
            errorMessage = "Failed to check in: \(error.localizedDescription)"
        }
    }
}

// MARK: - Nearby Court Row

struct NearbyCourtRow: View {
    let court: Court
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "basketball")
                        .foregroundStyle(.orange)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(court.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    HStack {
                        Text(court.isIndoor ? "Indoor" : "Outdoor")
                        Text("•")
                        Text("\(court.activeCheckInsCount) here")
                        Text("•")
                        Text("0.5 mi") // Placeholder distance
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - QR Scanner View

struct QRScannerView: View {
    @Environment(\.dismiss) private var dismiss
    let onScan: (String) -> Void
    
    @State private var isScanning = true
    
    var body: some View {
        NavigationStack {
            VStack {
                if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                    DataScanner(isScanning: $isScanning) { result in
                        onScan(result)
                        dismiss()
                    }
                } else {
                    ContentUnavailableView(
                        "Scanner Not Available",
                        systemImage: "qrcode.viewfinder",
                        description: Text("QR code scanning is not available on this device")
                    )
                }
            }
            .navigationTitle("Scan QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Data Scanner Wrapper

struct DataScanner: UIViewControllerRepresentable {
    @Binding var isScanning: Bool
    let onScan: (String) -> Void
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [VNBarcodeSymbology.qr])],
            qualityLevel: .balanced,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        if isScanning {
            try? uiViewController.startScanning()
        } else {
            uiViewController.stopScanning()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onScan: (String) -> Void
        
        init(onScan: @escaping (String) -> Void) {
            self.onScan = onScan
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .barcode(let barcode):
                if let payloadString = barcode.payloadStringValue {
                    onScan(payloadString)
                }
            default:
                break
            }
        }
    }
}

// MARK: - Check-In Confirmation

struct CheckInConfirmationView: View {
    let court: Court
    @Binding var status: CheckInStatus
    @Binding var partySize: Int
    let onConfirm: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Court") {
                    Text(court.name)
                        .font(.headline)
                }
                
                Section("Your Status") {
                    Picker("Status", selection: $status) {
                        Text("Playing").tag(CheckInStatus.playing)
                        Text("Waiting / Next").tag(CheckInStatus.waiting)
                        Text("Watching").tag(CheckInStatus.watching)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Party Size") {
                    Stepper("\(partySize) \(partySize == 1 ? "person" : "people")", value: $partySize, in: 1...10)
                }
                
                Section {
                    Button {
                        onConfirm()
                    } label: {
                        Text("Check In")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                    }
                    .listRowBackground(Color.orange)
                }
            }
            .navigationTitle("Confirm Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    CheckInView()
        .modelContainer(for: [Court.self, CheckIn.self], inMemory: true)
}
