package migrations

import (
	"github.com/pocketbase/pocketbase/core"
)

func init() {
	core.AppMigrations.Register(func(txApp core.App) error {
		usersColl, err := txApp.FindCollectionByNameOrId("users")
		if err == nil && usersColl != nil {
			if usersColl.Fields.GetByName("apple_id") == nil {
				usersColl.Fields.Add(&core.TextField{Name: "apple_id"})
				usersColl.AddIndex("idx_users_apple_id", false, "apple_id", "")
				return txApp.Save(usersColl)
			}
		}
		return nil
	}, func(txApp core.App) error {
		return nil
	})
}
