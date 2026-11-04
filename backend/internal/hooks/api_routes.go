package hooks

import (
	"crypto/sha256"
	"encoding/hex"
	"net/http"
	"strings"
	"time"

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

type IapVerifyRequest struct {
	ProductID     string `json:"product_id"`
	Platform      string `json:"platform"`
	OrderID       string `json:"order_id"`
	PurchaseToken string `json:"purchase_token"`
}

// RegisterCustomRoutes binds custom API endpoints for Verb360 AI
func RegisterCustomRoutes(e *core.ServeEvent, aiService ai.Service) {
	// AI sentence evaluation endpoint with semantic cache (Requires Authentication)
	e.Router.POST("/api/ai/evaluate", func(evt *core.RequestEvent) error {
		if evt.Auth == nil {
			return evt.UnauthorizedError("Vui lòng đăng nhập để sử dụng tính năng Gia sư AI", nil)
		}

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

	// AI context examples generator (Requires Authentication)
	e.Router.POST("/api/ai/examples", func(evt *core.RequestEvent) error {
		if evt.Auth == nil {
			return evt.UnauthorizedError("Vui lòng đăng nhập để sử dụng tính năng Gia sư AI", nil)
		}

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

	// In-App Purchase Verify Endpoint
	e.Router.POST("/api/iap/verify", func(evt *core.RequestEvent) error {
		if evt.Auth == nil {
			return evt.UnauthorizedError("Vui lòng đăng nhập để đồng bộ gói mua VIP.", nil)
		}

		var req IapVerifyRequest
		if err := evt.BindBody(&req); err != nil {
			return evt.BadRequestError("Thông tin giao dịch không hợp lệ", err)
		}

		req.ProductID = strings.TrimSpace(req.ProductID)
		var amountVnd int64
		var planType string
		var expiresAt time.Time
		now := time.Now().UTC()

		switch req.ProductID {
		case "verb360_lifetime_299k":
			amountVnd = 299000
			planType = "lifetime"
			expiresAt = time.Date(2099, 12, 31, 23, 59, 59, 0, time.UTC)
		case "verb360_sub_yearly_199k":
			amountVnd = 199000
			planType = "yearly"
			expiresAt = now.AddDate(1, 0, 0)
		case "verb360_sub_monthly_19k":
			amountVnd = 19000
			planType = "monthly"
			expiresAt = now.AddDate(0, 1, 0)
		default:
			return evt.BadRequestError("Mã sản phẩm IAP không hợp lệ: "+req.ProductID, nil)
		}

		orderId := req.OrderID
		if orderId == "" {
			orderId = "ORD-" + time.Now().Format("20060102150405")
		}

		// 1. Record transaction in iap_transactions collection
		iapColl, err := evt.App.FindCollectionByNameOrId("iap_transactions")
		if err == nil && iapColl != nil {
			txRecord := core.NewRecord(iapColl)
			txRecord.Set("user", evt.Auth.Id)
			txRecord.Set("product_id", req.ProductID)
			txRecord.Set("plan_type", planType)
			txRecord.Set("amount_vnd", amountVnd)
			txRecord.Set("platform", req.Platform)
			txRecord.Set("order_id", orderId)
			txRecord.Set("purchase_token", req.PurchaseToken)
			txRecord.Set("status", "active")
			txRecord.Set("expires_at", expiresAt.Format(time.RFC3339))
			_ = evt.App.Save(txRecord)
		}

		// 2. Update user record with VIP status
		evt.Auth.Set("is_pro", true)
		evt.Auth.Set("pro_plan", planType)
		evt.Auth.Set("pro_expires_at", expiresAt.Format(time.RFC3339))
		if err := evt.App.Save(evt.Auth); err != nil {
			return evt.InternalServerError("Không thể kích hoạt VIP cho tài khoản", err)
		}

		return evt.JSON(http.StatusOK, map[string]any{
			"success":        true,
			"is_pro":         true,
			"plan_type":      planType,
			"product_id":     req.ProductID,
			"amount_vnd":     amountVnd,
			"expires_at":     expiresAt.Format(time.RFC3339),
			"order_id":       orderId,
			"message":        "Chúc mừng! Bạn đã mở khóa thành công gói VIP " + planType + ".",
		})
	})

	// In-App Purchase Status Endpoint
	e.Router.GET("/api/iap/status", func(evt *core.RequestEvent) error {
		if evt.Auth == nil {
			return evt.JSON(http.StatusOK, map[string]any{
				"is_pro":    false,
				"plan_type": "free",
			})
		}

		isPro := evt.Auth.GetBool("is_pro")
		proPlan := evt.Auth.GetString("pro_plan")
		proExpiresAt := evt.Auth.GetString("pro_expires_at")

		// Check expiration if not lifetime
		if isPro && proPlan != "lifetime" && proExpiresAt != "" {
			exp, err := time.Parse(time.RFC3339, proExpiresAt)
			if err == nil && time.Now().UTC().After(exp) {
				isPro = false
				evt.Auth.Set("is_pro", false)
				_ = evt.App.Save(evt.Auth)
			}
		}

		return evt.JSON(http.StatusOK, map[string]any{
			"is_pro":         isPro,
			"plan_type":      proPlan,
			"pro_expires_at": proExpiresAt,
		})
	})
}

func computeHash(text string) string {
	h := sha256.New()
	h.Write([]byte(text))
	return hex.EncodeToString(h.Sum(nil))
}
