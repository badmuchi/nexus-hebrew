import json

new_nodes = [
    # ==========================================
    # СЦЕНАРИЙ 4: В аптеке (בְּבֵית מִרְקַחַת)
    # ==========================================
    {
        "id": "node_pharmacy_start",
        "speaker_hebrew": "רוֹקֵחַ",
        "speaker_russian": "Провизор",
        "line_hebrew": "שָׁלוֹם! בַּמֶּה אֶפְשָׁר לַעֲזֹר לְךָ הַיּוֹם?",
        "line_russian": "Здравствуйте! Чем я могу помочь вам сегодня?",
        "audio_path": None,
        "options": [
            {
                "id": "opt_pharmacy_headache",
                "text_hebrew": "יֵשׁ לְךָ מַשֶּׁהוּ טוֹב נֶגֶד כְּאֵב רֹאשׁ חָזָק?",
                "text_russian": "Есть что-то хорошее от сильной головной боли?",
                "next_node_id": "node_pharmacy_headache",
                "binyan": "none",
                "root": "כ-א-ב"
            },
            {
                "id": "opt_pharmacy_firstaid",
                "text_hebrew": "אֲנִי צָרִיךְ פְּלַסְטֶרִים וְתַרְסִיס חִטּוּי",
                "text_russian": "Мне нужны пластыри и антисептический спрей",
                "next_node_id": "node_pharmacy_firstaid",
                "binyan": "piel",
                "root": "ח-ט-א"
            },
            {
                "id": "opt_pharmacy_vitamins",
                "text_hebrew": "אֶפְשָׁר כַּדּוּרֵי מְצִיצָה לַגָּרוֹן וְוִיטָמִינִים?",
                "text_russian": "Можно леденцы для горла и витамины?",
                "next_node_id": "node_pharmacy_instructions",
                "binyan": "paal",
                "root": "מ-צ-ץ"
            }
        ]
    },
    {
        "id": "node_pharmacy_headache",
        "speaker_hebrew": "רוֹקֵחַ",
        "speaker_russian": "Провизор",
        "line_hebrew": "בֶּטַח! יֵשׁ לָנוּ אָקָמוֹל, נורופן וְאוֹפּטַלְגִּין. אַתָּה רָגִישׁ לִתְרוּפָה כָּלְשֶׁהִי?",
        "line_russian": "Конечно! У нас есть Акамоль, Нурофен и Оптальгин. У вас есть аллергия на какие-то лекарства?",
        "audio_path": None,
        "options": [
            {
                "id": "opt_headache_acamol",
                "text_hebrew": "לֹא, אֵין רְגִישׁוּת. אֲנִי אַעֲדִיף אָקָמוֹל. כֵּיצַד לָקַחַת?",
                "text_russian": "Нет, аллергии нет. Я предпочту Акамоль. Как принимать?",
                "next_node_id": "node_pharmacy_instructions",
                "binyan": "hifil",
                "root": "ע-ד-ף"
            },
            {
                "id": "opt_headache_nurofen",
                "text_hebrew": "אֶקַּח חֲבִילָה אַחַת שֶׁל נוּרוֹפֶן, תּוֹדָה",
                "text_russian": "Возьму одну упаковку Нурофена, спасибо",
                "next_node_id": "node_pharmacy_checkout",
                "binyan": "paal",
                "root": "ל-ק-ח"
            }
        ]
    },
    {
        "id": "node_pharmacy_firstaid",
        "speaker_hebrew": "רוֹקֵחַ",
        "speaker_russian": "Провизор",
        "line_hebrew": "הִנֵּה פְּלַסְטֶרִים עֲמִידִים בְּמַיִם וְתַרְסִיס אֵיכוּתִי לְחִטּוּי פְּצָעִים.",
        "line_russian": "Вот водостойкие пластыри и качественный спрей для дезинфекции ран.",
        "audio_path": None,
        "options": [
            {
                "id": "opt_firstaid_accept",
                "text_hebrew": "מְצֻיָּן, זֶה בְּדִיּוּק מָה שֶׁחִפַּשְׂתִּי. תּוֹדָה רַבָּה!",
                "text_russian": "Отлично, это ровно то, что я искал. Большое спасибо!",
                "next_node_id": "node_pharmacy_checkout",
                "binyan": "piel",
                "root": "ח-פ-ש"
            }
        ]
    },
    {
        "id": "node_pharmacy_instructions",
        "speaker_hebrew": "רוֹקֵחַ",
        "speaker_russian": "Провизор",
        "line_hebrew": "קַח כַּדּוּר אֶחָד כָּל שֵׁשׁ שָׁעוֹת אַחֲרֵי הָאֹכֶל, לֹא יוֹתֵר מֵאַרְבָּעָה בַּיּוֹם.",
        "line_russian": "Принимайте одну таблетку каждые 6 часов после еды, не больше четырех в день.",
        "audio_path": None,
        "options": [
            {
                "id": "opt_instructions_understood",
                "text_hebrew": "הֵבַנְתִּי מְצֻיָּן. כַּמָּה הַכֹּל יַחַד?",
                "text_russian": "Я отлично понял. Сколько все вместе?",
                "next_node_id": "node_pharmacy_checkout",
                "binyan": "hifil",
                "root": "ב-י-ן"
            }
        ]
    },
    {
        "id": "node_pharmacy_checkout",
        "speaker_hebrew": "רוֹקֵחַ",
        "speaker_russian": "Провизор",
        "line_hebrew": "סַךְ הַכֹּל שְׁלוֹשִׁים וְשִׁשָּׁה שְׁקָלִים. מְשַׁלֵּם בְּאַשְׁרַאי? שֶׁתִּהְיֶה רְפוּאָה שְׁלֵמָה!",
        "line_russian": "Всего 36 шекелей. Оплата картой? Скорейшего выздоровления!",
        "audio_path": None,
        "options": [
            {
                "id": "opt_pharmacy_pay",
                "text_hebrew": "כֵּן, בְּאַשְׁרַאי. תּוֹדָה רַבָּה עַל הַשֵּׁרוּת הַמְּעֻלֶּה!",
                "text_russian": "Да, картой. Большое спасибо за отличный сервис!",
                "next_node_id": "node_pharmacy_start",
                "binyan": "none",
                "root": "ש-ר-ת"
            }
        ]
    },

    # ==========================================
    # СЦЕНАРИЙ 5: Заселение в отель (בַּמָּלוֹן)
    # ==========================================
    {
        "id": "node_hotel_start",
        "speaker_hebrew": "פְּקִיד קַבָּלָה",
        "speaker_russian": "Портье на ресепшене",
        "line_hebrew": "שָׁלוֹם וּבְרוּכִים הַבָּאִים לַמָּלוֹן! יֵשׁ לָכֶם הַזְמָנָה?",
        "line_russian": "Здравствуйте и добро пожаловать в отель! У вас есть бронь?",
        "audio_path": None,
        "options": [
            {
                "id": "opt_hotel_booked",
                "text_hebrew": "כֵּן, הַזְמַנְתִּי חֶדֶר לִשְׁלוֹשָׁה לֵילוֹת עַל שֵׁם דָּוִד",
                "text_russian": "Да, я забронировал номер на 3 ночи на имя Давид",
                "next_node_id": "node_hotel_checkin",
                "binyan": "hifil",
                "root": "ז-מ-ן"
            },
            {
                "id": "opt_hotel_ask_room",
                "text_hebrew": "אֵין לִי הַזְמָנָה, הַאִם יֵשׁ חֶדֶר פָּנוּי עִם נוֹף לַיָּם?",
                "text_russian": "У меня нет брони, есть ли свободный номер с видом на море?",
                "next_node_id": "node_hotel_availability",
                "binyan": "paal",
                "root": "פ-נ-ה"
            }
        ]
    },
    {
        "id": "node_hotel_checkin",
        "speaker_hebrew": "פְּקִיד קַבָּלָה",
        "speaker_russian": "Портье на ресепшене",
        "line_hebrew": "מָצָאתִי אֶת הַהַזְמָנָה! אֶפְשָׁר דַּרְכּוֹן וְכַרְטִיס אַשְׁרַאי לְפִקָּדוֹן?",
        "line_russian": "Нашел вашу бронь! Можно паспорт и кредитную карту для залога?",
        "audio_path": None,
        "options": [
            {
                "id": "opt_checkin_passport",
                "text_hebrew": "בְּוַדַּאי, הִנֵּה הַדַּרְכּוֹן וְהַכַּרְטִיס שֶׁלִּי",
                "text_russian": "Разумеется, вот мой паспорт и карта",
                "next_node_id": "node_hotel_key",
                "binyan": "none",
                "root": None
            }
        ]
    },
    {
        "id": "node_hotel_availability",
        "speaker_hebrew": "פְּקִיד קַבָּלָה",
        "speaker_russian": "Портье на ресепшене",
        "line_hebrew": "יֵשׁ לָנוּ חֶדֶר דֵּלַקְס נִפְלָא בַּקּוֹמָה הַחֲמִישִׁית עִם מִרְפֶּסֶת מוּל הַחוֹף.",
        "line_russian": "У нас есть замечательный номер делюкс на 5-м этаже с балконом напротив пляжа.",
        "audio_path": None,
        "options": [
            {
                "id": "opt_avail_take",
                "text_hebrew": "נִשְׁמָע חֲלוֹמִי, אֲנִי לוֹקֵחַ אוֹתוֹ!",
                "text_russian": "Звучит великолепно, я беру его!",
                "next_node_id": "node_hotel_key",
                "binyan": "paal",
                "root": "ל-ק-ח"
            }
        ]
    },
    {
        "id": "node_hotel_key",
        "speaker_hebrew": "פְּקִיד קַבָּלָה",
        "speaker_russian": "Портье на ресепшене",
        "line_hebrew": "הִנֵּה הַכַּרְטִיס לְחֶדֶר 504. סִיסְמַת הָאִינְטֶרְנֶט הִיא Welcome2026. אֲרוּחַת בֹּקֶר בֵּין שֶׁבַע לְעֶשֶׂר.",
        "line_russian": "Вот ключ-карта от номера 504. Пароль от Wi-Fi — Welcome2026. Завтрак с 7:00 до 10:00.",
        "audio_path": None,
        "options": [
            {
                "id": "opt_key_elevator",
                "text_hebrew": "תּוֹדָה! מֵאֵיפֹה עוֹלִים לַמַּעֲלִית?",
                "text_russian": "Спасибо! Откуда подниматься на лифте?",
                "next_node_id": "node_hotel_finish",
                "binyan": "paal",
                "root": "ע-ל-ה"
            },
            {
                "id": "opt_key_pool",
                "text_hebrew": "עַד אֵיזוֹ שָׁעָה הַבְּרֵכָה פְּתוּחָה?",
                "text_russian": "До скольки часов открыт бассейн?",
                "next_node_id": "node_hotel_finish",
                "binyan": "paal",
                "root": "פ-ת-ח"
            }
        ]
    },
    {
        "id": "node_hotel_finish",
        "speaker_hebrew": "פְּקִיד קַבָּלָה",
        "speaker_russian": "Портье на ресепшене",
        "line_hebrew": "הַמַּעֲלִית מִיָּמִין, וְהַבְּרֵכָה עַד שְׁמוֹנֶה בָּעֶרֶב. שֶׁתִּהְיֶה לָכֶם שְׁהִיָּה נְעִימָה וּמַהֲנָה!",
        "line_russian": "Лифт справа, а бассейн до 8 вечера. Приятного и радостного вам отдыха!",
        "audio_path": None,
        "options": [
            {
                "id": "opt_hotel_restart",
                "text_hebrew": "תּוֹדָה רַבָּה עַל כָּל הַהֶסְבֵּרִים, שָׁלוֹם!",
                "text_russian": "Большое спасибо за все объяснения, до свидания!",
                "next_node_id": "node_hotel_start",
                "binyan": "none",
                "root": "ס-ב-ר"
            }
        ]
    },

    # ==========================================
    # СЦЕНАРИЙ 6: Знакомство в ульпане (הֶכֵּרוּת בָּאֻלְפָּן)
    # ==========================================
    {
        "id": "node_meet_start",
        "speaker_hebrew": "יוֹסִי",
        "speaker_russian": "Йоси",
        "line_hebrew": "הַי! נָעִים מְאֹד, אֲנִי יוֹסִי. אַתָּה הַתַּלְמִיד הֶחָדָשׁ בָּאֻלְפָּן?",
        "line_russian": "Привет! Очень приятно, я Йоси. Ты новый ученик в ульпане?",
        "audio_path": None,
        "options": [
            {
                "id": "opt_meet_newbie",
                "text_hebrew": "שָׁלוֹם יוֹסִי, נָעִים מְאֹד! כֵּן, הִתְחַלְתִּי לִלְמֹד פֹּה הַשָּׁבוּעַ",
                "text_russian": "Шалом Йоси, приятно познакомиться! Да, я начал учиться тут на этой неделе",
                "next_node_id": "node_meet_origin",
                "binyan": "hitpael",
                "root": "ת-ח-ל"
            },
            {
                "id": "opt_meet_hebrew_time",
                "text_hebrew": "נָעִים מְאֹד! אֲנִי לוֹמֵד עִבְרִית כְּבָר חֲצִי שָׁנָה",
                "text_russian": "Очень приятно! Я учу иврит уже полгода",
                "next_node_id": "node_meet_hebrew",
                "binyan": "paal",
                "root": "ל-מ-ד"
            }
        ]
    },
    {
        "id": "node_meet_origin",
        "speaker_hebrew": "יוֹסִי",
        "speaker_russian": "Йоси",
        "line_hebrew": "אֵיזֶה יֹפִי! מֵאֵיזוֹ מְדִינָה הִגַּעְתָּ לְיִשְׂרָאֵל, וְאֵיפֹה אַתָּה גָּר עַכְשָׁו?",
        "line_russian": "Здорово! Из какой страны ты приехал в Израиль, и где живешь сейчас?",
        "audio_path": None,
        "options": [
            {
                "id": "opt_origin_city",
                "text_hebrew": "עָלִיתִי מֵאֵירוֹפָּה, וְכַיּוֹם אֲנִי גָּר בְּתֵל אָבִיב לְיַד הַיָּם",
                "text_russian": "Я репатриировался из Европы, сейчас живу в Тель-Авиве возле моря",
                "next_node_id": "node_meet_profession",
                "binyan": "paal",
                "root": "ע-ל-ה"
            }
        ]
    },
    {
        "id": "node_meet_hebrew",
        "speaker_hebrew": "יוֹסִי",
        "speaker_russian": "Йоси",
        "line_hebrew": "וָאוּ, הָעִבְרִית שֶׁלְּךָ מַמָּשׁ טוֹבָה! בַּמֶּה אַתָּה עוֹבֵד?",
        "line_russian": "Вау, твой иврит прямо хорош! Кем ты работаешь?",
        "audio_path": None,
        "options": [
            {
                "id": "opt_hebrew_job",
                "text_hebrew": "אֲנִי מְפַתֵּחַ תָּכְנָה בְּחֶבְרַת הַיְטֶק בְּהֶרְצְלִיָּה",
                "text_russian": "Я разработчик софта в хайтек-компании в Герцлии",
                "next_node_id": "node_meet_profession",
                "binyan": "piel",
                "root": "פ-ת-ח"
            }
        ]
    },
    {
        "id": "node_meet_profession",
        "speaker_hebrew": "יוֹסִי",
        "speaker_russian": "Йоси",
        "line_hebrew": "מַגְנִיב לְגַמְרֵי! גַּם אֲנִי אוֹהֵב טֶכְנוֹלוֹגְיָה. בּוֹא נִשְׁתֶּה קָפֶה בַּהַפְסָקָה?",
        "line_russian": "Круто вообще! Я тоже люблю технологии. Пойдем выпьем кофе на перемене?",
        "audio_path": None,
        "options": [
            {
                "id": "opt_prof_coffee_yes",
                "text_hebrew": "בְּשִׂמְחָה רַבָּה, קַח אֶת מִסְפַּר הַוּוֹטְסְאַפּ שֶׁלִּי!",
                "text_russian": "С большой радостью, запиши мой номер WhatsApp!",
                "next_node_id": "node_meet_finish",
                "binyan": "paal",
                "root": "ש-מ-ח"
            }
        ]
    },
    {
        "id": "node_meet_finish",
        "speaker_hebrew": "יוֹסִי",
        "speaker_russian": "Йоси",
        "line_hebrew": "שָׁמַרְתִּי אֶת הַמִּסְפָּר. נִפָּגֵשׁ בֶּחָצֵר עוֹד עֶשֶׂר דַּקּוֹת!",
        "line_russian": "Сохранил номер. Встретимся во дворе через 10 минут!",
        "audio_path": None,
        "options": [
            {
                "id": "opt_meet_restart",
                "text_hebrew": "סָגוּר, אָחִי! נִתְרָאֶה בְּקָרוֹב",
                "text_russian": "Договорились, бро! Скоро увидимся",
                "next_node_id": "node_meet_start",
                "binyan": "hitpael",
                "root": "ר-א-ה"
            }
        ]
    },

    # ==========================================
    # СЦЕНАРИЙ 7: Касса в супермаркете (בַּסּוּפֶּרְמַרְקֶט)
    # ==========================================
    {
        "id": "node_supermarket_start",
        "speaker_hebrew": "קוּפָאִית",
        "speaker_russian": "Кассир",
        "line_hebrew": "שָׁלוֹם! יֵשׁ לְךָ כַּרְטִיס מוֹעֲדוֹן שֶׁל הָרֶשֶׁת?",
        "line_russian": "Здравствуйте! У вас есть клубная карта сети?",
        "audio_path": None,
        "options": [
            {
                "id": "opt_super_has_club",
                "text_hebrew": "כֵּן, הִנֵּה הַכַּרְטִיס. וְאֶפְשָׁר גַּם שַׂקִּיּוֹת?",
                "text_russian": "Да, вот карточка. И можно также пакеты?",
                "next_node_id": "node_supermarket_bag",
                "binyan": "none",
                "root": None
            },
            {
                "id": "opt_super_no_club",
                "text_hebrew": "אֵין לִי כַּרְטִיס, תּוֹדָה. רַק חֶשְׁבּוֹן",
                "text_russian": "У меня нет карты, спасибо. Только чек",
                "next_node_id": "node_supermarket_payment",
                "binyan": "none",
                "root": "ח-ש-ב"
            }
        ]
    },
    {
        "id": "node_supermarket_bag",
        "speaker_hebrew": "קוּפָאִית",
        "speaker_russian": "Кассир",
        "line_hebrew": "בְּוַדַּאי. כַּמָּה שַׂקִּיּוֹת תִּרְצֶה? כָּל שַׂקִּית עוֹלָה עֲשָׂרָה אַגּוֹרוֹת.",
        "line_russian": "Конечно. Сколько пакетов вы хотите? Каждый пакет стоит 10 агорот.",
        "audio_path": None,
        "options": [
            {
                "id": "opt_bag_count",
                "text_hebrew": "שְׁתֵּי שַׂקִּיּוֹת בְּבַקָּשָׁה, יֵשׁ לִי הַרְבֵּה מִצְרָכִים",
                "text_russian": "Два пакета, пожалуйста, у меня много продуктов",
                "next_node_id": "node_supermarket_club",
                "binyan": "none",
                "root": "צ-ר-ך"
            }
        ]
    },
    {
        "id": "node_supermarket_club",
        "speaker_hebrew": "קוּפָאִית",
        "speaker_russian": "Кассир",
        "line_hebrew": "הֶעֱבַרְתִּי אֶת הַכַּרְטִיס, יֵשׁ לְךָ הֲנָחָה שֶׁל עֶשְׂרִים שְׁקָלִים עַל גְּבִינוֹת וְיֵינוֹת.",
        "line_russian": "Я провела карту, у вас скидка 20 шекелей на сыры и вина.",
        "audio_path": None,
        "options": [
            {
                "id": "opt_club_thanks",
                "text_hebrew": "אֵיזֶה כֵּיף, מַמָּשׁ תּוֹדָה! כַּמָּה יָצָא הַסַּךְ הַכֹּל?",
                "text_russian": "Как здорово, спасибо большое! Сколько вышло всего?",
                "next_node_id": "node_supermarket_payment",
                "binyan": "paal",
                "root": "י-צ-א"
            }
        ]
    },
    {
        "id": "node_supermarket_payment",
        "speaker_hebrew": "קוּפָאִית",
        "speaker_russian": "Кассир",
        "line_hebrew": "הַסַּךְ הַכֹּל מֵאָה וְאַרְבָּעִים שְׁקָלִים. אֵיךְ תִּרְצֶה לְשַׁלֵּם? בְּתַשְׁלוּם אֶחָד?",
        "line_russian": "Итого 140 шекелей. Как хотите оплатить? В один платеж?",
        "audio_path": None,
        "options": [
            {
                "id": "opt_pay_one_charge",
                "text_hebrew": "בְּאַשְׁרַאי בְּבַקָּשָׁה, בְּתַשְׁלוּם אֶחָד",
                "text_russian": "Картой, пожалуйста, в один платеж",
                "next_node_id": "node_supermarket_finish",
                "binyan": "piel",
                "root": "ש-ל-ם"
            },
            {
                "id": "opt_pay_cash_exact",
                "text_hebrew": "בִּמְזֻמָּן, הִנֵּה הַסְּכוּם הַמְּדֻיָּק",
                "text_russian": "Наличными, вот точная сумма",
                "next_node_id": "node_supermarket_finish",
                "binyan": "pual",
                "root": "ד-י-ק"
            }
        ]
    },
    {
        "id": "node_supermarket_finish",
        "speaker_hebrew": "קוּפָאִית",
        "speaker_russian": "Кассир",
        "line_hebrew": "הַתַּשְׁלוּם עָבַר בְּהַצְלָחָה! הִנֵּה הַקַּבָּלָה שֶׁלְּךָ. שֶׁיִּהְיֶה יוֹם מְצֻיָּן!",
        "line_russian": "Оплата прошла успешно! Вот ваш чек. Пусть будет отличный день!",
        "audio_path": None,
        "options": [
            {
                "id": "opt_super_restart",
                "text_hebrew": "יוֹם נִפְלָא וְתוֹדָה עַל הָעֶזְרָה!",
                "text_russian": "Замечательного дня и спасибо за помощь!",
                "next_node_id": "node_supermarket_start",
                "binyan": "none",
                "root": "ע-ז-ר"
            }
        ]
    },

    # ==========================================
    # СЦЕНАРИЙ 8: Поликлиника / Купат Холим (בְּקֻפַּת חוֹלִים)
    # ==========================================
    {
        "id": "node_clinic_start",
        "speaker_hebrew": "פְּקִידָה",
        "speaker_russian": "Регистратор",
        "line_hebrew": "בֹּקֶר טוֹב! אֶפְשָׁר כַּרְטִיס קֻפַּת חוֹלִים בְּבַקָּשָׁה?",
        "line_russian": "Доброе утро! Можно карточку больничной кассы, пожалуйста?",
        "audio_path": None,
        "options": [
            {
                "id": "opt_clinic_doctor",
                "text_hebrew": "הִנֵּה הַכַּרְטִיס. יֵשׁ לִי תּוֹר לְרוֹפֵא מִשְׁפָּחָה בְּעֶשֶׂר",
                "text_russian": "Вот карта. У меня запись к семейному врачу в 10:00",
                "next_node_id": "node_clinic_doctor",
                "binyan": "paal",
                "root": "ת-ו-ר"
            },
            {
                "id": "opt_clinic_lab",
                "text_hebrew": "שָׁלוֹם, בָּאתִי לִבְדִיקַת דָּם בַּמַּעְבָּדָה",
                "text_russian": "Здравствуйте, я пришел на анализ крови в лабораторию",
                "next_node_id": "node_clinic_lab",
                "binyan": "paal",
                "root": "ב-ד-ק"
            }
        ]
    },
    {
        "id": "node_clinic_doctor",
        "speaker_hebrew": "פְּקִידָה",
        "speaker_russian": "Регистратор",
        "line_hebrew": "דּוֹקְטוֹר לֵוִי מְקַבֵּל בְּחֶדֶר שְׁתֵּים עֶשְׂרֵה בַּקּוֹמָה הַשְּׁנִיָּה.",
        "line_russian": "Доктор Леви принимает в кабинете 12 на втором этаже.",
        "audio_path": None,
        "options": [
            {
                "id": "opt_doc_ticket",
                "text_hebrew": "תּוֹדָה! אֲנִי צָרִיךְ פֶּתֶק עִם מִסְפַּר תּוֹר?",
                "text_russian": "Спасибо! Мне нужен талончик с номером очереди?",
                "next_node_id": "node_clinic_ticket",
                "binyan": "none",
                "root": "צ-ר-ך"
            }
        ]
    },
    {
        "id": "node_clinic_lab",
        "speaker_hebrew": "פְּקִידָה",
        "speaker_russian": "Регистратор",
        "line_hebrew": "הַמַּעְבָּדָה פְּתוּחָה עַד עֶשֶׂר וָחֵצִי בְּחֶדֶר אַרְבַּע בְּסוֹף הַמִּסְדְּרוֹן.",
        "line_russian": "Лаборатория открыта до 10:30 в кабинете 4 в конце коридора.",
        "audio_path": None,
        "options": [
            {
                "id": "opt_lab_fasting",
                "text_hebrew": "מְצֻיָּן, אֲנִי בְּצוֹם מֵהַבֹּקֶר כְּפִי שֶׁבִּקְּשׁוּ",
                "text_russian": "Отлично, я натощак с утра, как просили",
                "next_node_id": "node_clinic_ticket",
                "binyan": "piel",
                "root": "ב-ק-ש"
            }
        ]
    },
    {
        "id": "node_clinic_ticket",
        "speaker_hebrew": "פְּקִידָה",
        "speaker_russian": "Регистратор",
        "line_hebrew": "הִנֵּה הַפֶּתֶק עִם מִסְפַּר הַתּוֹר שֶׁלְּךָ: 42. כְּשֶׁיַּגִּיעַ תּוֹרְךָ, הַמִּסְפָּר יֵרָאֶה עַל הַמָּסָךְ.",
        "line_russian": "Вот талончик с вашим номером очереди: 42. Когда придет ваш черед, номер появится на экране.",
        "audio_path": None,
        "options": [
            {
                "id": "opt_ticket_wait",
                "text_hebrew": "הֵבַנְתִּי, אֲנִי אֶמְתִּין בַּחֲדַר הַהַמְתָּנָה",
                "text_russian": "Понял, я подожду в зале ожидания",
                "next_node_id": "node_clinic_finish",
                "binyan": "hifil",
                "root": "מ-ת-ן"
            }
        ]
    },
    {
        "id": "node_clinic_finish",
        "speaker_hebrew": "פְּקִידָה",
        "speaker_russian": "Регистратор",
        "line_hebrew": "בְּשִׂמְחָה! שְׁתֵה מַיִם בַּקּוֹלֶר שָׁם וְתִהְיֶה בָּרִיא!",
        "line_russian": "С радостью! Попейте воды из кулера вон там и будьте здоровы!",
        "audio_path": None,
        "options": [
            {
                "id": "opt_clinic_restart",
                "text_hebrew": "תּוֹדָה רַבָּה, יוֹם טוֹב וּבְרִיאוּת לְכֻלָּם!",
                "text_russian": "Большое спасибо, хорошего дня и здоровья всем!",
                "next_node_id": "node_clinic_start",
                "binyan": "none",
                "root": "ב-ר-א"
            }
        ]
    }
]

with open('assets/seed/dialogues_seed.json', 'r', encoding='utf-8') as f:
    existing_nodes = json.load(f)

print(f"Existing dialogue nodes: {len(existing_nodes)}")

# Check for id collisions
existing_ids = {n['id'] for n in existing_nodes}
for node in new_nodes:
    if node['id'] in existing_ids:
        raise ValueError(f"Duplicate id found: {node['id']}")

all_nodes = existing_nodes + new_nodes
print(f"Total dialogue nodes after expansion: {len(all_nodes)}")

with open('assets/seed/dialogues_seed.json', 'w', encoding='utf-8') as f:
    json.dump(all_nodes, f, ensure_ascii=False, indent=2)

print("Saved assets/seed/dialogues_seed.json successfully!")
