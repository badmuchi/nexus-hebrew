# Open-Source Hebrew Content ETL (`tool/import_open_hebrew.py`)

Утилита на чистом Python (только стандартная библиотека) для наполнения оффлайн-базы приложения из открытых лицензированных источников.

## Поддерживаемые источники и лицензии

1. **Tatoeba API v1** (`https://api.tatoeba.org/v1/sentences`):
   - Текстовые пары `heb ↔ rus`: `CC-BY 2.0 FR`.
   - Аудио-записи носителей: строго фильтруются (оставляются только `CC0` и `CC-BY`; клипы с `NC`/`ND`/`No license` отбрасываются).
   - Целевые форматы (`--format`):
     - `srs` -> `assets/seed/srs_seed.json`
     - `listening` -> `assets/seed/listening_seed.json` (с авторасчётом `difficulty` и `focus_words`)
2. **Kaikki.org / Wiktextract Hebrew** (`https://kaikki.org/dictionary/Hebrew/`):
   - Дамп Викисловаря для иврита (`CC BY-SA 4.0`): слова с огласовками (`canonical`), русские переводы, теги биньянов/корней и прямые ссылки на аудио Wikimedia Commons / Lingua Libre.
   - Целевые форматы (`--format`):
     - `srs` -> `assets/seed/srs_seed.json`
     - `grammar` -> `assets/seed/grammar_verbs_seed.json` (таблицы спряжения `present` / `past` / `future`)

## Примеры запуска

```bash
# Предпросмотр карточек SRS с Tatoeba по слову "קפה"
python3 tool/import_open_hebrew.py tatoeba --query קפה --limit 10 --dry-run

# Долить новые фразы с Tatoeba в аудирование (assets/seed/listening_seed.json)
python3 tool/import_open_hebrew.py tatoeba --query שלום --format listening --limit 15

# Импорт карточек SRS из скачанного дампа Kaikki Hebrew JSONL(.gz)
python3 tool/import_open_hebrew.py kaikki --input ~/Downloads/kaikki.org-dictionary-Hebrew.jsonl.gz --limit 100

# Импорт глаголов и таблиц спряжения в assets/seed/grammar_verbs_seed.json
python3 tool/import_open_hebrew.py kaikki --input ~/Downloads/kaikki.org-dictionary-Hebrew.jsonl.gz --format grammar --limit 40
```

## Тесты ETL-скрипта

```bash
python3 -m unittest discover -s tool -p "test_*.py" -v
```
