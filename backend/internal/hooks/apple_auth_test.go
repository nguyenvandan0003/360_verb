package hooks

import (
	"net/http"
	"strings"
	"testing"

	"github.com/antigravity/verb360/backend/internal/ai"
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/tests"
)

func TestAppleAuth(t *testing.T) {
	scenarios := []tests.ApiScenario{
		{
			Name:           "Missing user_identifier returns 400",
			Method:         http.MethodPost,
			URL:            "/api/auth/apple",
			Body:           strings.NewReader(`{"user_identifier": "", "email": "test@apple.com"}`),
			ExpectedStatus: http.StatusBadRequest,
			ExpectedContent: []string{
				"không được để trống",
			},
			BeforeTestFunc: func(t testing.TB, app *tests.TestApp, e *core.ServeEvent) {
				RegisterCustomRoutes(e, ai.NewDeepSeekService("", ""))
			},
		},
		{
			Name:           "Valid user_identifier creates user and returns auth token",
			Method:         http.MethodPost,
			URL:            "/api/auth/apple",
			Body:           strings.NewReader(`{"user_identifier": "001234.apple.test.identifier", "email": "dan.apple@test.com", "full_name": "Dan Apple"}`),
			ExpectedStatus: http.StatusOK,
			ExpectedContent: []string{
				`"token":`,
				`"dan.apple@test.com"`,
			},
			BeforeTestFunc: func(t testing.TB, app *tests.TestApp, e *core.ServeEvent) {
				usersColl, err := app.FindCollectionByNameOrId("users")
				if err == nil && usersColl != nil {
					if usersColl.Fields.GetByName("apple_id") == nil {
						usersColl.Fields.Add(&core.TextField{Name: "apple_id"})
						_ = app.Save(usersColl)
					}
				}
				RegisterCustomRoutes(e, ai.NewDeepSeekService("", ""))
			},
		},
	}

	for _, s := range scenarios {
		s.Test(t)
	}
}
