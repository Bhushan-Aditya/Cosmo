import SwiftUI
import SceneKit

struct NeoView: View {
    var body: some View {
        ZStack {
            CosmoAnimatedBackground()

            VStack(alignment: .leading, spacing: 24) {
                header

                NeoModelCard()
                    .frame(maxWidth: .infinity, maxHeight: 340)

                Text("Drag to rotate • Pinch to zoom")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Meet Morphy")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            Text("Your shadow companion")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(18)
        .cosmoCard(cornerRadius: 24)
    }
}

private struct NeoModelCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.black.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.6), radius: 30, x: 0, y: 20)

            MorphySceneView()
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .padding(6)
        }
        .frame(height: 260)
    }
}

// MARK: - SceneKit-based Morphy view

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
                // User has moved the camera; schedule/reset auto-return.
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

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

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

        // Load FINISHEDWORK.usdc from bundle (with simple fallback).
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

        // Center and scale model to a comfortable size.
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
        // Place Morphy slightly higher so he appears vertically centered in the box.
        modelNode.position = SCNVector3(-center.x, -center.y * 0.6, -center.z)

        scene.rootNode.addChildNode(modelNode)

        // Camera slightly above and in front, looking at Morphy.
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 40
        cameraNode.position = SCNVector3(0, 0.9, 6)
        cameraNode.look(at: SCNVector3(0, 0.4, 0))
        scene.rootNode.addChildNode(cameraNode)

        // Remember base transform for auto-reset.
        context.coordinator.originalCameraTransform = cameraNode.transform

        // Key light - warm spotlight from above-front.
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

        // Soft fill and rim lights.
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

// Helper to compare camera transforms with tolerance.
private func SCNMatrix4AlmostEqual(_ a: SCNMatrix4, _ b: SCNMatrix4, eps: Float = 0.0005) -> Bool {
    let deltas: [Float] = [
        a.m11 - b.m11, a.m12 - b.m12, a.m13 - b.m13, a.m14 - b.m14,
        a.m21 - b.m21, a.m22 - b.m22, a.m23 - b.m23, a.m24 - b.m24,
        a.m31 - b.m31, a.m32 - b.m32, a.m33 - b.m33, a.m34 - b.m34,
        a.m41 - b.m41, a.m42 - b.m42, a.m43 - b.m43, a.m44 - b.m44
    ]
    return deltas.allSatisfy { abs($0) < eps }
}

// Basic body/eye materials approximating the reference look.
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

