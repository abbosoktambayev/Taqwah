import SwiftUI
import CoreHaptics
import OSLog

private let splashLogger = Logger(subsystem: "Taqwah", category: "Splash")

struct SplashView: View {
    @State private var isActive = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    @State private var engine: CHHapticEngine?
    @Environment(\.colorScheme) private var scheme

    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            splashContent
        }
    }
    
    private var splashContent: some View {
        ZStack {
            AppBackground()
                .foregroundColor(.primary)
            VStack(spacing: 28) {
                Image("SplashLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .scaleEffect(scale)
                    .shadow(color: .accentShadow(scheme), radius: 16, y: 8)
                
                Text("Taqwah")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.prayerAccent)
                
                Text("Y o u r   G u i d i n g   L i g h t")
                    .font(.title3)
                    .foregroundColor(.secondaryText(scheme))
            }
            .opacity(opacity)
        }
        .onAppear {
            prepareHaptics()
            startSplashAnimation()
        }
    }
}

extension SplashView {
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            let engine = try CHHapticEngine()
            self.engine = engine

            // Restart handler to recover after interruptions
            engine.resetHandler = { [weak engine] in
                do {
                    try engine?.start()
                } catch {
                    splashLogger.error("Haptic engine failed to restart: \(error.localizedDescription, privacy: .public)")
                }
            }

            engine.stoppedHandler = { reason in
                splashLogger.debug("Haptic engine stopped: \(String(describing: reason), privacy: .public)")
            }

            try engine.start()
        } catch {
            splashLogger.error("Haptic engine start error: \(error.localizedDescription, privacy: .public)")
            self.engine = nil
        }
    }
    
    private func startSplashAnimation() {
        playWaveHaptic()
        
        withAnimation(.easeIn(duration: 1.8)) {
            opacity = 1.0
            scale = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeOut(duration: 0.3)) {
                isActive = true
            }
        }
    }
    
    private func playWaveHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = engine else { return }
        
        var events = [CHHapticEvent]()
        
        for i in 0..<35 {
            let time = Double(i) * 0.04
            let intensity = Float(0.25 + Double(i) * 0.016)
            let sharpness = Float(0.3)
            
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: time
            )
            events.append(event)
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            splashLogger.error("Haptic playback error: \(error.localizedDescription, privacy: .public)")
        }
    }
}
