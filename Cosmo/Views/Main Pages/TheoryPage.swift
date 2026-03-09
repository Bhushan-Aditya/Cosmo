import SwiftUI

struct TheoryTypeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))

                Text(title)
                    .font(.footnote.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .allowsTightening(true)
            }
            .frame(maxWidth: .infinity, minHeight: 68)
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(isSelected ? Color.blue.opacity(0.8) : Color.clear)
            .foregroundColor(.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.blue.opacity(isSelected ? 1 : 0), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CategoryButton: View {
    let category: TheoryCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 5) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .gray)
                Text(category.rawValue)
                    .font(.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .allowsTightening(true)
                    .foregroundColor(isSelected ? .white : .gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
            .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TheoryTypeIndicator: View {
    let type: TheoryType

    var body: some View {
        HStack {
            if type == .verified {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                Text("Verified")
                    .font(.caption2)
                    .foregroundColor(.green)
            } else if type == .community {
                Image(systemName: "person.3.fill")
                    .foregroundColor(.blue)
                Text("Community")
                    .font(.caption2)
                    .foregroundColor(.blue)
            } else if type == .hypothesis {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(.yellow)
                Text("Hypothesis")
                    .font(.caption2)
                    .foregroundColor(.yellow)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.08))
        .cornerRadius(8)
    }
}

struct CommunityMetricsView: View { // Static placeholder for offline
    let metrics: CommunityMetrics

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "arrow.up.heart.fill")
                .foregroundColor(.white)
            Text("\(metrics.upvotes)")
                .font(.caption)
                .foregroundColor(.white)
            Image(systemName: "text.bubble.fill")
                .foregroundColor(.white)
            Text("\(metrics.comments.count)")
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.08))
        .cornerRadius(8)
    }
}

struct CategoryTag: View {
    let category: TheoryCategory

    var body: some View {
        Text(category.rawValue)
            .font(.caption.bold())
            .foregroundColor(.blue)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
    }
}


// MARK: - Main Theory Models
struct Theory: Identifiable {
    let id = UUID()
    var title: String
    var category: TheoryCategory
    var scientist: String
    let year: String
    var shortDescription: String
    var fullDescription: String
    let citations: [String]
    let icon: String
    let color: Color
    let type: TheoryType
    var communityMetrics: CommunityMetrics?
}

struct CommunityMetrics: Identifiable{
    let id = UUID() // Added Identifiable conformance and ID for CommunityMetrics
    var upvotes: Int
    var downvotes: Int
    var comments: [TheoryComment]
    var datePosted: Date
    var authorName: String
    var authorCredentials: String?
}

struct TheoryComment: Identifiable {
    let id = UUID()
    let authorName: String
    let content: String
    let timestamp: Date
    var replies: [TheoryComment]
    var likes: Int
}

enum TheoryType {
    case verified
    case community
    case hypothesis
    case all // Added 'all' case if you intend to filter by all theory types
}

enum TheoryCategory: String, CaseIterable, Identifiable { // Conform to Identifiable
    var id: Self { self } // Conformance to Identifiable - id is the enum case itself

    case all = "All"
    case universe = "Universe"
    case blackHoles = "Black Holes"
    case quantum = "Quantum"
    case relativity = "Relativity"
    case cosmology = "Cosmology"
    case astrobiology = "Astrobiology"
    case particlePhysics = "Particle Physics"
    case spaceTime = "Space-Time"
    case darkMatter = "Dark Matter"
    //Removed case community = "Community" - if this was typo causing issue. If category 'Community' was intended, reinstate it.

    var icon: String {
        switch self {
        case .all: return "star.circle.fill"
        case .universe: return "globe.americas.fill"
        case .blackHoles: return "circle.fill"
        case .quantum: return "atom"
        case .relativity: return "clock.fill"
        case .cosmology: return "sparkles"
        case .astrobiology: return "leaf.fill"
        case .particlePhysics: return "particles"
        case .spaceTime: return "timer"
        case .darkMatter: return "cloud.fill"
        }
    }

    var description: String {
        switch self {
        case .all: return "All theories across categories"
        case .universe: return "Theories about universal structure and evolution"
        case .blackHoles: return "Black hole formation and behavior"
        case .quantum: return "Quantum mechanics and phenomena"
        case .relativity: return "Special and general relativity"
        case .cosmology: return "Origin and evolution of the cosmos"
        case .astrobiology: return "Life in the universe"
        case .particlePhysics: return "Fundamental particles and forces"
        case .spaceTime: return "Nature of space and time"
        case .darkMatter: return "Dark matter and dark energy"
        }
    }
}

// MARK: - Main Theory View
struct TheoryExplorerView: View {
    @State private var selectedTheoryType: TheoryType = .verified //Default to verified.
    @State private var selectedTheory: Theory? = nil
    @State private var showTheoryDetail = false
    @State private var animateCards = false
    @State private var showAddTheory = false
    @State private var scrollOffset: CGFloat = 0
    @State private var parallaxOffset: CGFloat = 0
    @State private var starfieldRotation: Double = 0
    @State private var zoomLevel: Double = 1.0

    private let theories: [Theory] = TheoryDatabase.allTheories

    init() { // Added initializer to print count on view initialization - for debugging
        print("Total theories loaded: \(theories.count)")
    }

    private func startCosmicAnimations() {
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            starfieldRotation = 360
        }
    }


    var filteredTheories: [Theory] {
        theories.filter { theory in
            let typeMatch = selectedTheoryType == .all || theory.type == selectedTheoryType // Now using .all for TheoryType filtering too if you need it in future
            if selectedTheoryType == .community && theory.type != .community { // For Offline, only show Community if type filter is Community.
                return false
            }
            return typeMatch
        }
    }

    var body: some View {
        ZStack {
            EnhancedCosmicBackground(
                parallaxOffset: parallaxOffset,
                starfieldRotation: starfieldRotation,
                zoomLevel: zoomLevel
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                headerSection
                theorySelectorSection
                    .padding(.horizontal)
                theoriesGrid
            }
        }
        .onAppear {
            startCosmicAnimations()
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showTheoryDetail) {
            if let theory = selectedTheory {
                TheoryDetailModal(theory: theory, isShowing: $showTheoryDetail)
            }
        }
        .sheet(isPresented: $showAddTheory) {
            TheoryExplorerView.AddTheoryModal(isShowing: $showAddTheory)
        }
    }

    // MARK: - View Components
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Icon + Title row
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: "atom")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, Color.cyan.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text("Theory Explorer")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                if selectedTheoryType == .community {
                    Button(action: { showAddTheory = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.blue)
                    }
                }
            }

            // Subtitle
            Text(headerDescription)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.55))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 4)
    }

    private var theorySelectorSection: some View { // Theory type selector boxed
        HStack(spacing: 16) {
            TheoryTypeButton(
                title: "Verified Theories",
                icon: "checkmark.seal.fill",
                isSelected: selectedTheoryType == .verified
            ) {
                withAnimation(.spring()) {
                    selectedTheoryType = .verified
                }
            }

            TheoryTypeButton(
                title: "Community Theories",
                icon: "person.3.fill",
                isSelected: selectedTheoryType == .community
            ) {
                withAnimation(.spring()) {
                    selectedTheoryType = .community
                }
            }

            TheoryTypeButton(
                title: "Hypotheses",
                icon: "questionmark.circle.fill",
                isSelected: selectedTheoryType == .hypothesis
            ) {
                withAnimation(.spring()) {
                    selectedTheoryType = .hypothesis
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
        )
    }

    // Category + search sections removed (per request).

    private var theoriesGrid: some View { // Theories Grid
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20)
                ],
                spacing: 20
            ) {
                ForEach(Array(filteredTheories.enumerated()), id: \.element.id) { index, theory in
                    TheoryCard(theory: theory) { // <-- CHECK THIS ACTION CLOSURE AGAIN
                        print("Action from TheoryCard triggered in TheoryExplorerView for: \(theory.title)") // Add print HERE
                        withAnimation {
                            selectedTheory = theory
                            showTheoryDetail = true
                            print("  selectedTheory set to: \(selectedTheory?.title ?? "nil")") // Print selected theory
                            print("  showTheoryDetail set to: \(showTheoryDetail)") // Print showTheoryDetail value
                        }
                    }
                    .offset(y: animateCards ? 0 : 50)
                    .opacity(animateCards ? 1 : 0)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.7)
                        .delay(Double(index) * 0.1),
                        value: animateCards
                    )
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            animateCards = true
        }
    }


    private var headerDescription: String {
        switch selectedTheoryType {
        case .verified:
            return "Explore scientifically verified theories that shape our understanding of the cosmos"
        case .community:
            return "Discover and discuss theories proposed by the space science community (Offline Demo - No Interaction)" // Adjusted Header text for offline demo
        case .hypothesis:
            return "Explore emerging hypotheses and theoretical proposals"
        case .all: return "All theories across types" //Added for completeness if you use .all type in future
        }
    }
}


// MARK: - Supporting Views
extension TheoryExplorerView {
    struct TheoryCard: View {
        let theory: Theory
        let action: () -> Void // This is the action closure
        @State private var isHovered = false

        var body: some View {
            Button(action: {
                print("TheoryCard Tapped for: \(theory.title)") // ADD THIS PRINT STATEMENT
                action() // Call the action passed from TheoryExplorerView
            }) {
                VStack(alignment: .leading, spacing: 15) {
                    // Header
                    HStack {
                        TheoryTypeIndicator(type: theory.type)

                        Spacer()

                        if let metrics = theory.communityMetrics {
                            CommunityMetricsView(metrics: metrics)
                        }
                    }

                    // Content
                    VStack(alignment: .leading, spacing: 12) {
                        Text(theory.title)
                            .font(.title3.bold())
                            .foregroundColor(.white)

                        Text(theory.scientist)
                            .font(.subheadline)
                            .foregroundColor(theory.color)

                        Text(theory.shortDescription)
                            .font(.body)
                            .foregroundColor(.gray)
                            .lineLimit(3)

                        // Tags
                        HStack {
                            CategoryTag(category: theory.category)
                            Text(theory.year)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(theory.color.opacity(isHovered ? 0.5 : 0.2), lineWidth: 1)
                        )
                )
                .shadow(color: theory.color.opacity(isHovered ? 0.3 : 0), radius: 10)
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(isHovered ? 1.02 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
        }
    }
    struct TheoryDetailModal: View {
        let theory: Theory
        @Binding var isShowing: Bool

        var body: some View {
            ZStack {
                // Background
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isShowing = false
                        }
                    }

                VStack(spacing: 25) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(theory.title)
                                .font(.title.bold())
                                .foregroundColor(.white)

                            if let metrics = theory.communityMetrics {
                                HStack {
                                    Text("Posted by \(metrics.authorName)") // Corrected String Interpolation
                                        .font(.body)
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                            }
                            Text(theory.scientist)
                                .font(.subheadline)
                                .foregroundColor(theory.color)
                        }

                        Spacer()

                        Button {
                            withAnimation {
                                isShowing = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(theory.color.opacity(0.15))
                                    .frame(width: 80, height: 80)

                                Image(systemName: theory.icon)
                                    .font(.system(size: 40))
                                    .foregroundColor(theory.color)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)

                            // Full Description
                            Text(theory.fullDescription)
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal)

                            // Citations Section
                            if !theory.citations.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Citations")
                                        .font(.headline)
                                        .foregroundColor(.white)

                                    ForEach(theory.citations, id: \.self) { citation in
                                        Text("- \(citation)") // Corrected String Interpolation
                                            .font(.body)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.horizontal)
                            }

                            // Community Features (if applicable) - now using adjusted CommunityInteractionsSection which will be non-functional
                            if theory.type == .community, let _ = theory.communityMetrics {
                                CommunityInteractionsSection(metrics: theory.communityMetrics ?? CommunityMetrics(upvotes: 0, downvotes: 0, comments: [], datePosted: Date(), authorName: ""))
                             }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color(white: 0.12, opacity: 1))
                )
                .frame(maxWidth: 600)
            }
        }
    }

    // MARK: - Community Features (Adjusted for non-functionality)
    struct CommunityInteractionsSection: View {
        @State var metrics: CommunityMetrics

        var body: some View {
            VStack(spacing: 20) {
                // Upvote/Downvote - buttons are still present, but actions do nothing
                    HStack {
                        Button(action: {
                            // In offline mode, actions do nothing
                            print("Upvote action (offline mode - no action)")
                        }) {
                            Label("\(metrics.upvotes)", systemImage: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                        }

                        Spacer()

                        Button(action: {
                            // In offline mode, actions do nothing
                            print("Downvote action (offline mode - no action)")
                        }) {
                            Label("\(metrics.downvotes)", systemImage: "arrow.down.circle.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                    }


                    CommentsView(comments: metrics.comments)
                        .padding(.top)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(white: 0.1))
                )
            }
        }

        // MARK: - Comments System
        struct CommentsView: View { // CommentsView remains, but comment data will be static from 'metrics'
            let comments: [TheoryComment]

            var body: some View {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Community Comments")
                        .font(.headline.bold())
                        .foregroundColor(.white)

                    ForEach(comments) { comment in
                        CommentView(comment: comment)
                    }
                }
            }
        }

        struct CommentView: View { // CommentView UI remains - but comments data is now static.
            let comment: TheoryComment

            var body: some View {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(comment.authorName)
                            .font(.body.bold())
                            .foregroundColor(.blue)
                        Spacer()
                        Text("\(comment.timestamp, formatter: DateFormatter.commentDateFormatter)") // Corrected String Interpolation
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Text(comment.content)
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)

                    if !comment.replies.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Replies")
                                .font(.caption.bold())
                                .foregroundColor(.gray)

                            ForEach(comment.replies) { reply in
                                CommentView(comment: reply)
                                    .padding(.leading, 20)
                            }
                        }
                    }
                }
                .padding(.bottom)
            }
        }


        // MARK: - Add Theory Modal (Submit action disabled - OFFLINE MODE)
        struct AddTheoryModal: View {
            @Binding var isShowing: Bool

            @State private var newTheoryTitle = ""
            @State private var newTheoryAuthor = ""
            @State private var newTheoryDescription = ""
            @State private var selectedCategory: TheoryCategory = .universe
            @State private var newTheory: Theory?

            var body: some View {
                ZStack {
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                isShowing = false
                            }
                        }
                        .onAppear {
                            newTheory = Theory(
                                title: "",
                                category: .universe,
                                scientist: "",
                                year: "2025",
                                shortDescription: "",
                                fullDescription: "",
                                citations: [],
                                icon: "person.fill",
                                color: .purple,
                                type: .community,
                                communityMetrics: CommunityMetrics(
                                    upvotes: 0,
                                    downvotes: 0,
                                    comments: [],
                                    datePosted: Date(),
                                    authorName: "",
                                    authorCredentials: nil
                                )
                            )
                        }

                    VStack(spacing: 20) {
                        Text("Submit a New Theory (Offline Demo)") // Updated header to indicate offline demo
                            .font(.title.bold())
                            .foregroundColor(.white)

                        ScrollView {
                            VStack(spacing: 15) {
                                TextField("Theory Title", text: $newTheoryTitle)
                                    .modifier(TextFieldModifier())
                                TextField("Author Name (Optional)", text: $newTheoryAuthor)
                                    .modifier(TextFieldModifier())
                                Picker("Category", selection: $selectedCategory) {
                                    ForEach(TheoryCategory.allCases) { category in // No 'id: \.self' here
                                        Text(category.rawValue).tag(category)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .foregroundColor(.white)
                                TextEditor(text: $newTheoryDescription)
                                    .modifier(TextEditorModifier())

                                Button(action: submitTheoryOffline) { // Changed action to offline version
                                    Text("Submit Theory (Simulated)") // Updated button text for offline
                                        .bold()
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                            }
                            .padding()
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(white: 0.12, opacity: 1))
                    )
                    .padding()
                }
            }

            func submitTheoryOffline() { // Offline Submission - no data saving
                print("\n--- OFFLINE MODE: Theory Submission ---")
                print("Theory Title: \(newTheoryTitle)")
                print("Author: \(newTheoryAuthor)")
                print("Category: \(selectedCategory)")
                print("Description: \(newTheoryDescription)")
                print("--- Theory submission simulated (offline) - no data saved. ---\n")

                newTheoryTitle = "" // Clear fields
                newTheoryAuthor = ""
                newTheoryDescription = ""


                withAnimation {
                    isShowing = false
                }
            }
        }

        // MARK: - Modifiers (Reusable UI)
        struct TextFieldModifier: ViewModifier {
            func body(content: Content) -> some View {
                content
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
        }

        struct TextEditorModifier: ViewModifier {
            func body(content: Content) -> some View {
                content // Corrected: now returning content, which is a View
                    .frame(height: 80)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
        }
    }

// MARK: - Helper Date Formatters, TheoryDatabase, etc. (No changes Needed)
extension DateFormatter { // Helper Date Formatters
    static var commentDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}

struct TheoryDatabase { // Theory Database
    static var allTheories: [Theory] {
        // MARK: - Relativity Theories
        let relativityTheories: [Theory] = [
            Theory(
                title: "General Relativity",
                category: .relativity,
                scientist: "Albert Einstein",
                year: "1915",
                shortDescription: "Gravity as a consequence of spacetime curvature",
                fullDescription: """
                    Einstein's theory of general relativity describes gravity as a consequence of spacetime curvature caused by mass and energy. Key principles include:
                    • Gravity is not a force, but a consequence of curved spacetime
                    • Massive objects distort the fabric of spacetime
                    • Light follows curved paths in curved spacetime
                    • Time dilation occurs in strong gravitational fields
                    • The theory predicts black holes and gravitational waves
                    """,
                citations: [
                    "Einstein, A. (1915). 'Die Feldgleichungen der Gravitation'",
                    "Wheeler, J.A. (1973). 'Gravitation'",
                    "Hawking, S. (1988). 'A Brief History of Time'"
                ],
                icon: "clock.fill",
                color: Color(red: 0.4, green: 0.8, blue: 1.0),
                type: .verified
            ),

            Theory(
                title: "Special Relativity",
                category: .relativity,
                scientist: "Albert Einstein",
                year: "1905",
                shortDescription: "The relationship between space and time",
                fullDescription: """
                    Special relativity fundamentally changed our understanding of space and time. Core principles:
                    • The speed of light is constant in all reference frames
                    • Time dilation occurs at high velocities
                    • Mass and energy are equivalent (E = mc²)
                    • No information can travel faster than light
                    • Length contraction occurs at relativistic speeds
                    """,
                citations: [
                    "Einstein, A. (1905). 'Zur Elektrodynamik bewegter Körper'",
                    "Lorentz, H.A. (1904). 'Electromagnetic phenomena'"
                ],
                icon: "bolt.fill",
                color: Color(red: 1.0, green: 0.8, blue: 0.4),
                type: .verified
            ),

            Theory(
                title: "Time Dilation",
                category: .relativity,
                scientist: "Albert Einstein",
                year: "1905",
                shortDescription: "Time passes differently depending on motion and gravity",
                fullDescription: """
                    Time dilation is a difference in elapsed time measured by observers in relative motion or at different gravitational potentials. Effects include:
                    • Moving clocks run slower
                    • Gravitational time dilation near massive objects
                    • The twin paradox
                    • GPS satellites must account for both special and general relativistic time dilation
                    """,
                citations: [
                    "Hafele, J.C. & Keating, R.E. (1972). 'Around-the-World Atomic Clocks'",
                    "Pound, R.V. & Rebka Jr, G.A. (1959). 'Gravitational Red-Shift'"
                ],
                icon: "timer",
                color: Color(red: 0.6, green: 0.4, blue: 0.8),
                type: .verified
            )
        ]

        // MARK: - Quantum Theories
        let quantumTheories: [Theory] = [
            Theory(
                title: "Quantum Mechanics",
                category: .quantum,
                scientist: "Multiple Scientists",
                year: "1900-1927",
                shortDescription: "The behavior of matter and energy at molecular, atomic, nuclear, and smaller scales",
                fullDescription: """
                    Quantum mechanics describes nature at the smallest scales. Key concepts include:
                    • Wave-particle duality
                    • Heisenberg's uncertainty principle
                    • Quantum superposition
                    • Wave function collapse
                    • Quantum entanglement
                    • The Copenhagen interpretation
                    """,
                citations: [
                    "Planck, M. (1900). 'On the Theory of the Energy Distribution Law'",
                    "Bohr, N. (1913). 'On the Constitution of Atoms and Molecules'",
                    "Heisenberg, W. (1927). 'Über den anschaulichen Inhalt'"
                ],
                icon: "atom",
                color: Color(red: 0.8, green: 0.4, blue: 0.6),
                type: .verified
            ),

            Theory(
                title: "Quantum Entanglement",
                category: .quantum,
                scientist: "Einstein, Podolsky, Rosen",
                year: "1935",
                shortDescription: "Quantum states of particles remain connected regardless of distance",
                fullDescription: """
                    Quantum entanglement occurs when particles interact in ways such that their quantum states cannot be described independently. Features include:
                    • 'Spooky action at a distance'
                    • Instantaneous correlation of quantum states
                    • The EPR paradox
                    • Bell's theorem
                    • Applications in quantum computing and cryptography
                    """,
                citations: [
                    "Einstein, A., Podolsky, B., & Rosen, N. (1935). 'Can Quantum-Mechanical Description'",
                    "Bell, J.S. (1964). 'On the Einstein Podolsky Rosen Paradox'"
                ],
                icon: "link.circle",
                color: Color(red: 0.3, green: 0.7, blue: 0.9),
                type: .verified
            )
        ]

        // Continue with more categories...
        // MARK: - Black Hole Theories
        let blackHoleTheories: [Theory] = [
            Theory(
                title: "Black Hole Formation",
                category: .blackHoles,
                scientist: "John Michell (concept), Karl Schwarzschild (math)",
                year: "1783, 1916",
                shortDescription: "Massive stars collapse under gravity to form singularities",
                fullDescription: """
                    Black holes form when massive stars exhaust their nuclear fuel and collapse under their gravitational pull. Key features include:
                    • Schwarzschild radius (event horizon)
                    • Singularity at the center
                    • No radiation escapes beyond the event horizon
                    • Stellar, intermediate, and supermassive black holes
                    • Discovered through X-rays from accretion disks
                    """,
                citations: [
                    "Michell, J. (1783). 'On the Means of Discovering the Distance'",
                    "Schwarzschild, K. (1916). 'Über das Gravitationsfeld'"
                ],
                icon: "circlebadge.fill",
                color: Color(red: 0.5, green: 0.2, blue: 0.8),
                type: .verified
            ),

            Theory(
                title: "Hawking Radiation",
                category: .blackHoles,
                scientist: "Stephen Hawking",
                year: "1974",
                shortDescription: "Black holes emit radiation due to quantum effects near the event horizon",
                fullDescription: """
                    Hawking radiation is theoretical radiation emitted by black holes due to quantum mechanical processes. Features include:
                    • Particle-antiparticle pair creation
                    • Particles escape near the event horizon
                    • Black holes can potentially evaporate over time
                    • Small black holes emit more radiation
                    """,
                citations: [
                    "Hawking, S. (1974). 'Black Hole Explosions?'",
                    "Hawking, S. (1975). 'Particle Creation by Black Holes'"
                ],
                icon: "globe.badge.plus",
                color: Color(red: 0.4, green: 0.7, blue: 1.0),
                type: .verified
            ),

            Theory(
                title: "Primordial Black Holes",
                category: .blackHoles,
                scientist: "Yakov Borisovich Zel'dovich, Igor Novikov",
                year: "1966",
                shortDescription: "Formation of small black holes early in the universe",
                fullDescription: """
                    Primordial black holes may have formed during the high-energy conditions of the early universe. Key characteristics include:
                    • Early density fluctuations create seeds for black holes
                    • Hypothetically smaller than stellar-mass black holes
                    • Possible candidates for dark matter
                    """,
                citations: [
                    "Zel’dovich, Y. & Novikov, I. (1966). 'The Hypothesis of CMB Black Holes'",
                    "Hawking, S. (1971). 'Gravitationally Collapsed Objects'"
                ],
                icon: "sparkles.circle.fill",
                color: Color(red: 0.1, green: 0.4, blue: 0.9),
                type: .verified
            )
        ]
        // MARK: - Universe/Cosmology Theories
        let cosmologyTheories: [Theory] = [
            Theory(
                title: "Big Bang Theory",
                category: .cosmology,
                scientist: "Georges Lemaître & Edwin Hubble",
                year: "1927",
                shortDescription: "The universe began in a hot, dense state and expanded",
                fullDescription: """
                    The Big Bang theory describes the initial state of the universe as a singularity that expanded and cooled over time. Key points include:
                    • Edwin Hubble discovered cosmic expansion through redshift observations
                    • Cosmic microwave background radiation is leftover radiation from the Big Bang
                    • Predicts homogeneity and isotropy (on large scales)
                    """,
                citations: [
                    "Hubble, E.P. (1927). 'A Relation between Distance and Radial Velocity of Nebulae'",
                    "Penzias, A. & Wilson, R. (1965). 'Cosmic Microwave Background'"
                ],
                icon: "flame.fill",
                color: Color.red,
                type: .verified
            ),

            Theory(
                title: "Inflationary Universe",
                category: .cosmology,
                scientist: "Alan Guth",
                year: "1981",
                shortDescription: "An exponential expansion in the early universe to explain uniformity and structure",
                fullDescription: """
                    Inflation theory proposes a brief period of exponential expansion moments after the Big Bang. Key ideas:
                    • Explains flatness and horizons of the universe
                    • Rapid stretching smoothed out irregularities
                    • Quantum fluctuations seeded structures like galaxies
                    """,
                citations: [
                    "Guth, A. (1981). 'Inflationary Universe'",
                    "Linde, A. (1982). 'Chaotic Inflation Models'"
                ],
                icon: "wind.circle",
                color: Color(red: 0.8, green: 0.5, blue: 0.2),
                type: .verified
            ),

            Theory(
                title: "Steady State Model",
                category: .cosmology,
                scientist: "Fred Hoyle, Thomas Gold, Hermann Bondi",
                year: "1948",
                shortDescription: "A competing model to the Big Bang—universe is eternal and constantly creates matter",
                fullDescription: """
                    The Steady State model asserts that as the universe expands, new matter is created to maintain constant density. It fell out of favor due to predictions contradicting observations:
                    • The universe appears isotropic but evolves over time
                    • Background radiation supports a Big Bang event
                    """,
                citations: [
                    "Hoyle, F. (1948). 'The Steady-State Theory in Cosmology'",
                    "Gold, T. & Bondi, H. Papers (1940s)"
                ],
                icon: "house.circle.fill",
                color: Color(.yellow),
                type: .hypothesis
            )
        ]
        // MARK: - Dark Matter/Energy Theories
        let darkMatterTheories: [Theory] = [
            Theory(
                title: "Dark Matter Hypothesis",
                category: .darkMatter,
                scientist: "Fritz Zwicky",
                year: "1933",
                shortDescription: "Invisible mass that explains gravitational effects in galaxies",
                fullDescription: """
                    Dark matter explains "missing mass" in galaxies and their clusters. Evidence:
                    • Galaxy rotational curves (constant velocity)
                    • Gravitational lensing
                    • Structure formation in the cosmic web
                    Key candidates include WIMPs (weakly interacting particles).
                    """,
                citations: [
                    "Zwicky, F. (1933). 'Redshift observations of galaxy clusters'"
                ],
                icon: "eye.slash",
                color: Color.gray,
                type: .verified
            ),

            Theory(
                title: "Dark Energy",
                category: .darkMatter,
                scientist: "Saul Perlmutter, Adam Riess, Brian Schmidt",
                year: "1998",
                shortDescription: "Mysterious energy causing the accelerated expansion of the universe",
                fullDescription: """
                    Dark energy accounts for 68% of the universe's energy density. Key findings:
                    • Observations of Type Ia supernovae revealed accelerated expansion
                    • Dark energy outcompetes gravity over large distances
                    • Its nature remains unknown.
                    """,
                citations: [
                    "Perlmutter, S. et al. (1999). 'Discovery of Cosmic Acceleration'"
                ],
                icon: "bolt.circle.fill",
                color: Color.purple,
                type: .verified
            )
        ]
        // MARK: - Space-Time Theories
        let spaceTimeTheories: [Theory] = [
            Theory(
                title: "Block Universe Theory",
                category: .spaceTime,
                scientist: "Hermann Minkowski",
                year: "1908",
                shortDescription: "Past, present, and future exist simultaneously in 4D spacetime",
                fullDescription: """
                    The Block Universe theory suggests that all moments in time exist simultaneously in a four-dimensional "block" of spacetime. Key concepts:
                    • Time is a dimension, similar to space
                    • All moments exist eternally
                    • The "flow" of time is an illusion
                    • Compatible with special relativity
                    """,
                citations: [
                    "Minkowski, H. (1908). 'Space and Time'",
                    "Einstein, A. (1920). 'Relativity: The Special and General Theory'"
                ],
                icon: "cube.fill",
                color: Color(red: 0.4, green: 0.6, blue: 0.8),
                type: .verified
            ),

            Theory(
                title: "Quantum Gravity",
                category: .spaceTime,
                scientist: "Multiple Scientists",
                year: "1960-Present",
                shortDescription: "Attempts to reconcile quantum mechanics with gravity",
                fullDescription: """
                    Quantum gravity seeks to describe gravity using quantum mechanics principles. Major approaches:
                    • String Theory
                    • Loop Quantum Gravity
                    • Causal Dynamical Triangulations
                    • Asymptotic Safety
                    • Causal Sets
                    """,
                citations: [
                    "Wheeler, J.A. (1957). 'On the Nature of Quantum Geometrodynamics'",
                    "DeWitt, B.S. (1967). 'Quantum Theory of Gravity'"
                ],
                icon: "network",
                color: Color(red: 0.7, green: 0.3, blue: 0.7),
                type: .hypothesis
            )
        ]

        // MARK: - Particle Physics Theories
        let particleTheories: [Theory] = [
            Theory(
                title: "Standard Model",
                category: .particlePhysics,
                scientist: "Multiple Scientists",
                year: "1970s",
                shortDescription: "Fundamental particles and forces of nature",
                fullDescription: """
                    The Standard Model describes fundamental particles and three of four fundamental forces:
                    • Quarks and leptons (matter particles)
                    • Force carriers (bosons)
                    • Higgs mechanism
                    • Electromagnetic, strong, and weak forces
                    """,
                citations: [
                    "Glashow, S. (1961). 'Partial Symmetries of Weak Interactions'",
                    "Weinberg, S. (1967). 'A Model of Leptons'"
                ],
                icon: "atom",
                color: Color(red: 0.9, green: 0.4, blue: 0.4),
                type: .verified
            ),

            Theory(
                title: "Supersymmetry",
                category: .particlePhysics,
                scientist: "Multiple Scientists",
                year: "1970s",
                shortDescription: "Symmetry between fermions and bosons",
                fullDescription: """
                    Supersymmetry proposes a partner particle for each known particle:
                    • Solves hierarchy problem
                    • Provides dark matter candidates
                    • Unifies force coupling constants
                    • Not yet observed experimentally
                    """,
                citations: [
                    "Wess, J. & Zumino, B. (1974). 'Supergauge Transformations'",
                    "Fayet, P. & Ferrara, S. (1977). 'Supersymmetry'"
                ],
                icon: "circle.grid.cross",
                color: Color(red: 0.5, green: 0.8, blue: 0.3),
                type: .hypothesis
            )
        ]

        // MARK: - Astrobiology Theories
        let astrobiologyTheories: [Theory] = [
            Theory(
                title: "Panspermia",
                category: .astrobiology,
                scientist: "Multiple Scientists",
                year: "Ancient-Present",
                shortDescription: "Life spread through space via meteors and cosmic dust",
                fullDescription: """
                    Panspermia suggests life can travel between planets and star systems:
                    • Bacterial spores survive in space
                    • Meteors can transport organic material
                    • Life might originate in multiple locations
                    • Supported by extremophile studies
                    """,
                citations: [
                    "Arrhenius, S. (1903). 'The Propagation of Life in Space'",
                    "Hoyle, F. & Wickramasinghe, N.C. (1981). 'Evolution from Space'"
                ],
                icon: "moon.stars.fill",
                color: Color(red: 0.3, green: 0.9, blue: 0.6),
                type: .hypothesis
            ),

            Theory(
                title: "RNA World Hypothesis",
                category: .astrobiology,
                scientist: "Walter Gilbert",
                year: "1986",
                shortDescription: "RNA preceded DNA in evolution",
                fullDescription: """
                    The RNA World hypothesis suggests RNA was the first genetic material:
                    • RNA can store information and catalyze reactions
                    • Preceded more complex DNA-based life
                    • Supported by ribozyme discovery
                    • Explains the origin of the genetic code
                    """,
                citations: [
                    "Gilbert, W. (1986). 'Origin of Life: The RNA World'",
                    "Cech, T.R. (1989). 'RNA as an Enzyme'"
                ],
                icon: "dna",
                color: Color(red: 0.8, green: 0.6, blue: 0.2),
                type: .verified
            )
        ]
         // MARK: - Example Community Theories (Added for offline Demo) - included within allTheories
         let exampleCommunityTheories: [Theory] = [
             Theory(
                 title: "Community Proposed Theory Example",
                 category: .all,
                 scientist: "Community Member",
                 year: "2024",
                 shortDescription: "An example theory proposed by the community - it's non-interactive in offline mode",
                 fullDescription: "This is an example of a theory added to showcase the Community section UI in offline mode. Interactions are disabled.",
                 citations: [],
                 icon: "person.fill",
                 color: .blue,
                 type: .community,
                 communityMetrics: CommunityMetrics(upvotes: 120, downvotes: 25, comments: [ // Static comments
                     TheoryComment(authorName: "User1", content: "Interesting theory!", timestamp: Date(), replies: [], likes: 5),
                     TheoryComment(authorName: "User2", content: "Needs more evidence but cool concept", timestamp: Date(), replies: [], likes: 2)
                 ], datePosted: Date(), authorName: "CommunityMemberExample", authorCredentials: nil)
             )
         ]

       return relativityTheories + quantumTheories + blackHoleTheories + cosmologyTheories + darkMatterTheories + spaceTimeTheories + particleTheories + astrobiologyTheories + exampleCommunityTheories
    }

    // Helper methods for filtering
    static func theoriesByCategory(_ category: TheoryCategory) -> [Theory] {
        return allTheories.filter { $0.category == category }
    }

    static func theoriesByType(_ type: TheoryType) -> [Theory] {
        return allTheories.filter { $0.type == type }
    }

    static func searchTheories(_ searchText: String) -> [Theory] {
        guard !searchText.isEmpty else { return allTheories }

        return allTheories.filter { theory in
            theory.title.localizedCaseInsensitiveContains(searchText) ||
            theory.scientist.localizedCaseInsensitiveContains(searchText) ||
            theory.shortDescription.localizedCaseInsensitiveContains(searchText)
        }
    }
}

extension TheoryDatabase {
    static var communityTheories: [Theory] = [] // Starts empty, won't be used actively in offline

    static func addCommunityTheory(_ theory: Theory) { // Offline - No Add action
        print("\n--- OFFLINE MODE: Attempted to add community theory ---")
        print("Theory Title: \(theory.title)")
        print("Offline mode - no data will be permanently saved.\n") // Indicate offline no-op
    }

    static func updateCommunityTheory(_ theory: Theory) { // Offline - No Update action
        // Do nothing in offline version
        print("\n--- OFFLINE MODE: Attempted to update community theory ---")
        print("Theory Title: \(theory.title)")
        print("Offline mode - no data will be updated.\n") // Indicate offline no-op
    }
}

extension TheoryDatabase {
    static var theoriesCount: [TheoryCategory: Int] {
        get {
            var counts: [TheoryCategory: Int] = [:]
            TheoryCategory.allCases.forEach { category in
                counts[category] = theoriesByCategory(category).count
            }
            return counts
        }
    }

    static var verifiedTheoriesPercentage: Double {
        let verified = theoriesByType(.verified).count
        return Double(verified) / Double(allTheories.count) * 100
    }
}


// MARK: - Preview
struct TheoryExplorerView_Previews: PreviewProvider {
    static var previews: some View {
        TheoryExplorerView()
    }
}
