package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"

	"github.com/antigravity/verb360/backend/internal/tts"
	_ "github.com/antigravity/verb360/backend/migrations"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/tools/filesystem"
)

type VerbData struct {
	ID                string `json:"id"`
	V1                string `json:"v1"`
	V2                string `json:"v2"`
	V3                string `json:"v3"`
	IpaV1             string `json:"ipa_v1"`
	IpaV2             string `json:"ipa_v2"`
	IpaV3             string `json:"ipa_v3"`
	MeaningVi         string `json:"meaning_vi"`
	MorphGroup        string `json:"morph_group"`
	CefrLevel         string `json:"cefr_level"`
	CommonRank        int    `json:"common_rank"`
	ExampleSentence   string `json:"example_sentence"`
	ExampleSentenceVi string `json:"example_sentence_vi"`
}

func main() {
	jsonPath := flag.String("json", "data/verbs_360.json", "Path to verbs_360.json")
	generateAudio := flag.Bool("audio", false, "Generate real TTS MP3 audio files")
	flag.Parse()

	dataBytes, err := os.ReadFile(*jsonPath)
	if err != nil {
		log.Fatalf("Failed to read JSON file %s: %v", *jsonPath, err)
	}

	var verbs []VerbData
	if err := json.Unmarshal(dataBytes, &verbs); err != nil {
		log.Fatalf("Failed to parse JSON: %v", err)
	}

	app := pocketbase.New()
	if err := app.Bootstrap(); err != nil {
		log.Fatalf("Failed to bootstrap PocketBase app: %v", err)
	}

	if err := app.RunAllMigrations(); err != nil {
		log.Fatalf("Failed to run migrations: %v", err)
	}

	collection, err := app.FindCollectionByNameOrId("verbs")
	if err != nil {
		log.Fatalf("Could not find 'verbs' collection: %v", err)
	}

	audioDir := filepath.Join(os.TempDir(), "verb360_seed_audio")
	_ = os.MkdirAll(audioDir, 0755)

	successCount := 0
	for _, v := range verbs {
		// Use deterministic 15-character PocketBase record ID (e.g. verb00000000001)
		recordID := fmt.Sprintf("verb%011d", v.CommonRank)

		// Check if record exists
		existing, _ := app.FindRecordById("verbs", recordID)
		var record *core.Record
		if existing != nil {
			record = existing
		} else {
			record = core.NewRecord(collection)
			record.Set("id", recordID)
		}

		record.Set("v1", v.V1)
		record.Set("v2", v.V2)
		record.Set("v3", v.V3)
		record.Set("ipa_v1", v.IpaV1)
		record.Set("ipa_v2", v.IpaV2)
		record.Set("ipa_v3", v.IpaV3)
		record.Set("meaning_vi", v.MeaningVi)
		record.Set("morph_group", v.MorphGroup)
		record.Set("cefr_level", v.CefrLevel)
		record.Set("common_rank", v.CommonRank)
		record.Set("example_sentence", v.ExampleSentence)
		record.Set("example_sentence_vi", v.ExampleSentenceVi)

		if *generateAudio {
			// Generate MP3s for V1, V2, V3
			f1 := filepath.Join(audioDir, fmt.Sprintf("%s_v1.mp3", v.ID))
			f2 := filepath.Join(audioDir, fmt.Sprintf("%s_v2.mp3", v.ID))
			f3 := filepath.Join(audioDir, fmt.Sprintf("%s_v3.mp3", v.ID))

			_ = tts.GenerateMP3(v.V1, f1)
			_ = tts.GenerateMP3(v.V2, f2)
			_ = tts.GenerateMP3(v.V3, f3)

			if file1, err := filesystem.NewFileFromPath(f1); err == nil {
				record.Set("audio_v1", file1)
			}
			if file2, err := filesystem.NewFileFromPath(f2); err == nil {
				record.Set("audio_v2", file2)
			}
			if file3, err := filesystem.NewFileFromPath(f3); err == nil {
				record.Set("audio_v3", file3)
			}
		}

		if err := app.Save(record); err != nil {
			log.Printf("Failed to save verb %s: %v", v.V1, err)
			continue
		}
		successCount++
	}

	fmt.Printf("Successfully seeded %d/%d verbs into PocketBase database!\n", successCount, len(verbs))
}
