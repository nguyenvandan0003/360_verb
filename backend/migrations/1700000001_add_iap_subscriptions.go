package migrations

import (
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/tools/types"
)

func init() {
	core.AppMigrations.Register(func(txApp core.App) error {
		// 1. Update users collection with IAP fields
		usersColl, err := txApp.FindCollectionByNameOrId("users")
		if err == nil && usersColl != nil {
			usersColl.Fields.Add(
				&core.BoolField{Name: "is_pro"},
				&core.TextField{Name: "pro_plan"},
				&core.TextField{Name: "pro_expires_at"},
			)
			if err := txApp.Save(usersColl); err != nil {
				return err
			}
		}

		// 2. Create iap_transactions collection
		iapColl := core.NewBaseCollection("iap_transactions")
		iapColl.ListRule = types.Pointer("@request.auth.id != '' && user = @request.auth.id")
		iapColl.ViewRule = types.Pointer("@request.auth.id != '' && user = @request.auth.id")
		iapColl.CreateRule = types.Pointer("@request.auth.id != '' && user = @request.auth.id")

		if usersColl != nil {
			iapColl.Fields.Add(&core.RelationField{
				Name:         "user",
				CollectionId: usersColl.Id,
				MaxSelect:    1,
				Required:     true,
			})
		} else {
			iapColl.Fields.Add(&core.TextField{Name: "user", Required: true})
		}

		iapColl.Fields.Add(
			&core.TextField{Name: "product_id", Required: true},
			&core.TextField{Name: "plan_type", Required: true},
			&core.NumberField{Name: "amount_vnd", Required: true},
			&core.TextField{Name: "platform"},
			&core.TextField{Name: "order_id"},
			&core.TextField{Name: "purchase_token"},
			&core.TextField{Name: "status"},
			&core.TextField{Name: "expires_at"},
		)
		iapColl.AddIndex("idx_iap_user", false, "user", "")
		iapColl.AddIndex("idx_iap_order", false, "order_id", "")

		return txApp.Save(iapColl)
	}, func(txApp core.App) error {
		c, err := txApp.FindCollectionByNameOrId("iap_transactions")
		if err == nil && c != nil {
			_ = txApp.Delete(c)
		}
		return nil
	})
}
