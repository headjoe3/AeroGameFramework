local TS = require(game:GetService("ReplicatedStorage").RobloxTS.Include.RuntimeLib);
local _exports = {};
local StoreService, StoreServiceClient;
local Aero = TS.import("ReplicatedStorage", "Aero", "Internal", "Aero");
local PRODUCT_PURCHASES_KEY = "ProductPurchases";
local PROMPT_PURCHASE_FINISHED_EVENT = "PromptPurchaseFinished";
local MarketplaceService = game:GetService("MarketplaceService");
local dataStoreScope = "PlayerReceipts";
do
	StoreService = {};
	StoreService.__index = setmetatable({
		IncrementPurchase = function(self, player, productId)
			productId = tostring(productId);
			local productPurchases = self.Services.DataService:Get(player, PRODUCT_PURCHASES_KEY);
			if (not productPurchases) then
				productPurchases = {};
				self.Services.DataService:Set(player, PRODUCT_PURCHASES_KEY, productPurchases);
			end;
			local n = productPurchases[productId];
			productPurchases[productId] = (n and (TS.add(n, 1)) or 1);
			self.Services.DataService:FlushKey(player, PRODUCT_PURCHASES_KEY);
		end;
		ProcessReceipt = function(self, receiptInfo)
			local player = game:GetService("Players"):GetPlayerByUserId(receiptInfo.PlayerId);
			local dataStoreName = tostring(receiptInfo.PlayerId);
			local key = tostring(receiptInfo.PurchaseId);
			local alreadyPurchased = self.Services.DataService:GetCustom(dataStoreName, dataStoreScope, key);
			if (not alreadyPurchased) then
				self.Services.DataService:SetCustom(dataStoreName, dataStoreScope, key, true);
				self.Services.DataService:FlushCustom(dataStoreName, dataStoreScope, key);
			end;
			if (player) then
				self:IncrementPurchase(player, receiptInfo.ProductId);
				self:FireEvent(PROMPT_PURCHASE_FINISHED_EVENT, player, receiptInfo);
				self:FireClientEvent(PROMPT_PURCHASE_FINISHED_EVENT, player, receiptInfo);
			end;
			return Enum.ProductPurchaseDecision.PurchaseGranted;
		end;
		HasPurchased = function(self, player, productId)
			local productPurchases = self.Services.DataService:Get(player, PRODUCT_PURCHASES_KEY);
			return (productPurchases and productPurchases[tostring(productId)] ~= nil);
		end;
		GetNumberPurchased = function(self, player, productId)
			local n = 0;
			local productPurchases = self.Services.DataService:Get(player, PRODUCT_PURCHASES_KEY);
			if (productPurchases) then
				n = (productPurchases[tostring(productId)] or 0);
			end;
			return n;
		end;
		Start = function(self)
			MarketplaceService.ProcessReceipt = function(receiptInfo) return self:ProcessReceipt(receiptInfo); end;
		end;
		Init = function(self)
			self:RegisterEvent(PROMPT_PURCHASE_FINISHED_EVENT);
			self:RegisterClientEvent(PROMPT_PURCHASE_FINISHED_EVENT);
		end;
	}, Aero.Service);
	StoreService.new = function(...)
		return StoreService.constructor(setmetatable({}, StoreService), ...);
	end;
	StoreService.constructor = function(self, ...)
		Aero.Service.constructor(self, ...);
		return self;
	end;
end;
do
	StoreServiceClient = {};
	StoreServiceClient.__index = setmetatable({}, Aero.ClientInterface);
	StoreServiceClient.new = function(...)
		return StoreServiceClient.constructor(setmetatable({}, StoreServiceClient), ...);
	end;
	StoreServiceClient.constructor = function(self, ...)
		Aero.ClientInterface.constructor(self, ...);
		self.GetNumberPurchased = Aero.Sync(function(player, productId)
			if TS.typeof(productId) == "number" or TS.typeof(productId) == "string" then
				return self.Server:GetNumberPurchased(player, productId);
			end;
			return 0;
		end);
		self.HasPurchased = Aero.Sync(function(player, productId)
			if TS.typeof(productId) == "number" then
				return self.Server:HasPurchased(player, productId);
			end;
			return false;
		end);
		return self;
	end;
end;
_exports.StoreService = StoreService;
_exports.StoreServiceClient = StoreServiceClient;
return _exports;
