import SwiftUI

// MARK: - Top Button

struct ProfileTopButton: View {
    var body: some View {
        NavigationLink {
            ProfilePageView()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                    .frame(width: 36, height: 36)

                Image(systemName: "person.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Profile Page

struct ProfilePageView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var remoteProfile: RemoteProfile?
    @State private var dailyStreak = DailyStreakStore.shared.currentStreak
    @State private var dailyBest   = DailyStreakStore.shared.bestStreak

    @State private var isEditingName = false
    @State private var draftName = ""
    @State private var isSavingName = false

    @State private var isSyncing = false
    @State private var showDeleteConfirm = false

    private var email: String? { AuthSessionStore.shared.currentEmail }

    var body: some View {
        ZStack {
            // App background
            CosmoAnimatedBackground()
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    avatarSection
                        .padding(.top, 24)
                        .padding(.bottom, 28)

                    streakCard
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)

                    historySection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)

                    settingsSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
            }
        }
        .preferredColorScheme(.dark)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadAll() }
        .onReceive(NotificationCenter.default.publisher(for: .dailyStreakDidUpdate)) { _ in
            dailyStreak = DailyStreakStore.shared.currentStreak
            dailyBest   = DailyStreakStore.shared.bestStreak
        }
        .onReceive(NotificationCenter.default.publisher(for: .quizDataDidSync)) { _ in
            Task { await loadProfile() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .gameDataDidSync)) { _ in
            Task { await loadProfile() }
        }
        .alert("Delete Account Data", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) { deleteAccountData() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears all local data and signs you out. Your remote history is preserved.")
        }
    }

    // MARK: - Avatar + Name

    private var avatarSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.5), Color.blue.opacity(0.4)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 84, height: 84)
                Image(systemName: "person.fill")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
            }

            if isEditingName {
                HStack(spacing: 8) {
                    TextField("Display name", text: $draftName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                                )
                        )
                        .frame(maxWidth: 200)

                    if isSavingName {
                        ProgressView().tint(.white).scaleEffect(0.8)
                    } else {
                        Button { Task { await saveName() } } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.green)
                        }
                        Button { isEditingName = false } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
            } else {
                HStack(spacing: 6) {
                    Text(remoteProfile?.displayName ?? email?.components(separatedBy: "@").first ?? "Explorer")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)

                    Button {
                        draftName = remoteProfile?.displayName ?? ""
                        isEditingName = true
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.45))
                    }
                }
            }

            if let email {
                Text(email)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.45))
            }
        }
    }

    // MARK: - Unified Daily Streak

    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.orange)
                Text("Daily Streak")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(dailyStreak)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                VStack(alignment: .leading, spacing: 2) {
                    Text("days")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                    Text("Best: \(dailyBest)")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.35))
                }
            }

            Text(dailyStreak == 0
                 ? "Complete a quiz or game today to start your streak."
                 : "Keep going — play a quiz or game every day.")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.45))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cosmoCard(cornerRadius: 18, strokeColor: Color.orange.opacity(0.35), fillOpacity: 0.14)
    }

    // MARK: - History

    private var historySection: some View {
        VStack(spacing: 1) {
            sectionHeader("History")
            NavigationLink {
                QuizHistoryView()
            } label: {
                historyRow(icon: "list.bullet.rectangle", label: "Quiz Run History")
            }
            .buttonStyle(.plain)

            NavigationLink {
                GameHistoryView()
            } label: {
                historyRow(icon: "gamecontroller", label: "Game Session History")
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(spacing: 10) {
            sectionHeader("Settings")

            Button {
                guard !isSyncing else { return }
                isSyncing = true
                Task {
                    await SupabaseUploadQueue.shared.drain()
                    isSyncing = false
                    ToastManager.shared.show("Sync complete", style: .success)
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Text(isSyncing ? "Syncing…" : "Sync Now")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    if isSyncing {
                        ProgressView().tint(.white).scaleEffect(0.8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.08))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.12), lineWidth: 1))
                )
            }
            .buttonStyle(.plain)

            Button {
                AuthSessionStore.shared.clearSession()
                dismiss()
            } label: {
                actionRow(label: "Sign Out", icon: "arrow.right.square", color: .orange)
            }
            .buttonStyle(.plain)

            Button { showDeleteConfirm = true } label: {
                actionRow(label: "Delete Account Data", icon: "trash", color: .red)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Reusable Rows

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.white.opacity(0.35))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 6)
            .padding(.top, 4)
    }

    private func historyRow(icon: String, label: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 22)
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .overlay(Divider().opacity(0.15), alignment: .bottom)
    }

    private func actionRow(label: String, icon: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(color)
            Text(label)
                .font(.headline)
                .foregroundColor(color)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(color.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.2), lineWidth: 1))
        )
    }

    // MARK: - Data Loading

    private func loadAll() async {
        await loadProfile()
    }

    private func loadProfile() async {
        do {
            remoteProfile = try await SupabaseProfileSyncService.shared.fetchCurrentProfile()
        } catch {
#if DEBUG
            print("[Profile] Fetch failed: \(error.localizedDescription)")
#endif
        }
    }

    private func saveName() async {
        isSavingName = true
        do {
            try await SupabaseProfileSyncService.shared.upsertCurrentProfile(displayName: draftName)
            remoteProfile = try await SupabaseProfileSyncService.shared.fetchCurrentProfile()
            isEditingName = false
            ToastManager.shared.show("Name updated", style: .success)
        } catch {
            ToastManager.shared.show("Failed to save name", style: .error)
        }
        isSavingName = false
    }

    private func deleteAccountData() {
        DailyStreakStore.shared.clearAll()
        UserDefaults.standard.removeObject(forKey: "cosmo.quiz.stats.v1")
        UserDefaults.standard.removeObject(forKey: "supabase.pendingUploads")
        AuthSessionStore.shared.clearSession()
        dismiss()
    }
}
