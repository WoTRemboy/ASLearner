import Foundation

final class Texts {
    enum AppInfo {
        static let title = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "AS Learner"
    }

    enum UserDefaults {
        static let skipOnboarding = "skipOnboarding"
    }

    enum Tabbar {
        static let home = "Home"
        static let path = "Learning"
        static let profile = "Profile"
        static let settings = "Settings"
        static let dictionary = "Dictionary"
        static let stats = "Stats"
    }

    enum OnboardingPage {
        static let skip = "Skip"
        static let skipPermission = "Later"
        static let next = "Next"
        static let begin = "Start"
        static let permission = "Allow"
        static let forbidden = "Unavailable"

        enum FirstPage {
            static let title = "Signa"
            static let description = "Learn sign language through short visual lessons and guided practice."
        }

        enum SecondPage {
            static let title = "Local intelligence"
            static let description = "Receive hints and generated quizzes prepared for a future on-device LLM."
        }

        enum ThirdPage {
            static let title = "Progress"
            static let description = "Earn XP, unlock achievements, keep a streak, and analyze learning results."
        }

        enum FourthPage {
            static let title = "Camera access"
            static let description = "Allow camera access to run the gesture recognition scenario."
        }

        enum CameraAlert {
            static let title = "Camera access is disabled"
            static let content = "Open Settings and allow camera access to use gesture recognition."
            static let settings = "Settings"
            static let cancel = "Cancel"
        }
    }

    enum HomePage {
        static let title = "Learn gestures"
        static let progressLevel = "Level"
        static let xp = "XP"
        static let streak = "day streak"
        static let nextLevel = "Next level at"
        static let demoTitle = "Demo scenario"
        static let demoDescription = "Start a short lesson, perform “Hello” in mock camera mode, receive recognition confidence, earn XP, and unlock progress."
        static let practiceHello = "Practice Hello"
    }

    enum LessonsPage {
        static let title = "Lessons"
        static let lessonGestures = "Lesson gestures"
        static let minutes = "min"
        static let gestures = "gestures"
    }

    enum LearningFlowPage {
        static let title = "Learning"
        static let progress = "Module progress"
        static let completed = "Completed"
        static let available = "Available"
        static let locked = "Locked"
        static let xp = "XP"
        static let start = "Start"
        static let lockedNode = "Complete previous steps to unlock"
        static let sectionsTitle = "Sections"
        static let sectionsSubtitle = "Choose a learning section"
        static let sectionsDescription = "The first section is connected to the current learning path. The rest show the future course structure."
        static let comingSoonDescription = "New practice nodes, adaptive tests and recognition scenarios will appear here later."
        static let comingSoon = "Coming soon..."
        static let close = "Close"
        static let unit = "Unit"
        static let complete = "Complete"
        static let completeLesson = "Complete lesson"
        static let completeCheckpoint = "Complete checkpoint"
        static let simulateGesture = "Simulate correct gesture"
        static let gestureAccepted = "Gesture accepted. You can complete this step."
        static let chooseAnswer = "Choose the correct answer"
        static let correctAnswer = "Correct. Step is ready to complete."
        static let wrongAnswer = "Try again. Look for the gesture meaning."
        static let currentLesson = "Current lesson"
    }

    enum PracticePage {
        static let titlePrefix = "Show"
        static let openCamera = "Open camera task"
        static let preparingHint = "Preparing local model hint..."
    }

    enum CameraPage {
        static let title = "Camera"
        static let initialFeedback = "Place your hand inside the frame and start recognition."
        static let mockPreview = "Mock CV preview"
        static let result = "Recognition result"
        static let waiting = "Waiting"
        static let gesture = "Gesture"
        static let confidence = "Confidence"
        static let scanning = "Scanning..."
        static let runRecognition = "Run recognition"
        static let analyzing = "Analyzing hand pose and temporal motion..."
        static let accepted = "Gesture accepted with stable confidence."
        static let lowConfidence = "The model sees a similar gesture. Repeat slower and keep your hand in frame."
        static let notDetected = "Gesture was not detected. Improve lighting and try again."
    }

    enum QuizPage {
        static let title = "Generated quiz"
        static let loading = "Generating adaptive questions..."
        static let tasks = "tasks"
        static let submitted = "Quiz submitted. XP was added to the shared progress model."
        static let performed = "Marked as performed"
        static let markReady = "Mark camera task ready"
        static let newQuiz = "Generate new quiz"
        static let submit = "Submit quiz"
    }

    enum DictionaryPage {
        static let title = "Dictionary"
        static let search = "Search gestures"
        static let emptySearch = "No gestures found"
        static let category = "Category"
        static let difficulty = "Difficulty"
        static let howToPerform = "How to perform"
    }

    enum AchievementsPage {
        static let title = "Achievements"
        static let unlocked = "unlocked"
    }

    enum StatisticsPage {
        static let title = "Statistics"
        static let openAchievements = "Open achievements"
        static let recognitionCoverage = "Recognition coverage"
        static let recognitionCoverageSuffix = "gestures were accepted by the mock recognition pipeline."
        static let quizHistory = "Quiz history"
        static let emptyQuizHistory = "No generated quiz attempts yet."
    }

    enum ProfilePage {
        static let title = "Profile"
        static let subtitle = "Your sign language learning progress"
        static let learningProgress = "Learning progress"
        static let practiceSummary = "Practice summary"
        static let achievements = "Achievements"
        static let latestAchievements = "Latest achievements"
        static let viewAchievements = "View achievements"
    }

    enum SettingsPage {
        static let title = "Settings"
        static let learning = "Learning"
        static let recognition = "Recognition"
        static let about = "About"
        static let dailyGoal = "Daily goal"
        static let dailyGoalValue = "10 minutes"
        static let reminders = "Practice reminders"
        static let remindersValue = "Enabled"
        static let cameraMode = "Camera mode"
        static let cameraModeValue = "Mock recognition"
        static let localLLM = "Local LLM"
        static let localLLMValue = "Mock hints"
        static let appVersion = "Prototype version"
        static let appVersionValue = "Research demo"
    }

    enum Stats {
        static let lessons = "Lessons"
        static let gestures = "Gestures"
        static let quizAverage = "Quiz avg"
        static let badges = "Badges"
        static let level = "Level"
        static let streak = "Streak"
        static let averageQuiz = "Average"
    }

    enum GlassEffectId {
        enum Onboarding {
            static let begin = "OnboardingBeginGlassEffect"
            static let permission = "OnboardingPermissionGlassEffect"
            static let skip = "OnboardingSkipGlassEffect"
            static let skipPermission = "OnboardingSkipPermissionGlassEffect"
        }
    }
}
