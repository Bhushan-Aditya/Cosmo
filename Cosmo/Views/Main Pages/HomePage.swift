import SwiftUI

struct MenuSection: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color
}

class CardState: ObservableObject {
    @Published var offset: CGFloat
    @Published var opacity: Double
    @Published var isPressed: Bool
    
    init(offset: CGFloat = 0, opacity: Double = 1, isPressed: Bool = false) {
        self.offset = offset
        self.opacity = opacity
        self.isPressed = isPressed
    }
}

struct StarfieldBackground: View {
    let starCount = 100
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<starCount, id: \.self) { _ in
                Circle()
                    .fill(Color.white)
                    .frame(width: 2, height: 2)
                    .position(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height)
                    )
                    .opacity(Double.random(in: 0.2...0.7))
                    .animation(
                        Animation
                            .easeInOut(duration: Double.random(in: 1.0...3.0))
                            .repeatForever(autoreverses: true),
                        value: UUID()
                    )
            }
        }
    }
}

struct HomePage: View {
    @Binding var currentPage: AppPage
    @State private var selectedCard: String?
    @State private var cardStates: [String: CardState] = [:]
    @State private var headerOffset: CGFloat = -50
    @State private var headerOpacity: Double = 0
    @State private var showingWelcomeAnimation = false
    @State private var rotationAngle: Double = 0
    @State private var pulseSize: CGFloat = 1.0
    
    private let gradientColors: [Color] = [
        Color(red: 0.1, green: 0.2, blue: 0.45),
        Color(red: 0.15, green: 0.1, blue: 0.3),
        Color(red: 0.1, green: 0.1, blue: 0.2)
    ]
    
    private let sections = [
        MenuSection(
            id: "explore",
            title: "Explore",
            subtitle: "Journey through cosmic time",
            description: "From the Big Bang to the future of our universe",
            icon: "globe.stars.fill",
            color: Color(red: 0.4, green: 0.8, blue: 1.0)
        ),
        MenuSection(
            id: "theories",
            title: "Theories",
            subtitle: "Understanding the cosmos",
            description: "Discover groundbreaking space theories",
            icon: "atom",
            color: Color(red: 1.0, green: 0.5, blue: 0.3)
        ),
        MenuSection(
            id: "quiz",
            title: "Quiz",
            subtitle: "Test your knowledge",
            description: "Challenge yourself with cosmic questions",
            icon: "star.circle.fill",
            color: Color(red: 0.8, green: 0.4, blue: 1.0)
        )
    ]
    
    var body: some View {
        ZStack {
            backgroundLayer
            
            ScrollView {
                VStack(spacing: 35) {
                    welcomeHeader
                    menuCards
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
        }
        .onAppear {
            animateEntrance()
        }
    }
    
    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            StarfieldBackground()
                .opacity(0.7)
            
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.2),
                    Color.purple.opacity(0.15),
                    Color.clear
                ]),
                center: .top,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            Color.white
                .opacity(0.02)
                .ignoresSafeArea()
        }
    }
    
    private var welcomeHeader: some View {
        VStack(spacing: 30) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.3),
                                Color.purple.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .scaleEffect(pulseSize)
                
                Image(systemName: "sparkles.star.fill")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .blue.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .rotationEffect(.degrees(rotationAngle))
                    .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 0)
            }
            
            VStack(spacing: 12) {
                Text("Welcome, Explorer")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                
                Text("Choose your cosmic path")
                    .font(.title3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white.opacity(0.7), .white.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        }
        .offset(y: headerOffset)
        .opacity(headerOpacity)
        .padding(.vertical, 20)
    }
    
    private var menuCards: some View {
        VStack(spacing: 25) {
            ForEach(sections) { section in
                EnhancedMenuCard(
                    section: section,
                    isSelected: selectedCard == section.id,
                    cardState: cardStates[section.id, default: CardState()]
                ) {
                    handleCardTap(section)
                }
            }
        }
        .padding(.bottom, 30)
    }
    
    private func animateEntrance() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
            headerOffset = 0
            headerOpacity = 1
            showingWelcomeAnimation = true
        }
        
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            pulseSize = 1.2
        }
        
        sections.enumerated().forEach { index, section in
            cardStates[section.id] = CardState(offset: 100, opacity: 0)
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)
                .delay(0.5 + Double(index) * 0.1)) {
                    cardStates[section.id]?.offset = 0
                    cardStates[section.id]?.opacity = 1
                }
        }
    }
    
    private func handleCardTap(_ section: MenuSection) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            selectedCard = section.id
            cardStates[section.id]?.isPressed = true
            
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                cardStates[section.id]?.isPressed = false
                
                withAnimation {
                    switch section.id {
                    case "explore": currentPage = .explore
                    case "theories": currentPage = .theories
                    case "quiz": currentPage = .quiz
                    default: break
                    }
                }
            }
        }
    }
}

struct EnhancedMenuCard: View {
    let section: MenuSection
    let isSelected: Bool
    let cardState: CardState
    let action: () -> Void
    
    @State private var isHovered = false
    @State private var isPressed = false
    @State private var animateGradient = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                enhancedIcon
                enhancedContent
                Spacer()
                enhancedChevron
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 22)
            .background(enhancedBackground)
        }
        .buttonStyle(PlainButtonStyle())
        .offset(y: cardState.offset)
        .opacity(cardState.opacity)
        .scaleEffect(isPressed ? 0.98 : isHovered ? 1.02 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    private var enhancedIcon: some View {
        ZStack {
            Circle()
                .fill(section.color.opacity(0.2))
                .frame(width: 56, height: 56)
                .blur(radius: isHovered ? 10 : 5)
            
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            section.color.opacity(0.3),
                            section.color.opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .stroke(
                            section.color.opacity(isHovered ? 0.4 : 0.2),
                            lineWidth: 1
                        )
                )
            
            Image(systemName: section.icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, section.color],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .rotationEffect(.degrees(isHovered ? 360 : 0))
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isHovered)
        }
    }
    
    private var enhancedContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(section.title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.9)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            Text(section.subtitle)
                .font(.subheadline)
                .foregroundStyle(
                    LinearGradient(
                        colors: [section.color, section.color.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            Text(section.description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(2)
                .padding(.top, 2)
        }
    }
    
    private var enhancedChevron: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(
                LinearGradient(
                    colors: [section.color, section.color.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .rotationEffect(.degrees(isHovered ? 90 : 0))
            .opacity(0.8)
            .padding(.leading, 10)
    }
    
    private var enhancedBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.07))
            
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            section.color.opacity(isHovered ? 0.15 : 0.1),
                            section.color.opacity(isHovered ? 0.05 : 0.02)
                        ],
                        startPoint: animateGradient ? .topLeading : .bottomLeading,
                        endPoint: animateGradient ? .bottomTrailing : .topTrailing
                    )
                )
            
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [
                            section.color.opacity(isHovered ? 0.5 : 0.2),
                            section.color.opacity(isHovered ? 0.3 : 0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isHovered ? 1.5 : 1
                )
        }
        .shadow(
            color: section.color.opacity(isHovered ? 0.3 : 0.1),
            radius: isHovered ? 20 : 10,
            x: 0,
            y: isHovered ? 10 : 5
        )
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage(currentPage: .constant(.home))
    }
}
