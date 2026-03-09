import SwiftUI

// MARK: - Animation Dispatcher
struct SectionAnimationView: View {
    let title: String
    let accentColor: Color

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [accentColor.opacity(0.22), Color.black.opacity(0.6)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            dispatchedView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder private var dispatchedView: some View {
        switch title {
        case "Solar System":             SolarSystemAnim()
        case "Moons":                    MoonAnim()
        case "Satellites":               SatelliteAnim()
        case "Comets":                   CometAnim()
        case "Black Holes":              BlackHoleAnim()
        case "Wormholes":                WormholeAnim()
        case "Constellations":           ConstellationAnim()
        case "Dimensions":               DimensionsAnim()
        case "Time Delay":               TimeDelayAnim()
        case "Gravitational Time Delay": GravTimeAnim()
        case "Stellar Travel":           StellarTravelAnim()
        case "Cryogenic Sleep":          CryogenicAnim()
        case "Eclipses":                 EclipseAnim()
        case "Tidal Wave":               TidalWaveAnim()
        case "Gravity":                  GravityAnim()
        case "Solar Flares":             SolarFlareAnim()
        case "Hyperloop":                HyperloopAnim()
        case "Space Telescopes":         TelescopeAnim()
        case "Space Stations":           SpaceStationAnim()
        case "Rocket":                   RocketAnim()
        default:                         DefaultSpaceAnim()
        }
    }
}
