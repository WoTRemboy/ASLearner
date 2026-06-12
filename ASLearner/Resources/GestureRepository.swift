import Foundation

enum GestureRepository {
    static let gestures: [GestureModel] = [
        GestureModel(
            id: GestureType.hello.id,
            type: .hello,
            englishName: "Hello",
            russianName: "Привет",
            executionDescription: "Open your hand near the forehead and move it outward in a small arc.",
            difficulty: .beginner,
            category: "Basics",
            symbolName: "hand.wave.fill",
            mediaPlaceholderName: nil
        ),
        GestureModel(
            id: GestureType.thankYou.id,
            type: .thankYou,
            englishName: "Thank you",
            russianName: "Спасибо",
            executionDescription: "Touch the fingertips to the chin and move the hand forward with the palm up.",
            difficulty: .beginner,
            category: "Basics",
            symbolName: "hands.clap.fill",
            mediaPlaceholderName: nil
        ),
        GestureModel(
            id: GestureType.yes.id,
            type: .yes,
            englishName: "Yes",
            russianName: "Да",
            executionDescription: "Make a fist and nod it down and up like a small head movement.",
            difficulty: .beginner,
            category: "Answers",
            symbolName: "checkmark.circle.fill",
            mediaPlaceholderName: nil
        ),
        GestureModel(
            id: GestureType.no.id,
            type: .no,
            englishName: "No",
            russianName: "Нет",
            executionDescription: "Bring the index and middle fingers together with the thumb twice.",
            difficulty: .beginner,
            category: "Answers",
            symbolName: "xmark.circle.fill",
            mediaPlaceholderName: nil
        ),
        GestureModel(
            id: GestureType.please.id,
            type: .please,
            englishName: "Please",
            russianName: "Пожалуйста",
            executionDescription: "Place an open hand on the chest and move it in a small circular motion.",
            difficulty: .beginner,
            category: "Polite phrases",
            symbolName: "heart.circle.fill",
            mediaPlaceholderName: nil
        ),
        GestureModel(
            id: GestureType.help.id,
            type: .help,
            englishName: "Help",
            russianName: "Помощь",
            executionDescription: "Place one fist on the opposite open palm and raise both hands upward.",
            difficulty: .medium,
            category: "Everyday",
            symbolName: "lifepreserver.fill",
            mediaPlaceholderName: nil
        ),
        GestureModel(
            id: GestureType.good.id,
            type: .good,
            englishName: "Good",
            russianName: "Хорошо",
            executionDescription: "Move a flat hand from the lips down to the opposite palm.",
            difficulty: .medium,
            category: "Feedback",
            symbolName: "hand.thumbsup.fill",
            mediaPlaceholderName: nil
        ),
        GestureModel(
            id: GestureType.bad.id,
            type: .bad,
            englishName: "Bad",
            russianName: "Плохо",
            executionDescription: "Move a flat hand away from the mouth and rotate it downward.",
            difficulty: .medium,
            category: "Feedback",
            symbolName: "hand.thumbsdown.fill",
            mediaPlaceholderName: nil
        ),
        GestureModel(
            id: GestureType.iLoveYou.id,
            type: .iLoveYou,
            englishName: "I love you",
            russianName: "Я люблю тебя",
            executionDescription: "Raise the thumb, index finger, and little finger while keeping the middle and ring fingers folded.",
            difficulty: .advanced,
            category: "Emotions",
            symbolName: "heart.fill",
            mediaPlaceholderName: nil
        ),
        GestureModel(
            id: GestureType.learn.id,
            type: .learn,
            englishName: "Learn",
            russianName: "Учиться",
            executionDescription: "Pick information from one palm with the fingertips and move it toward the forehead.",
            difficulty: .advanced,
            category: "Education",
            symbolName: "graduationcap.fill",
            mediaPlaceholderName: nil
        )
    ]

    static let lessons: [LessonModel] = [
        LessonModel(
            id: "basics-hello",
            title: "First Contact",
            subtitle: "Hello, Thank you, Please",
            gestureTypes: [.hello, .thankYou, .please],
            estimatedMinutes: 6,
            accentSymbolName: "sparkles"
        ),
        LessonModel(
            id: "answers-core",
            title: "Quick Answers",
            subtitle: "Yes, No, Good, Bad",
            gestureTypes: [.yes, .no, .good, .bad],
            estimatedMinutes: 8,
            accentSymbolName: "checkmark.seal.fill"
        ),
        LessonModel(
            id: "support-learning",
            title: "Support and Learning",
            subtitle: "Help, Learn, I love you",
            gestureTypes: [.help, .learn, .iLoveYou],
            estimatedMinutes: 10,
            accentSymbolName: "brain.head.profile"
        )
    ]

    static func gesture(for type: GestureType) -> GestureModel {
        gestures.first(where: { $0.type == type }) ?? gestures[0]
    }
}

