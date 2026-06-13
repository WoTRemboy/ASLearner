import Foundation

enum GestureRepository {
    static let gestures: [GestureModel] = [
        GestureModel(
            id: GestureType.hello.id,
            type: .hello,
            englishName: "Привет",
            russianName: "Привет",
            executionDescription: "Откройте ладонь у лба и мягко отведите руку наружу небольшой дугой.",
            difficulty: .beginner,
            category: "База",
            symbolName: "hand.wave.fill",
            mediaPlaceholderName: nil
        ),
        GestureModel(
            id: GestureType.thankYou.id,
            type: .thankYou,
            englishName: "Спасибо",
            russianName: "Спасибо",
            executionDescription: "Коснитесь подбородка кончиками пальцев и отведите руку вперёд ладонью вверх.",
            difficulty: .beginner,
            category: "База",
            symbolName: "hands.clap.fill",
            mediaPlaceholderName: nil
        ),
        GestureModel(
            id: GestureType.yes.id,
            type: .yes,
            englishName: "Да",
            russianName: "Да",
            executionDescription: "Сожмите кулак и слегка качните им вверх-вниз, как кивок головой.",
            difficulty: .beginner,
            category: "Ответы",
            symbolName: "checkmark.circle.fill",
            mediaPlaceholderName: nil
        ),
        GestureModel(
            id: GestureType.no.id,
            type: .no,
            englishName: "Нет",
            russianName: "Нет",
            executionDescription: "Дважды сведите указательный и средний пальцы с большим пальцем.",
            difficulty: .beginner,
            category: "Ответы",
            symbolName: "xmark.circle.fill",
            mediaPlaceholderName: nil
        ),
        GestureModel(
            id: GestureType.please.id,
            type: .please,
            englishName: "Пожалуйста",
            russianName: "Пожалуйста",
            executionDescription: "Положите открытую ладонь на грудь и сделайте небольшое круговое движение.",
            difficulty: .beginner,
            category: "Вежливость",
            symbolName: "heart.circle.fill",
            mediaPlaceholderName: nil
        ),
        GestureModel(
            id: GestureType.help.id,
            type: .help,
            englishName: "Помощь",
            russianName: "Помощь",
            executionDescription: "Поставьте кулак на открытую ладонь другой руки и поднимите обе руки вверх.",
            difficulty: .medium,
            category: "Быт",
            symbolName: "lifepreserver.fill",
            mediaPlaceholderName: nil
        ),
        GestureModel(
            id: GestureType.good.id,
            type: .good,
            englishName: "Хорошо",
            russianName: "Хорошо",
            executionDescription: "Проведите ровной ладонью от губ вниз к другой раскрытой ладони.",
            difficulty: .medium,
            category: "Оценка",
            symbolName: "hand.thumbsup.fill",
            mediaPlaceholderName: nil
        ),
        GestureModel(
            id: GestureType.bad.id,
            type: .bad,
            englishName: "Плохо",
            russianName: "Плохо",
            executionDescription: "Отведите ровную ладонь от рта и поверните её вниз.",
            difficulty: .medium,
            category: "Оценка",
            symbolName: "hand.thumbsdown.fill",
            mediaPlaceholderName: nil
        ),
        GestureModel(
            id: GestureType.iLoveYou.id,
            type: .iLoveYou,
            englishName: "Я люблю тебя",
            russianName: "Я люблю тебя",
            executionDescription: "Поднимите большой, указательный и мизинец, оставив средний и безымянный пальцы согнутыми.",
            difficulty: .advanced,
            category: "Эмоции",
            symbolName: "heart.fill",
            mediaPlaceholderName: nil
        ),
        GestureModel(
            id: GestureType.learn.id,
            type: .learn,
            englishName: "Учиться",
            russianName: "Учиться",
            executionDescription: "Как будто возьмите информацию с ладони кончиками пальцев и перенесите её ко лбу.",
            difficulty: .advanced,
            category: "Обучение",
            symbolName: "graduationcap.fill",
            mediaPlaceholderName: nil
        )
    ]

    static let lessons: [LessonModel] = [
        LessonModel(
            id: "basics-hello",
            title: "Первый контакт",
            subtitle: "Привет, спасибо, пожалуйста",
            gestureTypes: [.hello, .thankYou, .please],
            estimatedMinutes: 6,
            accentSymbolName: "sparkles"
        ),
        LessonModel(
            id: "answers-core",
            title: "Короткие ответы",
            subtitle: "Да, нет, хорошо, плохо",
            gestureTypes: [.yes, .no, .good, .bad],
            estimatedMinutes: 8,
            accentSymbolName: "checkmark.seal.fill"
        ),
        LessonModel(
            id: "support-learning",
            title: "Помощь и обучение",
            subtitle: "Помощь, учиться, я люблю тебя",
            gestureTypes: [.help, .learn, .iLoveYou],
            estimatedMinutes: 10,
            accentSymbolName: "brain.head.profile"
        )
    ]

    static func gesture(for type: GestureType) -> GestureModel {
        gestures.first(where: { $0.type == type }) ?? gestures[0]
    }
}
