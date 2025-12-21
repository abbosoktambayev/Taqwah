import SwiftUI
import CoreHaptics

struct SplashView: View {
    @State private var isActive = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    
    // Движок для вибрации
    @State private var engine: CHHapticEngine?
    @Environment(\.colorScheme) private var scheme

    
    var body: some View {
        if isActive {
            ContentView()  // ← Здесь твой главный экран (замени если нужно)
        } else {
            splashContent
        }
    }
    
    private var splashContent: some View {
        ZStack {
            AppBackground()
                .foregroundColor(.primary)
            VStack(spacing: 28) {
                Image("SplashLogo")  // ← Твой логотип из Assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .scaleEffect(scale)
                    .shadow(color: .yellow.opacity(0.4), radius: 30, y: 15)
                
                Text("Taqwah")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.yellow.opacity(0.95))
                
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
                    print("Haptic engine failed to restart: \(error.localizedDescription)")
                }
            }

            engine.stoppedHandler = { reason in
                // You can inspect reason if needed; keeping for debugging
                 print("Haptic engine stopped: \(reason)")
            }

            try engine.start()
        } catch {
            print("Haptic engine Creation/Start Error: \(error.localizedDescription)")
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
        
        // Максимально плотная и длинная нежная волна — 28 импульсов
        for i in 0..<35 {
            let time = Double(i) * 0.04
            // Самый плотный интервал — волна почти сплошная
            let intensity = Float(0.25 + Double(i) * 0.016)  // От 0.25 до ~0.7 — очень медленно и нежно нарастает
            let sharpness = Float(0.3)  // Максимально мягкая резкость — как шёпот
            
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
            print("Vibration playback error: \(error.localizedDescription)")
        }
    }
}

