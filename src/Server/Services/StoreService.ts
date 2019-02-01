import * as Aero from "Shared/Modules/Aero"

// Store Service
// Original by Crazyman32, ported by DataBrain

/*
	
	Server.
		
		StoreService.HasPurchased(player, productId)
		StoreService.GetNumberPurchased(player, productId)
		
		StoreService.PromptPurchaseFinished(player, receiptInfo)
	
	
	Client.
		
		StoreService.HasPurchased(productId)
		StoreService.GetNumberPurchased(productId)
	
		StoreService.PromptPurchaseFinished(receiptInfo)
	
*/



const PRODUCT_PURCHASES_KEY = "ProductPurchases"
const PROMPT_PURCHASE_FINISHED_EVENT = "PromptPurchaseFinished"

const MarketplaceService = game.GetService("MarketplaceService")

const dataStoreScope = "PlayerReceipts"

export class StoreService extends Aero.Service {
    private IncrementPurchase(player: Player, productId: number | string) {
        productId = tostring(productId)
        let productPurchases = this.Services.DataService.Get(player, PRODUCT_PURCHASES_KEY)
        if ((!productPurchases)) {
            productPurchases = {}
            this.Services.DataService.Set(player, PRODUCT_PURCHASES_KEY, productPurchases)
        }
        let n = productPurchases[productId]
        productPurchases[productId] = (n && (n + 1) || 1)
        this.Services.DataService.FlushKey(player, PRODUCT_PURCHASES_KEY)
    }
    private ProcessReceipt(receiptInfo: ReceiptInfo): Enum.ProductPurchaseDecision {
	
        /*
            ReceiptInfo.
                PlayerId               [Number]
                PlaceIdWherePurchased  [Number]
                PurchaseId             [String]
                ProductId              [Number]
                CurrencyType           [CurrencyType Enum]
                CurrencySpent          [Number]
        */
        
        let player = game.GetService("Players").GetPlayerByUserId(receiptInfo.PlayerId)
        
        let dataStoreName = tostring(receiptInfo.PlayerId)
        let key = tostring(receiptInfo.PurchaseId)
        
        // Check if unique purchase was already completed:
        let alreadyPurchased = this.Services.DataService.GetCustom(dataStoreName, dataStoreScope, key)
        
        if ((!alreadyPurchased)) {
            // Mark as purchased and save immediately:
            this.Services.DataService.SetCustom(dataStoreName, dataStoreScope, key, true)
            this.Services.DataService.FlushCustom(dataStoreName, dataStoreScope, key)
        }
        
        if ((player)) {
            this.IncrementPurchase(player, receiptInfo.ProductId)
            this.FireEvent(PROMPT_PURCHASE_FINISHED_EVENT, player, receiptInfo)
            this.FireClientEvent(PROMPT_PURCHASE_FINISHED_EVENT, player, receiptInfo)
        }
        
        return Enum.ProductPurchaseDecision.PurchaseGranted
        
    }
    HasPurchased(player: Player, productId: number | string) {
        let productPurchases = this.Services.DataService.Get(player, PRODUCT_PURCHASES_KEY)
        return (productPurchases && productPurchases[tostring(productId)] !== undefined)
    }
    /** Get the number of productId's purchased. */
    GetNumberPurchased(player: Player, productId: number | string) {
        let n = 0
        let productPurchases = this.Services.DataService.Get(player, PRODUCT_PURCHASES_KEY)
        if ((productPurchases)) {
            n = (productPurchases[tostring(productId)] || 0)
        }
        return n
    }
    Start() {
        MarketplaceService.ProcessReceipt = (receiptInfo) => this.ProcessReceipt(receiptInfo)
    }
    Init() {
        // 'services = this.Services' - Seems like questionable practice to me. Circumvented using private functions.
        this.RegisterEvent(PROMPT_PURCHASE_FINISHED_EVENT)
        this.RegisterClientEvent(PROMPT_PURCHASE_FINISHED_EVENT)
    }
}

export class StoreServiceClient extends Aero.ClientInterface<StoreService> {
    /** Get the number of productId's purchased. */
    GetNumberPurchased = Aero.Sync<(productId: number | string) => number>((player, productId) => {

        // Alternative: use Osyris' 't' module — but we don't want too many dependencies here.
        if (typeof productId === "number" || typeof productId === "string") {
            return this.Server.GetNumberPurchased(player, productId)
        }

        // Fail silently
        return 0
    })
    /** Whether or not the productId has been purchased before. */
    HasPurchased = Aero.Sync<(productId: number | string) => boolean>((player, productId) => {

        if (typeof productId === "number") {
            return this.Server.HasPurchased(player, productId)
        }

        // Fail silently
        return false
    })
}