package hooks

import (
	"crypto/sha256"
	"encoding/hex"
	"net/http"
	"strings"

	"github.com/antigravity/verb360/backend/internal/ai"
	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase/core"
)

type EvaluateRequest struct {
	VerbV1       string `json:"verb_v1"`
	TargetForm   string `json:"target_form"`
	UserSentence string `json:"user_sentence"`
}

type ExamplesRequest struct {
	VerbV1 string `json:"verb_v1"`
	Topic  string `json:"topic"`
}

// RegisterCustomRoutes binds custom API endpoints for Verb360 AI
func RegisterCustomRoutes(e *core.ServeEvent, aiService ai.Service) {
	// Health check
	e.Router.GET("/api/health", func(evt *core.RequestEvent) error {
		return evt.JSON(http.StatusOK, map[string]any{
			"status":  "ok",
			"app":     "Verb360 AI Backend",
			"version": "1.0.0",
		})
	})

	// AI sentence evaluation endpoint with semantic cache
	e.Router.POST("/api/ai/evaluate", func(evt *core.RequestEvent) error {
		var req EvaluateRequest
		if err := evt.BindBody(&req); err != nil {
			return evt.BadRequestError("Dữ liệu đầu vào không hợp lệ", err)
		}

		req.VerbV1 = strings.TrimSpace(req.VerbV1)
		req.TargetForm = strings.TrimSpace(req.TargetForm)
		req.UserSentence = strings.TrimSpace(req.UserSentence)

		if req.VerbV1 == "" || req.UserSentence == "" {
			return evt.BadRequestError("verb_v1 và user_sentence không được để trống", nil)
		}

		// Compute hash for caching
		cacheKey := computeHash(req.VerbV1 + ":" + req.TargetForm + ":" + strings.ToLower(req.UserSentence))

		// Check cache in SQLite
		cacheRecords, err := evt.App.FindRecordsByFilter(
			"ai_feedback_cache",
			"hash_prompt = {:hash}",
			"-created",
			1,
			0,
			dbx.Params{"hash": cacheKey},
		)

		if err == nil && len(cacheRecords) > 0 {
			analysis := cacheRecords[0].Get("ai_analysis")
			return evt.JSON(http.StatusOK, map[string]any{
				"cached": true,
				"result": analysis,
			})
		}

		// Evaluate using AI Service
		evalResult, err := aiService.EvaluateSentence(evt.Request.Context(), req.VerbV1, req.TargetForm, req.UserSentence)
		if err != nil {
			return evt.InternalServerError("Lỗi xử lý đánh giá AI", err)
		}

		// Save to cache collection
		cacheColl, err := evt.App.FindCollectionByNameOrId("ai_feedback_cache")
		if err == nil && cacheColl != nil {
			record := core.NewRecord(cacheColl)
			record.Set("hash_prompt", cacheKey)
			record.Set("verb_id", req.VerbV1)
			record.Set("user_sentence", req.UserSentence)
			record.Set("ai_analysis", evalResult)
			_ = evt.App.Save(record)
		}

		return evt.JSON(http.StatusOK, map[string]any{
			"cached": false,
			"result": evalResult,
		})
	})

	// AI context examples generator
	e.Router.POST("/api/ai/examples", func(evt *core.RequestEvent) error {
		var req ExamplesRequest
		if err := evt.BindBody(&req); err != nil {
			return evt.BadRequestError("Dữ liệu đầu vào không hợp lệ", err)
		}

		req.VerbV1 = strings.TrimSpace(req.VerbV1)
		if req.VerbV1 == "" {
			return evt.BadRequestError("verb_v1 không được để trống", nil)
		}

		examples, err := aiService.GenerateContextExamples(evt.Request.Context(), req.VerbV1, req.Topic)
		if err != nil {
			return evt.InternalServerError("Lỗi sinh ví dụ ngữ cảnh từ AI", err)
		}

		return evt.JSON(http.StatusOK, map[string]any{
			"verb":     req.VerbV1,
			"topic":    req.Topic,
			"examples": examples,
		})
	})
}

func computeHash(text string) string {
	h := sha256.New()
	h.Write([]byte(text))
	return hex.EncodeToString(h.Sum(nil))
}
