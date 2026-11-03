package main

import (
	"log"
	"os"

	"github.com/antigravity/verb360/backend/internal/ai"
	"github.com/antigravity/verb360/backend/internal/hooks"
	_ "github.com/antigravity/verb360/backend/migrations"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/plugins/migratecmd"
)

func main() {
	app := pocketbase.New()

	// Register migration commands (pocketbase migrate up/down/create)
	migratecmd.MustRegister(app, app.RootCmd, migratecmd.Config{
		Automigrate: true,
	})

	apiKey := os.Getenv("GEMINI_API_KEY")
	model := os.Getenv("GEMINI_MODEL")
	aiService := ai.NewGeminiService(apiKey, model)

	app.OnServe().BindFunc(func(e *core.ServeEvent) error {
		hooks.RegisterCustomRoutes(e, aiService)
		return e.Next()
	})

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
}
