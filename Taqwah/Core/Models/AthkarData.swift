import SwiftUI

// MARK: - Category

enum AthkarCategory: String, CaseIterable, Identifiable {
    case morning = "Morning"
    case evening = "Evening"
    case afterPrayer = "After Prayer"
    case sleep = "Before Sleep"
    case waking = "Upon Waking"
    case food = "Food & Drink"
    case travel = "Travel"

    var id: String { rawValue }

    var arabicTitle: String {
        switch self {
        case .morning: return "أذكار الصباح"
        case .evening: return "أذكار المساء"
        case .afterPrayer: return "أذكار بعد الصلاة"
        case .sleep: return "أذكار النوم"
        case .waking: return "أذكار الاستيقاظ"
        case .food: return "أذكار الطعام"
        case .travel: return "أذكار السفر"
        }
    }

    var icon: String {
        switch self {
        case .morning: return "sun.max.fill"
        case .evening: return "moon.fill"
        case .afterPrayer: return "clock.fill"
        case .sleep: return "bed.double.fill"
        case .waking: return "alarm.fill"
        case .food: return "fork.knife"
        case .travel: return "airplane"
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .morning:
            return [
                Color(red: 0.40, green: 0.20, blue: 0.70),
                Color(red: 0.75, green: 0.30, blue: 0.55)
            ]
        case .evening:
            return [
                Color(red: 0.95, green: 0.60, blue: 0.15),
                Color(red: 0.95, green: 0.45, blue: 0.20)
            ]
        case .afterPrayer:
            return [
                Color(red: 0.11, green: 0.23, blue: 0.22),
                Color(red: 0.09, green: 0.25, blue: 0.31)
            ]
        case .sleep:
            return [
                Color(red: 0.16, green: 0.18, blue: 0.45),
                Color(red: 0.08, green: 0.10, blue: 0.28)
            ]
        case .waking:
            return [
                Color(red: 0.95, green: 0.70, blue: 0.25),
                Color(red: 0.90, green: 0.50, blue: 0.30)
            ]
        case .food:
            return [
                Color(red: 0.20, green: 0.55, blue: 0.45),
                Color(red: 0.12, green: 0.40, blue: 0.35)
            ]
        case .travel:
            return [
                Color(red: 0.20, green: 0.50, blue: 0.75),
                Color(red: 0.15, green: 0.35, blue: 0.60)
            ]
        }
    }

    var athkar: [Dhikr] {
        AthkarDataSource.athkar(for: self)
    }
}

// MARK: - Dhikr Model

struct Dhikr: Identifiable {
    let id = UUID()
    let title: String
    let arabic: String
    let transliteration: String
    let translation: String
    let repetitions: Int
    let source: String
    let virtue: String?
    let category: AthkarCategory
}

// MARK: - Dhikr Extension

extension Dhikr {
    func forEvening() -> Dhikr {
        Dhikr(title: title, arabic: arabic, transliteration: transliteration,
              translation: translation, repetitions: repetitions, source: source,
              virtue: virtue, category: .evening)
    }
}

// MARK: - Data Source (Hisn al-Muslim)

enum AthkarDataSource {

    static func athkar(for category: AthkarCategory) -> [Dhikr] {
        switch category {
        case .morning: return morningAthkar
        case .evening: return eveningAthkar
        case .afterPrayer: return afterPrayerAthkar
        case .sleep: return sleepAthkar
        case .waking: return wakingAthkar
        case .food: return foodAthkar
        case .travel: return travelAthkar
        }
    }

    static let morningAthkar: [Dhikr] = [
        Dhikr(title: "Ayatul Kursi",
              arabic: "\u{0627}\u{0644}\u{0644}\u{0651}\u{0647}\u{064F} \u{0644}\u{0627} \u{0625}\u{0650}\u{0644}\u{0640}\u{0670}\u{0647}\u{064E} \u{0625}\u{0650}\u{0644}\u{0651}\u{0627} \u{0647}\u{064F}\u{0648}\u{064E} \u{0627}\u{0644}\u{0652}\u{062D}\u{064E}\u{064A}\u{0651}\u{064F} \u{0627}\u{0644}\u{0652}\u{0642}\u{064E}\u{064A}\u{0651}\u{064F}\u{0648}\u{0645}\u{064F}",
              transliteration: "Allahu la ilaha illa Huwal-Hayyul-Qayyum, la ta'khudhuhu sinatun wa la nawm...",
              translation: "Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep.",
              repetitions: 1, source: "Quran 2:255", virtue: nil, category: .morning),
        Dhikr(title: "Surah Al-Ikhlas",
              arabic: "قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ",
              transliteration: "Qul Huwal-lahu Ahad. Allahus-Samad. Lam yalid wa lam yulad. Wa lam yakul-lahu kufuwan ahad.",
              translation: "Say, He is Allah, the One. Allah, the Eternal Refuge. He neither begets nor is born. Nor is there to Him any equivalent.",
              repetitions: 3, source: "Quran 112:1-4", virtue: nil, category: .morning),
        Dhikr(title: "Surah Al-Falaq",
              arabic: "قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِن شَرِّ مَا خَلَقَ ۝ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ",
              transliteration: "Qul a'udhu bi-Rabbil-falaq. Min sharri ma khalaq. Wa min sharri ghasiqin idha waqab...",
              translation: "Say, I seek refuge in the Lord of daybreak. From the evil of that which He created.",
              repetitions: 3, source: "Quran 113:1-5", virtue: nil, category: .morning),
        Dhikr(title: "Surah An-Nas",
              arabic: "قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ",
              transliteration: "Qul a'udhu bi-Rabbin-nas. Malikin-nas. Ilahin-nas. Min sharril-waswasil-khannas...",
              translation: "Say, I seek refuge in the Lord of mankind. The Sovereign of mankind. The God of mankind.",
              repetitions: 3, source: "Quran 114:1-6", virtue: nil, category: .morning),
        Dhikr(title: "Morning Sovereignty",
              arabic: "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
              transliteration: "Asbahna wa asbahal-mulku lillah, walhamdu lillah, la ilaha illallahu wahdahu la sharika lah...",
              translation: "We have reached the morning and at this time all sovereignty belongs to Allah. None has the right to be worshipped except Allah, alone.",
              repetitions: 1, source: "Sahih Muslim 2723", virtue: nil, category: .morning),
        Dhikr(title: "Morning Supplication",
              arabic: "اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ",
              transliteration: "Allahumma bika asbahna, wa bika amsayna, wa bika nahya, wa bika namutu, wa ilaykan-nushur.",
              translation: "O Allah, by You we enter the morning, by You we live and by You we die, and to You is the resurrection.",
              repetitions: 1, source: "Sunan at-Tirmidhi 3391", virtue: nil, category: .morning),
        Dhikr(title: "Sayyid al-Istighfar",
              arabic: "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ",
              transliteration: "Allahumma Anta Rabbi la ilaha illa Anta, khalaqtani wa ana 'abduka, wa ana 'ala 'ahdika wa wa'dika mastata'tu...",
              translation: "O Allah, You are my Lord. You created me and I am Your servant, and I abide by Your covenant as best I can. I seek refuge in You from the evil of what I have done. Forgive me.",
              repetitions: 1, source: "Sahih al-Bukhari 6306",
              virtue: "Whoever says it with firm faith in the morning and dies before evening will be among the people of Paradise.", category: .morning),
        Dhikr(title: "Bearing Witness",
              arabic: "اللَّهُمَّ إِنِّي أَصْبَحْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلَائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللَّهُ لَا إِلَهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ، وَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ",
              transliteration: "Allahumma inni asbahtu ush-hiduka, wa ush-hidu hamalata 'arshika...",
              translation: "O Allah, I have reached the morning and call on You, the bearers of Your throne, Your angels, and all creation to witness that You are Allah.",
              repetitions: 4, source: "Sunan Abu Dawud 5069", virtue: nil, category: .morning),
        Dhikr(title: "Acknowledging Blessings",
              arabic: "اللَّهُمَّ مَا أَصْبَحَ بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ",
              transliteration: "Allahumma ma asbaha bi min ni'matin aw bi-ahadin min khalqika faminka wahdaka la sharika lak...",
              translation: "O Allah, what blessing I or any of Your creation have risen upon, is from You alone. For You is all praise and thanks.",
              repetitions: 1, source: "Sunan Abu Dawud 5073", virtue: nil, category: .morning),
        Dhikr(title: "Ya Hayyu Ya Qayyum",
              arabic: "يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ",
              transliteration: "Ya Hayyu ya Qayyum, bi-rahmatika astaghith, aslih li sha'ni kullahu, wa la takilni ila nafsi tarfata 'ayn.",
              translation: "O Ever-Living, O Self-Sustaining, in Your mercy I seek relief, rectify all my affairs, and do not leave me to myself even for the blink of an eye.",
              repetitions: 1, source: "Mustadrak al-Hakim", virtue: nil, category: .morning),
        Dhikr(title: "Seeking Well-being",
              arabic: "اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَهَ إِلَّا أَنْتَ",
              transliteration: "Allahumma 'afini fi badani, Allahumma 'afini fi sam'i, Allahumma 'afini fi basari, la ilaha illa Anta...",
              translation: "O Allah, grant me health in my body, hearing, and sight. I seek refuge in You from disbelief and poverty.",
              repetitions: 3, source: "Sunan Abu Dawud 5090", virtue: nil, category: .morning),
        Dhikr(title: "Protection with Allah's Name",
              arabic: "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ",
              transliteration: "Bismillahilladhi la yadurru ma'asmihi shay'un fil-ardi wa la fis-sama'i wa Huwas-Sami'ul-'Alim.",
              translation: "In the name of Allah with whose name nothing on earth or in the heavens can cause harm, and He is the All-Hearing, the All-Knowing.",
              repetitions: 3, source: "Sunan Abu Dawud 5088", virtue: nil, category: .morning),
        Dhikr(title: "Contentment with Allah",
              arabic: "رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا",
              transliteration: "Raditu billahi Rabba, wa bil-Islami dina, wa bi-Muhammadin sallallahu 'alayhi wa sallama nabiyya.",
              translation: "I am pleased with Allah as my Lord, with Islam as my religion, and with Muhammad (peace be upon him) as my Prophet.",
              repetitions: 3, source: "Sunan Abu Dawud 5072", virtue: nil, category: .morning),
        Dhikr(title: "Refuge in Perfect Words",
              arabic: "أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ",
              transliteration: "A'udhu bi-kalimatillahit-tammati min sharri ma khalaq.",
              translation: "I seek refuge in the perfect words of Allah from the evil of what He has created.",
              repetitions: 3, source: "Sahih Muslim 2709", virtue: nil, category: .morning),
        Dhikr(title: "Hasbiyallah",
              arabic: "حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ",
              transliteration: "Hasbiyallahu la ilaha illa Huwa, 'alayhi tawakkaltu wa Huwa Rabbul-'Arshil-'Adhim.",
              translation: "Allah is sufficient for me; there is no god but He. Upon Him I have relied, and He is the Lord of the Mighty Throne.",
              repetitions: 7, source: "Quran 9:129", virtue: nil, category: .morning),
        Dhikr(title: "Tahlil",
              arabic: "لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
              transliteration: "La ilaha illallahu wahdahu la sharika lah, lahul-mulku wa lahul-hamdu, wa Huwa 'ala kulli shay'in qadir.",
              translation: "None has the right to be worshipped except Allah, alone, without partner. To Him belongs all sovereignty and praise.",
              repetitions: 100, source: "Sahih al-Bukhari 3293",
              virtue: "Equivalent to freeing 10 slaves, 100 good deeds, 100 sins erased.", category: .morning),
        Dhikr(title: "SubhanAllah wa bihamdihi",
              arabic: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ",
              transliteration: "SubhanAllahi wa bihamdihi.",
              translation: "Glory is to Allah and praise is to Him.",
              repetitions: 100, source: "Sahih Muslim 2692",
              virtue: "No one will come with better deeds except one who says the same or more.", category: .morning),
        Dhikr(title: "Istighfar",
              arabic: "أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ",
              transliteration: "Astaghfirullaha wa atubu ilayh.",
              translation: "I seek Allah's forgiveness and turn to Him in repentance.",
              repetitions: 100, source: "Sahih al-Bukhari 6307", virtue: nil, category: .morning),
    ]

    // MARK: - Evening Athkar

    static var eveningAthkar: [Dhikr] {
        var list: [Dhikr] = []
        // 1-4: Same Quran surahs
        list.append(contentsOf: morningAthkar[0...3].map { $0.forEvening() })
        // 5: Evening variant
        list.append(Dhikr(title: "Evening Sovereignty",
              arabic: "أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
              transliteration: "Amsayna wa amsal-mulku lillah, walhamdu lillah, la ilaha illallahu wahdahu la sharika lah...",
              translation: "We have reached the evening and at this time all sovereignty belongs to Allah.",
              repetitions: 1, source: "Sahih Muslim 2723", virtue: nil, category: .evening))
        // 6: Evening variant
        list.append(Dhikr(title: "Evening Supplication",
              arabic: "اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ",
              transliteration: "Allahumma bika amsayna, wa bika asbahna, wa bika nahya, wa bika namutu, wa ilaykal-masir.",
              translation: "O Allah, by You we enter the evening, by You we live and by You we die, and to You is the final return.",
              repetitions: 1, source: "Sunan at-Tirmidhi 3391", virtue: nil, category: .evening))
        // 7: Same Sayyid al-Istighfar
        list.append(morningAthkar[6].forEvening())
        // 8: Evening variant
        list.append(Dhikr(title: "Bearing Witness",
              arabic: "اللَّهُمَّ إِنِّي أَمْسَيْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلَائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللَّهُ لَا إِلَهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ، وَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ",
              transliteration: "Allahumma inni amsaytu ush-hiduka...",
              translation: "O Allah, I have reached the evening and call on You, the bearers of Your throne, Your angels to witness.",
              repetitions: 4, source: "Sunan Abu Dawud 5069", virtue: nil, category: .evening))
        // 9: Evening variant
        list.append(Dhikr(title: "Acknowledging Blessings",
              arabic: "اللَّهُمَّ مَا أَمْسَى بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ",
              transliteration: "Allahumma ma amsa bi min ni'matin...",
              translation: "O Allah, what blessing I or any of Your creation have reached this evening upon, is from You alone.",
              repetitions: 1, source: "Sunan Abu Dawud 5073", virtue: nil, category: .evening))
        // 10-18: Same as morning
        list.append(contentsOf: morningAthkar[9...17].map { $0.forEvening() })
        return list
    }

    // MARK: - After Prayer Athkar

    static let afterPrayerAthkar: [Dhikr] = [
        Dhikr(title: "Istighfar", arabic: "أَسْتَغْفِرُ اللَّهَ", transliteration: "Astaghfirullah.", translation: "I seek the forgiveness of Allah.", repetitions: 3, source: "Sahih Muslim 591", virtue: nil, category: .afterPrayer),
        Dhikr(title: "Seeking Peace", arabic: "اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ", transliteration: "Allahumma Antas-Salam, wa minkas-salam, tabarakta ya Dhal-Jalali wal-Ikram.", translation: "O Allah, You are As-Salam and from You comes peace. Blessed are You, O Possessor of Majesty and Honor.", repetitions: 1, source: "Sahih Muslim 591", virtue: nil, category: .afterPrayer),
        Dhikr(title: "Tahlil", arabic: "لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، اللَّهُمَّ لَا مَانِعَ لِمَا أَعْطَيْتَ وَلَا مُعْطِيَ لِمَا مَنَعْتَ وَلَا يَنْفَعُ ذَا الْجَدِّ مِنْكَ الْجَدُّ", transliteration: "La ilaha illallahu wahdahu la sharika lah...", translation: "None has the right to be worshipped except Allah. O Allah, none can prevent what You bestow.", repetitions: 1, source: "Sahih al-Bukhari 844", virtue: nil, category: .afterPrayer),
        Dhikr(title: "Tasbih, Tahmid, Takbir", arabic: "سُبْحَانَ اللَّهِ (٣٣) الْحَمْدُ لِلَّهِ (٣٣) اللَّهُ أَكْبَرُ (٣٣) ثم: لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ", transliteration: "SubhanAllah (33x), Alhamdulillah (33x), Allahu Akbar (33x), then Tahlil.", translation: "Glory be to Allah (33x), All praise to Allah (33x), Allah is Greatest (33x), then Tahlil once = 100.", repetitions: 100, source: "Sahih Muslim 597", virtue: "Sins forgiven even if they were like the foam of the sea.", category: .afterPrayer),
        Dhikr(title: "Ayatul Kursi", arabic: "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...", transliteration: "Allahu la ilaha illa Huwal-Hayyul-Qayyum...", translation: "Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence.", repetitions: 1, source: "an-Nasa'i, Sahih", virtue: "Nothing prevents him from entering Paradise except death.", category: .afterPrayer),
        Dhikr(title: "Three Quls", arabic: "قُلْ هُوَ اللَّهُ أَحَدٌ... قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ... قُلْ أَعُوذُ بِرَبِّ النَّاسِ...", transliteration: "Qul Huwal-lahu Ahad... Qul a'udhu bi-Rabbil-falaq... Qul a'udhu bi-Rabbin-nas...", translation: "Recite Surah Al-Ikhlas, Al-Falaq, and An-Nas after every prayer.", repetitions: 1, source: "Sunan Abu Dawud 1523", virtue: nil, category: .afterPrayer),
        Dhikr(title: "Help in Worship", arabic: "اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ", transliteration: "Allahumma a'inni 'ala dhikrika wa shukrika wa husni 'ibadatik.", translation: "O Allah, help me in remembering You, being grateful to You, and worshipping You in the best of manners.", repetitions: 1, source: "Sunan Abu Dawud 1522", virtue: nil, category: .afterPrayer),
        Dhikr(title: "Seeking Refuge", arabic: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ، وَأَعُوذُ بِكَ مِنْ فِتْنَةِ الْمَسِيحِ الدَّجَّالِ، وَأَعُوذُ بِكَ مِنْ فِتْنَةِ الْمَحْيَا وَفِتْنَةِ الْمَمَاتِ", transliteration: "Allahumma inni a'udhu bika min 'adhabil-qabr, wa min fitnatil-masihid-dajjal...", translation: "O Allah, I seek refuge in You from the punishment of the grave, the trial of the False Messiah, and the trials of life and death.", repetitions: 1, source: "Sahih al-Bukhari 832", virtue: nil, category: .afterPrayer),
    ]

    // MARK: - Before Sleep Athkar

    static let sleepAthkar: [Dhikr] = [
        Dhikr(title: "In Your Name",
              arabic: "بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا",
              transliteration: "Bismika Allahumma amutu wa ahya.",
              translation: "In Your name, O Allah, I die and I live.",
              repetitions: 1, source: "Sahih al-Bukhari 6324", virtue: nil, category: .sleep),
        Dhikr(title: "Tasbih of Fatimah",
              arabic: "سُبْحَانَ اللَّهِ (٣٣) الْحَمْدُ لِلَّهِ (٣٣) اللَّهُ أَكْبَرُ (٣٤)",
              transliteration: "SubhanAllah (33x), Alhamdulillah (33x), Allahu Akbar (34x).",
              translation: "Glory be to Allah (33), all praise to Allah (33), Allah is the Greatest (34).",
              repetitions: 1, source: "Sahih al-Bukhari 5362",
              virtue: "Better for you than a servant.", category: .sleep),
        Dhikr(title: "Entrusting the Soul",
              arabic: "اللَّهُمَّ أَسْلَمْتُ نَفْسِي إِلَيْكَ، وَفَوَّضْتُ أَمْرِي إِلَيْكَ، وَأَلْجَأْتُ ظَهْرِي إِلَيْكَ، رَغْبَةً وَرَهْبَةً إِلَيْكَ، لَا مَلْجَأَ وَلَا مَنْجَا مِنْكَ إِلَّا إِلَيْكَ، آمَنْتُ بِكِتَابِكَ الَّذِي أَنْزَلْتَ، وَبِنَبِيِّكَ الَّذِي أَرْسَلْتَ",
              transliteration: "Allahumma aslamtu nafsi ilayk, wa fawwadtu amri ilayk...",
              translation: "O Allah, I submit myself to You, entrust my affairs to You, and rely upon You, in hope and fear of You. There is no refuge or escape from You except to You. I believe in Your Book which You revealed and Your Prophet whom You sent.",
              repetitions: 1, source: "Sahih al-Bukhari 247",
              virtue: "If you die that night, you die upon the fitrah.", category: .sleep),
        Dhikr(title: "Ayatul Kursi",
              arabic: "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...",
              transliteration: "Allahu la ilaha illa Huwal-Hayyul-Qayyum...",
              translation: "Recite Ayatul Kursi — a protector will remain with you and no devil will come near until morning.",
              repetitions: 1, source: "Sahih al-Bukhari 2311", virtue: nil, category: .sleep),
        Dhikr(title: "The Three Quls",
              arabic: "قُلْ هُوَ اللَّهُ أَحَدٌ … قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ … قُلْ أَعُوذُ بِرَبِّ النَّاسِ",
              transliteration: "Qul Huwallahu Ahad … Qul a'udhu bi-Rabbil-falaq … Qul a'udhu bi-Rabbin-nas.",
              translation: "Recite Al-Ikhlas, Al-Falaq and An-Nas, blow into the palms and wipe over the body.",
              repetitions: 3, source: "Sahih al-Bukhari 5017", virtue: nil, category: .sleep),
    ]

    // MARK: - Upon Waking Athkar

    static let wakingAthkar: [Dhikr] = [
        Dhikr(title: "Praise on Waking",
              arabic: "الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ",
              transliteration: "Alhamdu lillahil-ladhi ahyana ba'da ma amatana wa ilayhin-nushur.",
              translation: "All praise is for Allah who gave us life after death (sleep), and to Him is the resurrection.",
              repetitions: 1, source: "Sahih al-Bukhari 6312", virtue: nil, category: .waking),
        Dhikr(title: "No god but Allah",
              arabic: "لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ",
              transliteration: "La ilaha illallahu wahdahu la sharika lah... wa la hawla wa la quwwata illa billah.",
              translation: "None has the right to be worshipped but Allah alone... There is no might nor power except with Allah. (Whoever says this and then supplicates, his prayer is answered.)",
              repetitions: 1, source: "Sahih al-Bukhari 1154", virtue: nil, category: .waking),
        Dhikr(title: "Restored Health",
              arabic: "الْحَمْدُ لِلَّهِ الَّذِي عَافَانِي فِي جَسَدِي، وَرَدَّ عَلَيَّ رُوحِي، وَأَذِنَ لِي بِذِكْرِهِ",
              transliteration: "Alhamdu lillahil-ladhi 'afani fi jasadi, wa radda 'alayya ruhi, wa adhina li bi-dhikrih.",
              translation: "Praise is to Allah who restored my health, returned my soul, and permitted me to remember Him.",
              repetitions: 1, source: "Sunan at-Tirmidhi 3401", virtue: nil, category: .waking),
    ]

    // MARK: - Food & Drink Athkar

    static let foodAthkar: [Dhikr] = [
        Dhikr(title: "Before Eating",
              arabic: "بِسْمِ اللَّهِ",
              transliteration: "Bismillah.",
              translation: "In the name of Allah. (If forgotten, say: Bismillahi awwalahu wa akhirah.)",
              repetitions: 1, source: "Sunan Abu Dawud 3767", virtue: nil, category: .food),
        Dhikr(title: "After Eating",
              arabic: "الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ",
              transliteration: "Alhamdu lillahil-ladhi at'amani hadha wa razaqanihi min ghayri hawlin minni wa la quwwah.",
              translation: "Praise is to Allah who fed me this and provided it for me without any might or power on my part.",
              repetitions: 1, source: "Sunan at-Tirmidhi 3458",
              virtue: "His past sins are forgiven.", category: .food),
        Dhikr(title: "Du'a for the Host",
              arabic: "اللَّهُمَّ بَارِكْ لَهُمْ فِيمَا رَزَقْتَهُمْ، وَاغْفِرْ لَهُمْ وَارْحَمْهُمْ",
              transliteration: "Allahumma barik lahum fima razaqtahum, waghfir lahum warhamhum.",
              translation: "O Allah, bless for them what You have provided them, forgive them and have mercy on them.",
              repetitions: 1, source: "Sahih Muslim 2042", virtue: nil, category: .food),
    ]

    // MARK: - Travel Athkar

    static let travelAthkar: [Dhikr] = [
        Dhikr(title: "Mounting the Ride",
              arabic: "سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ، وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ",
              transliteration: "Subhanal-ladhi sakhkhara lana hadha wa ma kunna lahu muqrinin, wa inna ila Rabbina lamunqalibun.",
              translation: "Glory to Him who has subjected this to us, and we could never have it (by our efforts). Surely, to our Lord we are returning.",
              repetitions: 1, source: "Sahih Muslim 1342", virtue: nil, category: .travel),
        Dhikr(title: "Travel Supplication",
              arabic: "اللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَذَا الْبِرَّ وَالتَّقْوَى، وَمِنَ الْعَمَلِ مَا تَرْضَى، اللَّهُمَّ هَوِّنْ عَلَيْنَا سَفَرَنَا هَذَا وَاطْوِ عَنَّا بُعْدَهُ",
              transliteration: "Allahumma inna nas'aluka fi safarina hadhal-birra wat-taqwa...",
              translation: "O Allah, we ask You on this journey for righteousness, piety, and deeds that please You. O Allah, make this journey easy for us and fold up its distance.",
              repetitions: 1, source: "Sahih Muslim 1342", virtue: nil, category: .travel),
        Dhikr(title: "Entering a Town",
              arabic: "اللَّهُمَّ رَبَّ السَّمَاوَاتِ السَّبْعِ وَمَا أَظْلَلْنَ... أَسْأَلُكَ خَيْرَ هَذِهِ الْقَرْيَةِ وَخَيْرَ أَهْلِهَا، وَأَعُوذُ بِكَ مِنْ شَرِّهَا وَشَرِّ أَهْلِهَا",
              transliteration: "Allahumma Rabbas-samawatis-sab'i wa ma azlalna... as'aluka khayra hadhihil-qaryah...",
              translation: "O Allah, Lord of the seven heavens and all they overshadow... I ask You for the good of this town and its people, and seek refuge in You from its evil and the evil of its people.",
              repetitions: 1, source: "Sunan an-Nasa'i (al-Kubra)", virtue: nil, category: .travel),
        Dhikr(title: "Stopping at a Place",
              arabic: "أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ",
              transliteration: "A'udhu bi-kalimatillahit-tammati min sharri ma khalaq.",
              translation: "I seek refuge in the perfect words of Allah from the evil of what He created. (Nothing will harm him until he leaves.)",
              repetitions: 1, source: "Sahih Muslim 2708", virtue: nil, category: .travel),
    ]
}
