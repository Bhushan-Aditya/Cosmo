import SwiftUI
import SceneKit

// MARK: - Neo Space Fact Model
struct NeoFact: Identifiable {
    var id: String { title }
    let icon: String
    let title: String
    let body: String
    let accentColor: Color
}

// MARK: - Neo View (Redesigned)
struct NeoView: View {
    @State private var scrollOffset: CGFloat = 0

    private let facts: [NeoFact] = [
        NeoFact(icon: "light.max", title: "Speed of Light",
                body: "Light travels 299,792 km every second. It takes just 8 minutes 20 seconds to reach Earth from the Sun.",
                accentColor: .yellow),
        NeoFact(icon: "clock.arrow.circlepath", title: "Time Dilation",
                body: "Astronauts on the ISS age slightly slower due to speed and gravity. After 6 months they're ~0.007 seconds younger.",
                accentColor: .cyan),
        NeoFact(icon: "circle.fill", title: "Black Hole Mass",
                body: "Sagittarius A*, the black hole at our galaxy's centre, is 4 million times more massive than our Sun.",
                accentColor: .purple),
        NeoFact(icon: "star.fill", title: "Neutron Stars",
                body: "A teaspoon of neutron star material would weigh about 10 million tonnes. They spin up to 700 times per second.",
                accentColor: .blue),
        NeoFact(icon: "moon.stars.fill", title: "Moon's Distance",
                body: "385,000 km away on average. If you drove at 100 km/h non-stop, it'd take ~160 days to reach the Moon.",
                accentColor: .gray),
        NeoFact(icon: "globe.americas.fill", title: "ISS Speed",
                body: "The International Space Station travels at ~28,000 km/h — orbiting Earth once every 90 minutes.",
                accentColor: .orange),
        NeoFact(icon: "sparkles", title: "Observable Universe",
                body: "The observable universe spans ~93 billion light-years in diameter, containing over 2 trillion galaxies.",
                accentColor: .mint),
        NeoFact(icon: "atom", title: "Dark Matter",
                body: "About 27% of the universe is dark matter. It doesn't emit light but shapes the large-scale structure of the cosmos.",
                accentColor: .indigo),
        NeoFact(icon: "waveform.path", title: "Gravitational Waves",
                body: "When two black holes merge, they create ripples in spacetime that stretch space itself — detected by LIGO in 2015.",
                accentColor: .green),
        NeoFact(icon: "thermometer.sun.fill", title: "Sun's Core",
                body: "The Sun's core reaches 15 million °C. Energy produced there takes ~100,000 years to reach the surface.",
                accentColor: .red),
    ]

    var body: some View {
        ZStack {
            CosmoAnimatedBackground()
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // MARK: Header
                    HStack(alignment: .center) {
                        HStack(spacing: 10) {
                            Text("🙂")
                                .font(.system(size: 28))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Meet Neo")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Your Space Companion")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.55))
                            }
                        }
                        Spacer()
                        // 3D badge
                        HStack(spacing: 4) {
                            Image(systemName: "cube.transparent")
                                .font(.system(size: 11, weight: .semibold))
                            Text("3D")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(Color(red: 0.95, green: 0.82, blue: 0.45))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.95, green: 0.82, blue: 0.45).opacity(0.15))
                                .overlay(
                                    Capsule()
                                        .stroke(Color(red: 0.95, green: 0.82, blue: 0.45).opacity(0.4), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 18)

                    // MARK: 3D Model Card
                    NeoModelCard()
                        .padding(.horizontal, 16)

                    // Drag hint
                    Text("Drag to rotate  ·  Pinch to zoom")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.45))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)
                        .padding(.bottom, 22)

                    // MARK: Who is Neo?
                    VStack(alignment: .center, spacing: 12) {
                        HStack(spacing: 8) {
                            Text("🙂")
                                .font(.system(size: 22))
                            Text("Who is Neo?")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Text("""
                        Born the moment the first photon of the Big Bang touched matter, Neo is your eternal companion on this cosmic journey. Curious, witty, and full of wonder — he's been drifting through galaxies, black holes, and nebulae, collecting the most mind-bending facts in the universe.

                        As a space enthusiast who has "seen" everything from the first stars forming to the collision of galaxy clusters, Neo loves nothing more than sharing the universe's greatest secrets with explorers like you.
                        """)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.72))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.black.opacity(0.30))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 16)

                    // MARK: Space Facts Header
                    HStack {
                        Text("⚡️ Neo's Space Facts")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(facts.count) facts")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 22)
                    .padding(.bottom, 12)

                    // MARK: Facts Horizontal Scroll
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(facts) { fact in
                                NeoFactCard(fact: fact)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                    }

                    // MARK: Cosmic Stats Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🌌 Quick Cosmic Stats")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)

                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10)
                        ], spacing: 10) {
                            CosmicStatBubble(value: "13.8B", label: "Years since Big Bang", color: .purple)
                            CosmicStatBubble(value: "2T+", label: "Galaxies in universe", color: .blue)
                            CosmicStatBubble(value: "8 min", label: "Light travel: Sun → Earth", color: .yellow)
                            CosmicStatBubble(value: "4,000+", label: "Exoplanets discovered", color: .green)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 8)

                    Spacer(minLength: 100)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - 3D Model Card
private struct NeoModelCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(red: 0.06, green: 0.06, blue: 0.09))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.6), radius: 30, x: 0, y: 16)

            MorphySceneView()
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(4)
        }
        .frame(height: 280)
    }
}

// MARK: - Neo Fact Card
private struct NeoFactCard: View {
    let fact: NeoFact

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Circle()
                    .fill(fact.accentColor.opacity(0.18))
                    .frame(width: 42, height: 42)
                Image(systemName: fact.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(fact.accentColor)
            }

            Text(fact.title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)

            Text(fact.body)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.65))
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(width: 180, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.black.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(fact.accentColor.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: fact.accentColor.opacity(0.12), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Cosmic Stat Bubble
private struct CosmicStatBubble: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.6))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(color.opacity(0.28), lineWidth: 1)
                )
        )
    }
}

// MARK: - SceneKit-based Morphy view (unchanged)
private struct MorphySceneView: UIViewRepresentable {
    class Coordinator: NSObject, SCNSceneRendererDelegate {
        var originalCameraTransform: SCNMatrix4?
        var resetWorkItem: DispatchWorkItem?
        weak var view: SCNView?

        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            guard let cameraNode = renderer.pointOfView,
                  let base = originalCameraTransform else { return }

            let current = cameraNode.transform
            if !SCNMatrix4AlmostEqual(current, base) {
                resetWorkItem?.cancel()

                let work = DispatchWorkItem { [weak self] in
                    guard let camera = self?.view?.pointOfView,
                          let baseTransform = self?.originalCameraTransform else { return }
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0.5
                    SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    camera.transform = baseTransform
                    SCNTransaction.commit()
                }

                resetWorkItem = work
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: work)
            }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = false
        scnView.antialiasingMode = .multisampling4X
        scnView.delegate = context.coordinator
        context.coordinator.view = scnView

        let scene = SCNScene()
        scnView.scene = scene

        let modelNode: SCNNode
        if let url = Bundle.main.url(forResource: "FINISHEDWORK", withExtension: "usdc"),
           let loadedScene = try? SCNScene(url: url, options: [.checkConsistency: true, .convertToYUp: true]) {
            let container = SCNNode()
            for child in loadedScene.rootNode.childNodes {
                container.addChildNode(child)
            }
            modelNode = container
        } else {
            let sphere = SCNSphere(radius: 1.0)
            sphere.firstMaterial?.diffuse.contents = UIColor(white: 0.1, alpha: 1.0)
            modelNode = SCNNode(geometry: sphere)
        }

        applyMorphyMaterials(to: modelNode)

        let (min, max) = modelNode.boundingBox
        let size = SCNVector3(max.x - min.x, max.y - min.y, max.z - min.z)
        let maxDim = Swift.max(size.x, Swift.max(size.y, size.z))
        let target: Float = 2.8
        let scale = target / maxDim
        modelNode.scale = SCNVector3(scale, scale, scale)

        let center = SCNVector3(
            (min.x + max.x) / 2 * scale,
            (min.y + max.y) / 2 * scale,
            (min.z + max.z) / 2 * scale
        )
        modelNode.position = SCNVector3(-center.x, -center.y * 0.6, -center.z)
        scene.rootNode.addChildNode(modelNode)

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 40
        cameraNode.position = SCNVector3(0, 0.9, 6)
        cameraNode.look(at: SCNVector3(0, 0.4, 0))
        scene.rootNode.addChildNode(cameraNode)
        context.coordinator.originalCameraTransform = cameraNode.transform

        let keyLight = SCNNode()
        keyLight.light = SCNLight()
        keyLight.light?.type = .spot
        keyLight.light?.color = UIColor(red: 1.0, green: 0.96, blue: 0.88, alpha: 1.0)
        keyLight.light?.intensity = 1200
        keyLight.light?.spotInnerAngle = 25
        keyLight.light?.spotOuterAngle = 60
        keyLight.light?.castsShadow = true
        keyLight.light?.shadowRadius = 4
        keyLight.light?.shadowColor = UIColor.black.withAlphaComponent(0.6)
        keyLight.position = SCNVector3(0, 6, 3)
        keyLight.look(at: SCNVector3(0, 0.6, 0))
        scene.rootNode.addChildNode(keyLight)

        let fillLight = SCNNode()
        fillLight.light = SCNLight()
        fillLight.light?.type = .omni
        fillLight.light?.color = UIColor(red: 0.7, green: 0.75, blue: 0.9, alpha: 1.0)
        fillLight.light?.intensity = 230
        fillLight.position = SCNVector3(-4, 2, 3)
        scene.rootNode.addChildNode(fillLight)

        let rimLight = SCNNode()
        rimLight.light = SCNLight()
        rimLight.light?.type = .omni
        rimLight.light?.color = UIColor(red: 1.0, green: 0.85, blue: 0.65, alpha: 1.0)
        rimLight.light?.intensity = 320
        rimLight.position = SCNVector3(3, 4, -3)
        scene.rootNode.addChildNode(rimLight)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.color = UIColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)
        ambient.light?.intensity = 180
        scene.rootNode.addChildNode(ambient)

        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}
}

private func SCNMatrix4AlmostEqual(_ a: SCNMatrix4, _ b: SCNMatrix4, eps: Float = 0.0005) -> Bool {
    let deltas: [Float] = [
        a.m11 - b.m11, a.m12 - b.m12, a.m13 - b.m13, a.m14 - b.m14,
        a.m21 - b.m21, a.m22 - b.m22, a.m23 - b.m23, a.m24 - b.m24,
        a.m31 - b.m31, a.m32 - b.m32, a.m33 - b.m33, a.m34 - b.m34,
        a.m41 - b.m41, a.m42 - b.m42, a.m43 - b.m43, a.m44 - b.m44
    ]
    return deltas.allSatisfy { abs($0) < eps }
}

private func applyMorphyMaterials(to node: SCNNode) {
    let lowerName = (node.name ?? "").lowercased()
    let isEye = lowerName.contains("eye")

    if let geometry = node.geometry {
        if isEye {
            let eye = SCNMaterial()
            eye.diffuse.contents = UIColor.white
            eye.emission.contents = UIColor.white
            eye.lightingModel = .constant
            geometry.materials = [eye]
        } else {
            let body = SCNMaterial()
            body.diffuse.contents = UIColor(red: 0.06, green: 0.06, blue: 0.08, alpha: 1.0)
            body.specular.contents = UIColor(red: 0.4, green: 0.38, blue: 0.45, alpha: 1.0)
            body.shininess = 0.4
            body.lightingModel = .physicallyBased
            body.roughness.contents = 0.55
            body.metalness.contents = 0.15
            geometry.materials = [body]
        }
    }

    for child in node.childNodes {
        applyMorphyMaterials(to: child)
    }
}
