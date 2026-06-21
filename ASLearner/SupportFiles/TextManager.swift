import Foundation

final class Texts {
    enum AppInfo {
        static let title = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "AS Learner"
    }

    enum UserDefaults {
        static let skipOnboarding = "skipOnboarding"
        static let quizMistakes = "quizMistakes"
    }

    enum Tabbar {
        static let home = "Главная"
        static let path = "Обучение"
        static let profile = "Профиль"
        static let settings = "Настройки"
        static let dictionary = "Словарь"
        static let stats = "Статистика"
    }

    enum OnboardingPage {
        static let skip = "Пропустить"
        static let skipPermission = "Позже"
        static let next = "Далее"
        static let begin = "Начать"
        static let permission = "Разрешить"
        static let forbidden = "Недоступно"

        enum FirstPage {
            static let title = "Signa"
            static let description = "Изучайте жестовый язык через короткие уроки и практику с камерой."
        }

        enum SecondPage {
            static let title = "Локальный интеллект"
            static let description = "Получайте подсказки и тесты, подготовленные для будущей локальной LLM."
        }

        enum ThirdPage {
            static let title = "Прогресс"
            static let description = "Зарабатывайте XP, открывайте достижения и следите за результатами."
        }

        enum FourthPage {
            static let title = "Доступ к камере"
            static let description = "Разрешите камеру, чтобы тренировать жесты с распознаванием."
        }

        enum CameraAlert {
            static let title = "Камера отключена"
            static let content = "Откройте настройки и разрешите доступ к камере для распознавания жестов."
            static let settings = "Настройки"
            static let cancel = "Отмена"
        }
    }

    enum HomePage {
        static let title = "Учите жесты"
        static let progressLevel = "Уровень"
        static let xp = "XP"
        static let streak = "дней подряд"
        static let nextLevel = "Следующий уровень"
        static let demoTitle = "Демо-сценарий"
        static let demoDescription = "Пройдите короткий урок, покажите жест, получите результат распознавания и XP."
        static let practiceHello = "Практика: привет"
    }

    enum LessonsPage {
        static let title = "Уроки"
        static let lessonGestures = "Жесты урока"
        static let minutes = "мин"
        static let gestures = "жестов"
    }

    enum LearningFlowPage {
        static let title = "Обучение"
        static let progress = "Прогресс модуля"
        static let completed = "Пройдено"
        static let available = "Доступно"
        static let locked = "Закрыто"
        static let xp = "XP"
        static let start = "Старт"
        static let lockedNode = "Сначала пройдите предыдущие шаги"
        static let sectionsTitle = "Разделы"
        static let sectionsSubtitle = "Выберите раздел"
        static let sectionsDescription = "Первый раздел связан с текущим маршрутом. Остальные показывают будущую структуру курса."
        static let comingSoonDescription = "Новые задания, адаптивные тесты и сценарии распознавания появятся позже."
        static let comingSoon = "Скоро..."
        static let close = "Закрыть"
        static let unit = "Шаг"
        static let complete = "Завершить"
        static let completeLesson = "Завершить урок"
        static let completeCheckpoint = "Завершить"
        static let continueButton = "Продолжить"
        static let streakTitle = "дней подряд"
        static let streakToday = "Сегодня"
        static let streakSubtitle = "Вы продлили серию сегодня. Вернитесь завтра, чтобы сохранить темп."
        static let skipGesture = "Пропустить"
        static let skipGestureTitle = "Засчитать жест?"
        static let skipGestureMessage = "Используйте это, если распознавание не сработало. Практика будет отмечена как выполненная."
        static let skipGestureConfirm = "Засчитать"
        static let simulateGesture = "Симулировать верный жест"
        static let gestureAccepted = "Жест принят. Можно продолжать."
        static let chooseAnswer = "Выберите верный ответ"
        static let correctAnswer = "Верно. Шаг готов к завершению."
        static let wrongAnswer = "Попробуйте ещё раз. Вспомните значение жеста."
        static let currentLesson = "Текущий урок"
    }

    enum PracticePage {
        static let titlePrefix = "Покажи"
        static let openCamera = "Открыть камеру"
        static let preparingHint = "Готовим подсказку..."
    }

    enum CameraPage {
        static let title = "Камера"
        static let initialFeedback = "Поместите руку в кадр и запустите распознавание."
        static let mockPreview = "CV-превью"
        static let result = "Результат"
        static let waiting = "Ожидание"
        static let gesture = "Жест"
        static let confidence = "Уверенность"
        static let scanning = "Сканируем..."
        static let runRecognition = "Распознать"
        static let startLiveRecognition = "Начать"
        static let stopRecognition = "Остановить"
        static let preparingCamera = "Готовим камеру..."
        static let liveAnalyzing = "Камера передаёт кадры в MediaPipe."
        static let livePreview = "Live MediaPipe"
        static let cameraUnavailable = "Камера недоступна"
        static let fallbackRecognition = "Запустить mock"
        static let analyzing = "Анализируем позу руки и движение..."
        static let accepted = "Жест принят с высокой уверенностью."
        static let lowConfidence = "Модель видит похожий жест. Повторите медленнее и держите руку в кадре."
        static let notDetected = "Жест не найден. Улучшите свет и попробуйте снова."
    }

    enum QuizPage {
        static let title = "Тест"
        static let loading = "Генерируем задания..."
        static let generationTitle = "Подготовка теста"
        static let generationSubtitle = "Анализируем пройденный материал и ошибки, затем формируем задания локальной моделью."
        static let generationCompleted = "Тест готов"
        static let tasks = "заданий"
        static let submitted = "Тест завершён. XP добавлены в общий прогресс."
        static let performed = "Выполнено"
        static let markReady = "Отметить готовым"
        static let newQuiz = "Новый тест"
        static let submit = "Завершить тест"
    }

    enum DictionaryPage {
        static let title = "Словарь"
        static let search = "Поиск жестов"
        static let emptySearch = "Жесты не найдены"
        static let category = "Категория"
        static let difficulty = "Сложность"
        static let howToPerform = "Как выполнить"
        static let practiceGesture = "Тренировать жест"
        static let closePractice = "Закрыть тренировку"

        static func rowSubtitle(name: String, category: String) -> String {
            "\(name) • \(category)"
        }

        static func practiceTitle(_ gestureName: String) -> String {
            "Тренировка «\(gestureName)»"
        }
    }

    enum AchievementsPage {
        static let title = "Достижения"
        static let unlocked = "открыто"
    }

    enum StatisticsPage {
        static let title = "Статистика"
        static let openAchievements = "Открыть достижения"
        static let recognitionCoverage = "Распознавание"
        static let recognitionCoverageSuffix = "жестов принято системой распознавания."
        static let quizHistory = "История тестов"
        static let emptyQuizHistory = "Попыток тестов пока нет."

        static func recognitionSummary(recognized: Int, total: Int) -> String {
            "\(recognized) из \(total): \(recognitionCoverageSuffix)"
        }

        static func quizScore(correct: Int, total: Int) -> String {
            "\(correct)/\(total)"
        }
    }

    enum ProfilePage {
        static let title = "Профиль"
        static let subtitle = "Ваш прогресс в жестовом языке"
        static let learningProgress = "Прогресс"
        static let practiceSummary = "Практика"
        static let achievements = "Достижения"
        static let latestAchievements = "Новые достижения"
        static let viewAchievements = "Все достижения"

        static func levelTitle(_ level: Int) -> String {
            "\(HomePage.progressLevel) \(level)"
        }

        static func inlineXP(_ xp: Int) -> String {
            " • \(xp) \(HomePage.xp)"
        }

        static func progressPercent(_ value: Double) -> String {
            "\(Int(value * 100))%"
        }

        static func nextLevelXP(_ xp: Int) -> String {
            "\(HomePage.nextLevel) \(xp) \(HomePage.xp)"
        }
    }

    enum SettingsPage {
        static let title = "Настройки"
        static let learning = "Обучение"
        static let recognition = "Распознавание"
        static let about = "О приложении"
        static let dailyGoal = "Цель на день"
        static let dailyGoalValue = "10 минут"
        static let reminders = "Напоминания"
        static let remindersValue = "Включены"
        static let cameraMode = "Режим камеры"
        static let cameraModeValue = "Готово к MediaPipe"
        static let localLLM = "Локальная LLM"
        static let localLLMValue = "Тестовые подсказки"
        static let appVersion = "Версия"
        static let appVersionValue = "НИР-прототип"
    }

    enum Stats {
        static let lessons = "Уроки"
        static let gestures = "Жесты"
        static let quizAverage = "Средний тест"
        static let badges = "Значки"
        static let level = "Уровень"
        static let streak = "Серия"
        static let averageQuiz = "Среднее"
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
