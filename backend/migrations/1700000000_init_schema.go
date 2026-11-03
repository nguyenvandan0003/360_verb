package migrations

import (
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/tools/types"
)

func init() {
	core.AppMigrations.Register(func(txApp core.App) error {
		// 1. Verbs collection
		verbsColl := core.NewBaseCollection("verbs")
		verbsColl.ListRule = types.Pointer("")
		verbsColl.ViewRule = types.Pointer("")

		verbsColl.Fields.Add(
			&core.TextField{Name: "v1", Required: true},
			&core.TextField{Name: "v2", Required: true},
			&core.TextField{Name: "v3", Required: true},
			&core.TextField{Name: "ipa_v1"},
			&core.TextField{Name: "ipa_v2"},
			&core.TextField{Name: "ipa_v3"},
			&core.TextField{Name: "meaning_vi", Required: true},
			&core.TextField{Name: "morph_group"},
			&core.TextField{Name: "cefr_level"},
			&core.NumberField{Name: "common_rank"},
			&core.TextField{Name: "example_sentence"},
			&core.TextField{Name: "example_sentence_vi"},
			&core.FileField{Name: "audio_v1", MaxSize: 5 * 1024 * 1024},
			&core.FileField{Name: "audio_v2", MaxSize: 5 * 1024 * 1024},
			&core.FileField{Name: "audio_v3", MaxSize: 5 * 1024 * 1024},
		)
		verbsColl.AddIndex("idx_verbs_v1", false, "v1", "")
		verbsColl.AddIndex("idx_verbs_morph", false, "morph_group", "")
		verbsColl.AddIndex("idx_verbs_cefr", false, "cefr_level", "")

		if err := txApp.Save(verbsColl); err != nil {
			return err
		}

		// Find users collection for relation
		usersColl, err := txApp.FindCollectionByNameOrId("users")
		usersCollId := ""
		if err == nil && usersColl != nil {
			usersCollId = usersColl.Id
		}

		// 2. User Verb Progress collection (SRS SM-2)
		progressColl := core.NewBaseCollection("user_verb_progress")
		progressColl.ListRule = types.Pointer("@request.auth.id != '' && user = @request.auth.id")
		progressColl.ViewRule = types.Pointer("@request.auth.id != '' && user = @request.auth.id")
		progressColl.CreateRule = types.Pointer("@request.auth.id != '' && user = @request.auth.id")
		progressColl.UpdateRule = types.Pointer("@request.auth.id != '' && user = @request.auth.id")
		progressColl.DeleteRule = types.Pointer("@request.auth.id != '' && user = @request.auth.id")

		if usersCollId != "" {
			progressColl.Fields.Add(&core.RelationField{
				Name:         "user",
				CollectionId: usersCollId,
				MaxSelect:    1,
				Required:     true,
			})
		} else {
			progressColl.Fields.Add(&core.TextField{Name: "user", Required: true})
		}

		progressColl.Fields.Add(
			&core.TextField{Name: "verb_id", Required: true},
			&core.NumberField{Name: "repetition_count"},
			&core.NumberField{Name: "interval_days"},
			&core.NumberField{Name: "easiness_factor"},
			&core.TextField{Name: "last_reviewed_at"},
			&core.TextField{Name: "next_review_at"},
			&core.NumberField{Name: "consecutive_correct"},
			&core.NumberField{Name: "total_mistakes"},
		)
		progressColl.AddIndex("idx_user_progress_next", false, "next_review_at", "")

		if err := txApp.Save(progressColl); err != nil {
			return err
		}

		// 3. AI Feedback Cache collection
		cacheColl := core.NewBaseCollection("ai_feedback_cache")
		cacheColl.ListRule = types.Pointer("")
		cacheColl.ViewRule = types.Pointer("")
		cacheColl.CreateRule = types.Pointer("")

		cacheColl.Fields.Add(
			&core.TextField{Name: "hash_prompt", Required: true},
			&core.TextField{Name: "verb_id"},
			&core.TextField{Name: "user_sentence"},
			&core.JSONField{Name: "ai_analysis"},
		)
		cacheColl.AddIndex("idx_cache_hash", false, "hash_prompt", "")

		if err := txApp.Save(cacheColl); err != nil {
			return err
		}

		// 4. User Gamification collection
		gamificationColl := core.NewBaseCollection("user_gamification")
		gamificationColl.ListRule = types.Pointer("@request.auth.id != '' && user = @request.auth.id")
		gamificationColl.ViewRule = types.Pointer("@request.auth.id != '' && user = @request.auth.id")
		gamificationColl.CreateRule = types.Pointer("@request.auth.id != '' && user = @request.auth.id")
		gamificationColl.UpdateRule = types.Pointer("@request.auth.id != '' && user = @request.auth.id")

		if usersCollId != "" {
			gamificationColl.Fields.Add(&core.RelationField{
				Name:         "user",
				CollectionId: usersCollId,
				MaxSelect:    1,
				Required:     true,
			})
		} else {
			gamificationColl.Fields.Add(&core.TextField{Name: "user", Required: true})
		}

		gamificationColl.Fields.Add(
			&core.NumberField{Name: "current_streak"},
			&core.NumberField{Name: "longest_streak"},
			&core.NumberField{Name: "total_xp"},
			&core.JSONField{Name: "badges"},
			&core.TextField{Name: "last_active_date"},
		)

		return txApp.Save(gamificationColl)
	}, func(txApp core.App) error {
		colls := []string{"user_gamification", "ai_feedback_cache", "user_verb_progress", "verbs"}
		for _, name := range colls {
			c, err := txApp.FindCollectionByNameOrId(name)
			if err == nil && c != nil {
				if err := txApp.Delete(c); err != nil {
					return err
				}
			}
		}
		return nil
	})
}
