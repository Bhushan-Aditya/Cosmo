import SwiftUI

// MARK: - Models & Data Structures
struct Theme: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let accentColor: Color
    let backgroundColor: Color
    let levels: [Level]
}

struct Level: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let description: String
    let requiredPoints: Int
    let questions: [Question]
    let reward: Reward
}

struct Question: Identifiable {
    let id = UUID()
    let text: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String
    let difficulty: Difficulty
    let points: Int
}

struct Reward: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
}

enum Difficulty {
    case easy
    case medium
    case hard
    case expert
    
    var multiplier: Double {
        switch self {
        case .easy: return 1.0
        case .medium: return 1.5
        case .hard: return 2.0
        case .expert: return 3.0
        }
    }
}

// MARK: - Game State Management
class GameState: ObservableObject {
    @Published var currentTheme: Theme?
    @Published var currentLevel: Level?
    @Published var currentQuestionIndex = 0
    @Published var score = 0
    @Published var streak = 0
    @Published var maxStreak = 0
    @Published var selectedAnswer: Int?
    @Published var showAnswer = false
    @Published var isGameOver = false
    @Published var timeRemaining: TimeInterval = 30
    @Published var progress: CGFloat = 0
    
    var timer: Timer?
    var startTime: Date?
    
    func startGame(theme: Theme, level: Level) {
        currentTheme = theme
        currentLevel = level
        currentQuestionIndex = 0
        score = 0
        streak = 0
        maxStreak = 0
        selectedAnswer = nil
        showAnswer = false
        isGameOver = false
        startTimer()
    }
    
    func startTimer() {
        timeRemaining = 30
        startTime = Date()
        timer?.invalidate()
        // Reduced timer frequency to minimize overhead
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    func updateTimer() {
        guard let startTime = startTime else { return }
        let elapsed = Date().timeIntervalSince(startTime)
        timeRemaining = max(0, 30 - elapsed)
        
        // Auto check answer if time runs out
        if timeRemaining <= 0 {
            checkAnswer()
        }
    }
    
    func checkAnswer() {
        guard let currentLevel = currentLevel else { return }
        guard let question = currentLevel.questions[safe: currentQuestionIndex] else { return }
        
        if let selectedAnswer = selectedAnswer {
            if selectedAnswer == question.correctAnswer {
                let timeBonus = Int(timeRemaining * 10)
                let streakBonus = streak * 5
                let difficultyBonus = Int(Double(question.points) * question.difficulty.multiplier)
                score += question.points + timeBonus + streakBonus + difficultyBonus
                streak += 1
                maxStreak = max(maxStreak, streak)
            } else {
                streak = 0
            }
        }
        
        showAnswer = true
        timer?.invalidate()
    }
    
    func nextQuestion() {
        guard let currentLevel = currentLevel else { return }
        
        if currentQuestionIndex < currentLevel.questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = nil
            showAnswer = false
            startTimer()
        } else {
            isGameOver = true
            timer?.invalidate()
        }
        
        progress = CGFloat(currentQuestionIndex + 1) / CGFloat(currentLevel.questions.count)
    }
}

// MARK: - Questions Data
let spaceQuestionsLevel1 = [
    Question(
        text: "Which planet is known as the Red Planet?",
        options: ["Mars", "Venus", "Jupiter", "Mercury"],
        correctAnswer: 0,
        explanation: "Mars is called the Red Planet due to the iron oxide (rust) on its surface.",
        difficulty: .easy,
        points: 10
    ),
    Question(
        text: "What is the largest planet in our solar system?",
        options: ["Jupiter", "Saturn", "Uranus", "Neptune"],
        correctAnswer: 0,
        explanation: "Jupiter is the largest planet, with a mass more than twice that of all other planets combined.",
        difficulty: .easy,
        points: 10
    ),
    Question(
        text: "What is the name of the galaxy we live in?",
        options: ["Andromeda", "Triangulum", "Milky Way", "Whirlpool"],
        correctAnswer: 2,
        explanation: "Our solar system is located in the Milky Way galaxy, a spiral galaxy.",
        difficulty: .easy,
        points: 10
    )
]

let spaceQuestionsLevel2 = [
    Question(
        text: "What is the name of Saturn's largest moon?",
        options: ["Europa", "Titan", "Ganymede", "Io"],
        correctAnswer: 1,
        explanation: "Titan is the largest moon of Saturn and the second-largest moon in our Solar System.",
        difficulty: .medium,
        points: 15
    ),
    Question(
        text: "What is the Oort cloud?",
        options: [
            "A cloud of gas and dust where stars are born",
            "A spherical cloud of icy objects believed to surround the Solar System",
            "The cloud covering Venus",
            "A type of nebula"
        ],
        correctAnswer: 1,
        explanation: "The Oort cloud is a theoretical spherical cloud of icy planetesimals that may surround the Solar System, extending out to interstellar space.",
        difficulty: .medium,
        points: 15
    ),
    Question(
        text: "What is the Great Red Spot?",
        options: ["A large storm on Mars", "A giant crater on the Moon", "A persistent high-pressure region in the atmosphere of Jupiter", "A nebula in Orion"],
        correctAnswer: 2,
        explanation: "The Great Red Spot is a persistent anticyclonic storm on Jupiter, larger than Earth.",
        difficulty: .medium,
        points: 15
    )
]

let spaceQuestionsLevel3 = [
    Question(
        text: "Which telescope is primarily known for detecting gravitational waves?",
        options: ["Hubble Space Telescope", "James Webb Space Telescope", "LIGO (Laser Interferometer Gravitational-Wave Observatory)", "Chandra X-ray Observatory"],
        correctAnswer: 2,
        explanation: "LIGO is designed to detect gravitational waves, ripples in spacetime.",
        difficulty: .hard,
        points: 20
    ),
    Question(
        text: "What is dark matter primarily composed of?",
        options: ["Neutrinos", "Black Holes", "WIMPs (Weakly Interacting Massive Particles)", "Brown Dwarfs"],
        correctAnswer: 2,
        explanation: "WIMPs (Weakly Interacting Massive Particles) are a leading candidate for the composition of dark matter, although its exact nature is still unknown.",
        difficulty: .hard,
        points: 20
    ),
    Question(
        text: "What is the cosmological constant?",
        options: [
            "The rate of expansion of the universe",
            "A term in Einstein's field equations representing the energy density of space itself",
            "The average density of matter in the universe",
            "The speed of light in a vacuum"
        ],
        correctAnswer: 1,
        explanation: "The cosmological constant was introduced by Einstein and later associated with dark energy, representing the energy density of space causing the accelerated expansion of the universe.",
        difficulty: .hard,
        points: 20
    )
]

let spaceQuestionsLevel4 = [
    Question(
        text: "What is the Chandrasekhar Limit?",
        options: ["Maximum mass of a neutron star", "Minimum mass for star formation", "Maximum mass of a stable white dwarf", "Minimum distance to a black hole"],
        correctAnswer: 2,
        explanation: "The Chandrasekhar Limit is the maximum mass of a stable white dwarf star.",
        difficulty: .expert,
        points: 25
    ),
    Question(
        text: "What are Fast Radio Bursts (FRBs)?",
        options: ["Signals from alien civilizations", "Intense, millisecond-duration radio pulses of unknown origin", "Radio emissions from quasars", "Solar flares"],
        correctAnswer: 1,
        explanation: "FRBs are mysterious, intense radio pulses from distant galaxies, lasting only milliseconds.",
        difficulty: .expert,
        points: 25
    ),
    Question(
        text: "Explain the Fermi Paradox.",
        options: ["Lack of evidence for extraterrestrial civilizations given the high probability of their existence", "The accelerating expansion of the universe", "The bending of spacetime around black holes", "The lifespan of stars"],
        correctAnswer: 0,
        explanation: "The Fermi Paradox is the contradiction between the high probability of extraterrestrial civilizations existing and the lack of any observed evidence for them.",
        difficulty: .expert,
        points: 25
    )
]

let technologyQuestionsLevel1 = [
    Question(
        text: "What does HTML stand for?",
        options: ["Hyper Text Markup Language", "Highly Technical Modern Language", "Home Tool Markup Language", "Hyperlink and Text Management Language"],
        correctAnswer: 0,
        explanation: "HTML (Hyper Text Markup Language) is the standard markup language for documents designed to be displayed in a web browser.",
        difficulty: .easy,
        points: 10
    ),
    Question(
        text: "Which company developed the first commercially successful personal computer?",
        options: ["IBM", "Apple", "Microsoft", "Xerox"],
        correctAnswer: 1,
        explanation: "Apple, with the Apple II, is widely regarded as developing the first commercially successful personal computer.",
        difficulty: .easy,
        points: 10
    ),
    Question(
        text: "What is cloud computing?",
        options: [
            "Storing data only on your local devices",
            "Delivering computing services—including servers, storage, databases, networking, software, analytics, and intelligence—over the Internet (“the cloud”)",
            "A method of cooling computer hardware with liquid nitrogen",
            "Building physical data centers"
        ],
        correctAnswer: 1,
        explanation: "Cloud computing is the delivery of computing services—including servers, storage, databases, networking, software, analytics, and intelligence—over the Internet (“the cloud”).",
        difficulty: .easy,
        points: 10
    )
]

let technologyQuestionsLevel2 = [
    Question(
        text: "What is the role of RAM in a computer?",
        options: [
            "Long-term data storage",
            "To provide power to the CPU",
            "To temporarily store data that the CPU is actively using",
            "To manage the computer's cooling system"
        ],
        correctAnswer: 2,
        explanation: "RAM (Random Access Memory) is used for short-term data storage. It allows the CPU to access data quickly for processing.",
        difficulty: .medium,
        points: 15
    ),
    Question(
        text: "What does AI stand for in technology?",
        options: ["Artificial Intelligence", "Augmented Internet", "Automated Instructions", "Advanced Interfaces"],
        correctAnswer: 0,
        explanation: "AI stands for Artificial Intelligence, which refers to the simulation of human intelligence in machines.",
        difficulty: .medium,
        points: 15
    ),
    Question(
        text: "What is blockchain technology primarily known for?",
        options: ["Faster internet speeds", "Secure and transparent cryptocurrency transactions", "Improved mobile phone battery life", "More efficient data compression"],
        correctAnswer: 1,
        explanation: "Blockchain is best known for enabling secure and transparent transactions of cryptocurrencies like Bitcoin, through a decentralized and immutable ledger.",
        difficulty: .medium,
        points: 15
    )
]

let technologyQuestionsLevel3 = [
    Question(
        text: "What is quantum computing primarily expected to excel at over classical computing?",
        options: [
            "Everyday web browsing",
            "Word processing",
            "Solving highly complex problems like drug discovery and materials science",
            "Playing video games"
        ],
        correctAnswer: 2,
        explanation: "Quantum computing is expected to be particularly powerful at solving specific types of highly complex problems currently intractable for classical computers, such as those in drug discovery and materials science.",
        difficulty: .hard,
        points: 20
    ),
    Question(
        text: "Explain the concept of 'edge computing'.",
        options: [
            "A new type of computer screen that curves at the edges",
            "Processing data near the source of data generation, rather than in a centralized data center",
            "Using the very edge of available network bandwidth",
            "A software development technique focusing on the extreme boundaries of code"
        ],
        correctAnswer: 1,
        explanation: "Edge computing involves processing data closer to where it is generated (at the 'edge' of the network) to reduce latency and bandwidth usage, compared to sending all data to a central cloud or data center.",
        difficulty: .hard,
        points: 20
    ),
    Question(
        text: "What are the primary challenges in developing fully autonomous vehicles?",
        options: [
            "Cost of computing hardware only",
            "Ethical considerations, sensor limitations in adverse conditions, and complex decision-making in unpredictable scenarios",
            "Lack of consumer interest",
            "Regulatory hurdles are fully resolved"
        ],
        correctAnswer: 2,
        explanation: "Developing fully autonomous vehicles involves significant challenges including ethical considerations, sensor limitations (especially in bad weather), and creating AI capable of safely navigating unpredictable real-world scenarios and making complex driving decisions.",
        difficulty: .hard,
        points: 20
    )
]

let technologyQuestionsLevel4 = [
    Question(
        text: "What is Web3?",
        options: ["The semantic web", "Decentralized internet based on blockchain technologies", "The mobile web", "The Internet of Things"],
        correctAnswer: 1,
        explanation: "Web3 is envisioned as a decentralized internet built on blockchain, cryptocurrencies, and NFTs.",
        difficulty: .expert,
        points: 25
    ),
    Question(
        text: "Explain the CAP theorem in distributed computing.",
        options: ["Consistency, Availability, Partition tolerance: it is impossible to guarantee all three simultaneously", "CPU Architecture Performance theorem", "Cache Allocation Policy theorem", "Cybersecurity and Privacy theorem"],
        correctAnswer: 0,
        explanation: "CAP theorem states that in a distributed computer system, it is impossible to simultaneously guarantee Consistency, Availability, and Partition Tolerance – only two out of three can be achieved.",
        difficulty: .expert,
        points: 25
    ),
    Question(
        text: "What is homomorphic encryption?",
        options: ["Encryption that always yields the same ciphertext", "Encryption allowing computations to be carried out on ciphertext, producing a ciphertext result which, when decrypted, matches the result of operations performed on the plaintext", "A very weak form of encryption easily broken", "Encryption used only in quantum computing"],
        correctAnswer: 1,
        explanation: "Homomorphic encryption allows computation on encrypted data without decryption. The results of these computations, when decrypted, are the same as if the operations had been performed on the plaintext.",
        difficulty: .expert,
        points: 25
    )
]

// MARK: - Theme Data (Expanded with more levels)
let themes = [
    Theme(
        name: "Space & Astronomy",
        icon: "star.fill",
        accentColor: .purple,
        backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.2),
        levels: [
            Level(
                number: 1,
                title: "Solar System Basics",
                description: "Explore our cosmic neighborhood",
                requiredPoints: 0,
                questions: spaceQuestionsLevel1,
                reward: Reward(
                    title: "Star Navigator",
                    description: "Mastered the basics of our solar system",
                    icon: "sun.max.fill"
                )
            ),
            Level(
                number: 2,
                title: "Deep Space Objects",
                description: "Venture beyond our solar system",
                requiredPoints: 100,
                questions: spaceQuestionsLevel2,
                reward: Reward(
                    title: "Cosmic Pioneer",
                    description: "Explored the mysteries of deep space",
                    icon: "sparkles"
                )
            ),
            Level(
                number: 3,
                title: "Cosmology & Astrophysics",
                description: "Delve into the fundamental laws of the universe",
                requiredPoints: 250,
                questions: spaceQuestionsLevel3,
                reward: Reward(
                    title: "Galaxy Brain",
                    description: "Understanding of the Cosmos and its forces",
                    icon: "atom"
                )
            ),
            Level(
                number: 4,
                title: "Celestial Frontiers",
                description: "Conquer the hardest questions of space",
                requiredPoints: 500,
                questions: spaceQuestionsLevel4,
                reward: Reward(
                    title: "Master of the Universe",
                    description: "Ultimate knowledge of space and astronomy",
                    icon: "space shuttle.fill"
                )
            )
        ]
    ),
    Theme(
        name: "Technology & Innovation",
        icon: "laptopcomputer",
        accentColor: .blue,
        backgroundColor: Color(red: 0.1, green: 0.2, blue: 0.3),
        levels: [
            Level(
                number: 1,
                title: "Digital Basics",
                description: "Understanding modern technology",
                requiredPoints: 0,
                questions: technologyQuestionsLevel1,
                reward: Reward(
                    title: "Tech Novice",
                    description: "Mastered the basics of technology",
                    icon: "chip"
                )
            ),
            Level(
                number: 2,
                title: "Software & the Internet",
                description: "Exploring the world of code and online services",
                requiredPoints: 100,
                questions: technologyQuestionsLevel2,
                reward: Reward(
                    title: "Digital Citizen",
                    description: "Navigating software and internet technologies",
                    icon: "globe"
                )
            ),
            Level(
                number: 3,
                title: "Advanced Technologies",
                description: "Exploring future tech: AI, Quantum Computing, and more",
                requiredPoints: 250,
                questions: technologyQuestionsLevel3,
                reward: Reward(
                    title: "Tech Visionary",
                    description: "Understanding of advanced and emerging technologies",
                    icon: "bolt.horizontal.fill"
                )
            ),
            Level(
                number: 4,
                title: "Cutting-Edge Tech",
                description: "Tackle expert-level questions on the latest tech",
                requiredPoints: 500,
                questions: technologyQuestionsLevel4,
                reward: Reward(
                    title: "Tech Guru",
                    description: "Ultimate understanding of technology and innovation",
                    icon: "cpu.fill"
                )
            )
        ]
    )
]

// MARK: - Main App Entry
struct QuizApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                WelcomeView()
            }
        }
    }
}

// MARK: - Shared Background (Match Explore)
private struct ExploreStyleBackground: View {
    @State private var starfieldRotation: Double = 0

    var body: some View {
        EnhancedCosmicBackground(
            parallaxOffset: 0,
            starfieldRotation: starfieldRotation,
            zoomLevel: 1.0
        )
        .onAppear {
            starfieldRotation = 0
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                starfieldRotation = 360
            }
        }
    }
}

// MARK: - Welcome View
struct WelcomeView: View {
    @State private var showThemes = false
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ExploreStyleBackground()
            
            VStack(spacing: 30) {
                Text("Cosmic Quiz")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                
                Text("Explore the Universe of Knowledge")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
                
                StartButton {
                    withAnimation(.spring()) {
                        showThemes = true
                    }
                }
                .opacity(animate ? 1 : 0)
                .scaleEffect(animate ? 1 : 0.8)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animate = true
            }
        }
        .fullScreenCover(isPresented: $showThemes) {
            ThemeSelectionView()
        }
    }
}

// MARK: - Theme Selection
struct ThemeSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTheme: Theme?
    
    var body: some View {
        ZStack {
            ExploreStyleBackground()
            
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(themes) { theme in
                        ThemeCard(theme: theme)
                            .onTapGesture {
                                selectedTheme = theme
                            }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitle("Select Theme", displayMode: .large)
        .navigationBarItems(leading: Button("Back") { dismiss() })
        .sheet(item: $selectedTheme) { theme in
            LevelSelectionView(theme: theme)
        }
    }
}

// MARK: - Level Selection
struct LevelSelectionView: View {
    let theme: Theme
    @Environment(\.dismiss) var dismiss
    @State private var selectedLevel: Level?
    
    var body: some View {
        ZStack {
            ExploreStyleBackground()
            
            ScrollView {
                VStack(spacing: 25) {
                    ForEach(theme.levels) { level in
                        LevelCard(level: level, theme: theme)
                            .onTapGesture {
                                selectedLevel = level
                            }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitle(theme.name, displayMode: .large)
        .navigationBarItems(leading: Button("Back") { dismiss() })
        .fullScreenCover(item: $selectedLevel) { level in
            EnhancedGameView(gameState: GameState(), theme: theme, level: level)
        }
    }
}

// MARK: - Animated Background (Optimized)
struct AnimatedBackgroundView: View {
    @State private var animate = false
    
    // Pre-generate positions for stars to avoid repeated random calls
    private let starPositions: [CGPoint] = {
        var positions = [CGPoint]()
        for _ in 0..<50 {
            positions.append(
                CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                )
            )
        }
        return positions
    }()
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue, .black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ForEach(0..<starPositions.count, id: \.self) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: CGFloat.random(in: 2...4))
                    .position(starPositions[index])
                    .opacity(animate ? 1 : 0)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 1...3))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...2)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Enhanced Game View
struct EnhancedGameView: View {
    @StateObject var gameState: GameState
    let theme: Theme
    let level: Level
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            ExploreStyleBackground()

            AdvancedAnimations.AnimatedGradientBackground(
                colors: [theme.backgroundColor, theme.accentColor.opacity(0.5)],
                duration: 5
            )
            .opacity(0.35)
            
            AdvancedAnimations.WaveAnimation(
                color: theme.accentColor.opacity(0.3),
                amplitude: 50,
                frequency: 100
            )
            .frame(height: 200)
            .position(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height)
            
            VStack {
                GameHeader(gameState: gameState)
                
                if let currentQuestion = level.questions[safe: gameState.currentQuestionIndex] {
                    QuestionView(
                        question: currentQuestion,
                        gameState: gameState,
                        theme: theme
                    )
                    .modifier(AdvancedAnimations.QuestionTransition(isActive: gameState.showAnswer))
                }
            }
            
            if gameState.streak > 2 {
                AdvancedAnimations.ParticleSystem(colors: [theme.accentColor, .white, .yellow])
            }
        }
        .overlay(
            Group {
                if gameState.isGameOver {
                    GameOverView(
                        score: gameState.score,
                        maxStreak: gameState.maxStreak,
                        theme: theme,
                        level: level,
                        dismiss: dismiss
                    )
                }
            }
        )
        .onAppear {
            gameState.startGame(theme: theme, level: level)
        }
    }
}

// MARK: - Common Components
struct StartButton: View {
    let action: () -> Void
    @State private var animate = false
    
    var body: some View {
        Button(action: action) {
            Text("Start Journey")
                .font(.title2.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.purple)
                        
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                            .blur(radius: animate ? 5 : 0)
                    }
                )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                animate = true
            }
        }
    }
}

struct ThemeCard: View {
    let theme: Theme
    @State private var animate = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: theme.icon)
                    .font(.title)
                    .foregroundColor(theme.accentColor)
                Text(theme.name)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.5))
            }
            Text("\(theme.levels.count) Levels")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(theme.backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(theme.accentColor.opacity(0.5), lineWidth: 2)
                )
        )
        .shadow(color: theme.accentColor.opacity(0.3), radius: animate ? 10 : 5)
        .scaleEffect(animate ? 1 : 0.95)
        .animation(.spring(), value: animate)
        .onAppear {
            animate = true
        }
    }
}

struct LevelCard: View {
    let level: Level
    let theme: Theme
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Level \(level.number): \(level.title)")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                Text(level.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
            Image(systemName: "lock.open.fill") // Could be locked if insufficient points
                .foregroundColor(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(theme.backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(theme.accentColor.opacity(0.5), lineWidth: 2)
                )
        )
    }
}

// MARK: - Game Header
struct GameHeader: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                ProgressBar(progress: gameState.progress)
                    .frame(height: 8)
                TimerView(timeRemaining: gameState.timeRemaining)
                    .frame(width: 80)
            }
            HStack {
                ScoreView(score: gameState.score)
                Spacer()
                StreakView(streak: gameState.streak)
            }
        }
    }
}

// MARK: - Question & Answers
struct QuestionView: View {
    let question: Question
    @ObservedObject var gameState: GameState
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 25) {
            Text(question.text)
                .font(.title2.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.1))
                )
            
            VStack(spacing: 15) {
                ForEach(question.options.indices, id: \.self) { index in
                    AnswerButton(
                        text: question.options[index],
                        isSelected: gameState.selectedAnswer == index,
                        isCorrect: gameState.showAnswer ? (index == question.correctAnswer) : nil
                    ) {
                        withAnimation(.spring()) {
                            gameState.selectedAnswer = index
                            gameState.checkAnswer()
                        }
                    }
                }
            }
            
            if gameState.showAnswer {
                ExplanationView(
                    explanation: question.explanation,
                    isCorrect: gameState.selectedAnswer == question.correctAnswer
                )
                NextQuestionButton(gameState: gameState)
            }
        }
    }
}

struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool?
    let action: () -> Void
    
    private var backgroundColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .green : .red
        }
        return isSelected ? .blue : .white.opacity(0.1)
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.title3)
                    .foregroundColor(.white)
                Spacer()
                if let isCorrect = isCorrect {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "x.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(15)
            .shadow(color: backgroundColor.opacity(0.3), radius: 5)
        }
        .disabled(isCorrect != nil)
    }
}

struct ExplanationView: View {
    let explanation: String
    let isCorrect: Bool
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: isCorrect ? "star.fill" : "info.circle.fill")
                .font(.title)
                .foregroundColor(isCorrect ? .yellow : .blue)
            Text(isCorrect ? "Correct!" : "Not quite...")
                .font(.title2.bold())
                .foregroundColor(.white)
            Text(explanation)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
        )
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .onAppear {
            withAnimation(.spring()) {
                appear = true
            }
        }
    }
}

struct NextQuestionButton: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        Button {
            gameState.nextQuestion()
        } label: {
            Text("Next Question")
                .font(.title3.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(Color.blue)
                .cornerRadius(15)
        }
    }
}

// MARK: - Game Over View
struct GameOverView: View {
    let score: Int
    let maxStreak: Int
    let theme: Theme
    let level: Level
    var dismiss: DismissAction?
    @State private var showConfetti = false
    @Environment(\.dismiss) var presentationMode
    
    var body: some View {
        ZStack {
            ExploreStyleBackground()
                .overlay(Color.black.opacity(0.75).ignoresSafeArea())
            
            VStack(spacing: 30) {
                Text("Level Complete!")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 20) {
                    StatItem(title: "Final Score", value: "\(score)")
                    StatItem(title: "Highest Streak", value: "\(maxStreak)")
                    StatItem(title: "Accuracy", value: "\(calculateAccuracy())%")
                }
                
                if let reward = getReward() {
                    RewardView(reward: reward)
                }
                
                VStack(spacing: 15) {
                    ActionButton(title: "Play Again", color: theme.accentColor) {
                        dismiss?()
                    }
                    ActionButton(title: "Back to Levels", color: .gray) {
                        dismiss?()
                    }
                    ActionButton(title: "Go to Welcome Page", color: .blue) {
                        presentationMode()
                    }
                }
            }
            .padding()
            
            if showConfetti {
                ConfettiView()
            }
        }
        .onAppear {
            showConfetti = true
        }
    }
    
    private func calculateAccuracy() -> Int {
        // Implement accuracy calculation if needed
        return 85
    }
    
    private func getReward() -> Reward? {
        return level.reward
    }
}

// MARK: - Supporting Components
struct ProgressBar: View {
    let progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                Rectangle()
                    .fill(Color.green)
                    .frame(width: geometry.size.width * progress)
            }
        }
        .cornerRadius(5)
        .animation(.spring(), value: progress)
    }
}

struct TimerView: View {
    let timeRemaining: TimeInterval
    
    var body: some View {
        Text(String(format: "%.1f", timeRemaining))
            .font(.system(.title3, design: .monospaced).bold())
            .foregroundColor(timeRemaining < 5 ? .red : .white)
            .frame(width: 60)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.1))
            )
    }
}

struct ScoreView: View {
    let score: Int
    @State private var animate = false
    
    var body: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            Text("\(score)")
                .font(.title2.bold())
                .foregroundColor(.white)
        }
        .scaleEffect(animate ? 1.2 : 1)
        .onChange(of: score) { _ in
            withAnimation(.spring()) {
                animate = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring()) {
                    animate = false
                }
            }
        }
    }
}

struct StreakView: View {
    let streak: Int
    
    var body: some View {
        HStack {
            Image(systemName: "flame.fill")
                .foregroundColor(.orange)
            Text("\(streak)")
                .font(.title2.bold())
                .foregroundColor(.white)
        }
    }
}

// MARK: - Simplified Confetti View (Optimized)
struct ConfettiView: View {
    @State private var animate = false
    
    // Reduced confetti number and pre-generate positions
    private let confettiCount = 15
    private let confettiData: [(scale: CGFloat, position: CGPoint)] = {
        var data = [(scale: CGFloat, position: CGPoint)]()
        for _ in 0..<15 {
            data.append((
                scale: CGFloat.random(in: 0.5...2.0),
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                )
            ))
        }
        return data
    }()
    
    var body: some View {
        ZStack {
            ForEach(0..<confettiCount, id: \.self) { index in
                let conf = confettiData[index]
                Image(systemName: "sparkles")
                    .foregroundColor(Color.random())
                    .font(.system(size: 18 * conf.scale))
                    .position(conf.position)
                    .scaleEffect(animate ? 1 : 0.5)
                    .opacity(animate ? 1 : 0)
                    .animation(
                        Animation.spring(response: 0.4, dampingFraction: 0.6)
                            .delay(Double.random(in: 0...0.5)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title3)
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.white)
        }
    }
}

struct RewardView: View {
    let reward: Reward
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: reward.icon)
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            Text(reward.title)
                .font(.title.bold())
                .foregroundColor(.white)
            Text(reward.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct ActionButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title3.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 15)
                .background(color)
                .cornerRadius(15)
        }
    }
}

// MARK: - Advanced Animations
struct AdvancedAnimations {
    // Particle System
    struct ParticleSystem: View {
        let colors: [Color]
        @State private var particles: [(id: Int, x: CGFloat, y: CGFloat, scale: CGFloat)] = []
        @State private var timer: Timer?
        
        var body: some View {
            TimelineView(.animation) { _ in
                Canvas { context, size in
                    for particle in particles {
                        let rect = CGRect(
                            x: particle.x,
                            y: particle.y,
                            width: 5 * particle.scale,
                            height: 5 * particle.scale
                        )
                        context.fill(
                            Path(ellipseIn: rect),
                            with: .color(colors.randomElement() ?? .white)
                        )
                    }
                }
            }
            .onAppear {
                startParticleSystem()
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
        
        private func startParticleSystem() {
            timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                updateParticles()
            }
        }
        
        private func updateParticles() {
            // Update existing particles
            particles = particles.compactMap { particle in
                var newParticle = particle
                newParticle.y -= 2
                newParticle.scale *= 0.95
                return newParticle.scale > 0.1 ? newParticle : nil
            }
            // Add new particles
            if particles.count < 40 {
                particles.append((
                    id: Int.random(in: 0...1000),
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: UIScreen.main.bounds.height + 10,
                    scale: CGFloat.random(in: 0.5...2.0)
                ))
            }
        }
    }
    
    // Wave Animation
    struct WaveAnimation: View {
        @State private var phase = 0.0
        let color: Color
        let amplitude: CGFloat
        let frequency: CGFloat
        
        var body: some View {
            TimelineView(.animation) { _ in
                Canvas { context, size in
                    let path = Path { path in
                        path.move(to: CGPoint(x: 0, y: size.height / 2))
                        for x in stride(from: 0, to: size.width, by: 1) {
                            let y = sin((x / frequency) + phase) * amplitude + size.height / 2
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    context.stroke(
                        path,
                        with: .color(color),
                        lineWidth: 2
                    )
                }
            }
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    phase = .pi * 2
                }
            }
        }
    }
    
    // Animated Gradient Background
    struct AnimatedGradientBackground: View {
        @State private var start = UnitPoint(x: 0, y: 0)
        @State private var end = UnitPoint(x: 1, y: 1)
        
        let colors: [Color]
        let duration: Double
        
        var body: some View {
            LinearGradient(colors: colors, startPoint: start, endPoint: end)
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.linear(duration: duration).repeatForever(autoreverses: true)) {
                        start = UnitPoint(x: 1, y: 1)
                        end = UnitPoint(x: 0, y: 0)
                    }
                }
        }
    }
    
    // Success Animation
    struct SuccessAnimation: View {
        @State private var scale = 0.0
        @State private var opacity = 0.0
        
        var body: some View {
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 100, height: 100)
                    .scaleEffect(scale)
                    .opacity(opacity)
                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(opacity)
            }
            .onAppear {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1
                    opacity = 1
                }
            }
        }
    }
    
    // Custom Question Transition
    struct QuestionTransition: ViewModifier {
        let isActive: Bool
        
        func body(content: Content) -> some View {
            content
                .rotation3DEffect(
                    .degrees(isActive ? 360 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isActive)
        }
    }
}

// MARK: - Array & Color Extensions
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Color {
    static func random() -> Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

// MARK: - Preview
struct QuizAppPreviews: PreviewProvider {
    static var previews: some View {
        VStack {
            WelcomeView()
            ThemeSelectionView()
            LevelSelectionView(theme: themes[0])
            EnhancedGameView(gameState: GameState(), theme: themes[0], level: themes[0].levels[0])
        }
        .preferredColorScheme(.dark)
    }
}
